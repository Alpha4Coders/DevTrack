import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/theme.dart';
import '../../models/log_entry.dart';
import '../../providers/log_provider.dart';

class LearningScreen extends ConsumerStatefulWidget {
  const LearningScreen({super.key});

  @override
  ConsumerState<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends ConsumerState<LearningScreen> {
  bool _showAddForm = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(logStateProvider.notifier).fetchLogs(refresh: true);
      ref.read(logStateProvider.notifier).fetchStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final logState = ref.watch(logStateProvider);
    final stats = logState.stats;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ref.read(logStateProvider.notifier).fetchLogs(refresh: true);
            await ref.read(logStateProvider.notifier).fetchStats();
          },
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                floating: true,
                title: const Text('📚 Learning Tracker'),
                actions: [
                  IconButton(icon: const Icon(Icons.filter_list), onPressed: () {}),
                  IconButton(icon: const Icon(Icons.search), onPressed: () {}),
                ],
              ),

              // Content
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Stats Row
                    Row(
                      children: [
                        _StatChip(
                          label: 'Today',
                          value: '${stats?.weeklyActivity.isNotEmpty == true ? stats!.weeklyActivity.last.hours.toStringAsFixed(1) : '0'}h',
                          color: AppColors.accentGreen,
                        ),
                        const SizedBox(width: 8),
                        _StatChip(
                          label: 'Total',
                          value: '${stats?.totalHours.toStringAsFixed(0) ?? '0'}h',
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        _StatChip(
                          label: 'Streak',
                          value: '${stats?.currentStreak ?? 0} days',
                          color: AppColors.accentOrange,
                        ),
                      ],
                    ).animate().fadeIn().slideY(begin: 0.1),

                    const SizedBox(height: 24),

                    // Add new entry section
                    if (_showAddForm) ...[
                      _AddEntryForm(
                        onCancel: () => setState(() => _showAddForm = false),
                        onSave: (entry) async {
                          setState(() => _showAddForm = false);
                          await ref.read(logStateProvider.notifier).addLog(entry);
                        },
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Section header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Recent Entries', style: Theme.of(context).textTheme.titleLarge),
                        Text('${logState.entries.length} entries',
                            style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Loading indicator
                    if (logState.isLoading && logState.entries.isEmpty)
                      const Center(child: CircularProgressIndicator())
                    else if (logState.entries.isEmpty)
                      _EmptyState(onAddEntry: () => setState(() => _showAddForm = true))
                    else
                      ..._buildLearningEntries(logState.entries),

                    const SizedBox(height: 100),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => setState(() => _showAddForm = !_showAddForm),
        icon: Icon(_showAddForm ? Icons.close : Icons.add),
        label: Text(_showAddForm ? 'Cancel' : 'Add Entry'),
        backgroundColor: _showAddForm ? AppColors.error : AppColors.primary,
      ),
    );
  }

  List<Widget> _buildLearningEntries(List<LogEntry> entries) {
    return entries.asMap().entries.map((entry) {
      final log = entry.value;
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
                  Text(log.mood, style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatDate(log.date),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          '${log.durationHours.toStringAsFixed(1)}h',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppColors.accentGreen,
                              ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: AppColors.textMuted),
                    onSelected: (value) {
                      if (value == 'delete') {
                        ref.read(logStateProvider.notifier).deleteLog(log.id);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      const PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(log.description, style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 12),
                  if (log.tags.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: log.tags
                          .map((tag) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                                ),
                                child: Text(tag,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(color: AppColors.primary)),
                              ))
                          .toList(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ).animate(delay: (200 + entry.key * 100).ms).fadeIn().slideY(begin: 0.1);
    }).toList();
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return 'Today';
    }
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day - 1) {
      return 'Yesterday';
    }
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(value,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: color, fontWeight: FontWeight.bold)),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAddEntry;

  const _EmptyState({required this.onAddEntry});

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
          const Icon(Icons.edit_note, size: 48, color: AppColors.textMuted),
          const SizedBox(height: 12),
          Text('No learning entries yet', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('Start tracking your learning journey!',
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onAddEntry,
            icon: const Icon(Icons.add),
            label: const Text('Add First Entry'),
          ),
        ],
      ),
    );
  }
}

class _AddEntryForm extends StatefulWidget {
  final VoidCallback onCancel;
  final Function(LogEntry) onSave;

  const _AddEntryForm({required this.onCancel, required this.onSave});

  @override
  State<_AddEntryForm> createState() => _AddEntryFormState();
}

class _AddEntryFormState extends State<_AddEntryForm> {
  final _descriptionController = TextEditingController();
  final List<String> _selectedTags = [];
  String _selectedMood = '😊';

  final moods = ['😊', '😐', '😕', '😫', '🤩'];
  final suggestedTags = ['React', 'JavaScript', 'TypeScript', 'Node.js', 'Flutter', 'Python'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('➕ New Learning Entry', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'What did you learn?',
              hintText: 'Describe what you learned today...',
            ),
          ),
          const SizedBox(height: 16),
          Text('Tags', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: suggestedTags.map((tag) {
              final isSelected = _selectedTags.contains(tag);
              return FilterChip(
                label: Text(tag),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedTags.add(tag);
                    } else {
                      _selectedTags.remove(tag);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Text('How was it?', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: moods.map((mood) {
              final isSelected = _selectedMood == mood;
              return GestureDetector(
                onTap: () => setState(() => _selectedMood = mood),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: isSelected ? AppColors.primary : Colors.transparent),
                  ),
                  child: Text(mood, style: const TextStyle(fontSize: 28)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                  child: OutlinedButton(onPressed: widget.onCancel, child: const Text('Cancel'))),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (_descriptionController.text.isEmpty) return;
                    final entry = LogEntry(
                      id: '',
                      userId: '',
                      date: DateTime.now(),
                      description: _descriptionController.text,
                      tags: _selectedTags,
                      mood: _selectedMood,
                      createdAt: DateTime.now(),
                    );
                    widget.onSave(entry);
                  },
                  child: const Text('Save Entry'),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.1);
  }
}
