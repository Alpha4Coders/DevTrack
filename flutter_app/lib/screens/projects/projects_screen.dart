import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/theme.dart';
import '../../models/project.dart';
import '../../providers/project_provider.dart';

class ProjectsScreen extends ConsumerStatefulWidget {
  const ProjectsScreen({super.key});

  @override
  ConsumerState<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends ConsumerState<ProjectsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(projectStateProvider.notifier).fetchProjects();
    });
  }

  @override
  Widget build(BuildContext context) {
    final projectState = ref.watch(projectStateProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ref.read(projectStateProvider.notifier).fetchProjects();
          },
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                floating: true,
                title: const Text('🛠️ Projects'),
                actions: [
                  IconButton(icon: const Icon(Icons.search), onPressed: () {}),
                ],
              ),

              // Content
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    if (projectState.isLoading && projectState.projects.isEmpty)
                      const Center(child: CircularProgressIndicator())
                    else if (projectState.projects.isEmpty)
                      _EmptyState(onAddProject: () => _showAddProjectDialog(context))
                    else
                      ..._buildProjectCards(context, projectState.projects),
                    const SizedBox(height: 100),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddProjectDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Project'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _showAddProjectDialog(BuildContext context) {
    final urlController = TextEditingController();
    final nameController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add New Project', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 20),
            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                labelText: 'GitHub Repository URL',
                hintText: 'https://github.com/user/repo',
                prefixIcon: Icon(Icons.link),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Project Name (optional)',
                hintText: 'My Awesome Project',
                prefixIcon: Icon(Icons.folder),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  final project = Project(
                    id: '',
                    userId: '',
                    name: nameController.text.isNotEmpty
                        ? nameController.text
                        : urlController.text.split('/').last,
                    githubUrl: urlController.text,
                    createdAt: DateTime.now(),
                  );
                  ref.read(projectStateProvider.notifier).addProject(project);
                },
                child: const Text('Analyze & Add Project'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildProjectCards(BuildContext context, List<Project> projects) {
    return projects.asMap().entries.map((entry) {
      final project = entry.value;
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.folder, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(project.name, style: Theme.of(context).textTheme.titleLarge),
                        if (project.githubUrl != null)
                          Text(
                            project.githubUrl!.replaceFirst('https://', ''),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.accent,
                                ),
                          ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: AppColors.textMuted),
                    onSelected: (value) {
                      if (value == 'analyze') {
                        ref.read(projectStateProvider.notifier).analyzeProject(project.id);
                      } else if (value == 'delete') {
                        ref.read(projectStateProvider.notifier).deleteProject(project.id);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'view', child: Text('View Details')),
                      const PopupMenuItem(value: 'analyze', child: Text('Re-analyze')),
                      const PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ),
                ],
              ),
            ),

            // Progress
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Progress', style: Theme.of(context).textTheme.bodyMedium),
                      Text('${(project.progress * 100).toInt()}%',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppColors.accentGreen,
                              )),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: project.progress,
                      backgroundColor: AppColors.border,
                      valueColor: const AlwaysStoppedAnimation(AppColors.accentGreen),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ),

            // Languages
            if (project.languages.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: project.languages
                      .map((lang) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(lang, style: Theme.of(context).textTheme.bodySmall),
                          ))
                      .toList(),
                ),
              ),

            // AI Analysis
            if (project.aiAnalysis != null)
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: AppColors.primary, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        project.aiAnalysis!.summary,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ),
                  ],
                ),
              ),

            // Stats
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatItem(icon: Icons.commit, value: '${project.stats.commits}', label: 'Commits'),
                  _StatItem(
                      icon: Icons.merge_type, value: '${project.stats.pullRequests}', label: 'PRs'),
                  _StatItem(icon: Icons.bug_report, value: '${project.stats.issues}', label: 'Issues'),
                ],
              ),
            ),
          ],
        ),
      ).animate(delay: (200 + entry.key * 100).ms).fadeIn().slideY(begin: 0.1);
    }).toList();
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAddProject;

  const _EmptyState({required this.onAddProject});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(Icons.folder_open, size: 48, color: AppColors.textMuted),
          const SizedBox(height: 12),
          Text('No projects yet', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('Link your GitHub repositories', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onAddProject,
            icon: const Icon(Icons.add),
            label: const Text('Add Your First Project'),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatItem({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.textMuted),
            const SizedBox(width: 4),
            Text(value, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
