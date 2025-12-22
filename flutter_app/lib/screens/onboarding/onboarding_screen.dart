import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../config/router.dart';
import '../../providers/auth_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  // User preferences
  String? _selectedGoal;
  final List<String> _selectedSkills = [];
  String? _workPattern;
  
  final List<String> goals = [
    'Learn new technologies',
    'Build side projects',
    'Track daily progress',
    'Prepare for interviews',
    'Contribute to open source',
  ];
  
  final List<String> skills = [
    'JavaScript', 'TypeScript', 'React', 'Vue', 'Angular',
    'Node.js', 'Python', 'Java', 'Go', 'Rust',
    'Flutter', 'Swift', 'Kotlin', 'C#', 'PHP',
  ];
  
  final List<String> workPatterns = [
    'Morning (6 AM - 12 PM)',
    'Afternoon (12 PM - 6 PM)',
    'Evening (6 PM - 12 AM)',
    'Night (12 AM - 6 AM)',
    'Flexible / Varies',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _completeOnboarding() {
    ref.read(authStateProvider.notifier).completeOnboarding();
    context.go(AppRoutes.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: List.generate(3, (index) {
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
                      decoration: BoxDecoration(
                        color: index <= _currentPage
                            ? AppColors.primary
                            : AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),
            
            // Page content
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) {
                  setState(() => _currentPage = page);
                },
                children: [
                  _buildGoalsPage(),
                  _buildSkillsPage(),
                  _buildWorkPatternPage(),
                ],
              ),
            ),
            
            // Navigation
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    TextButton(
                      onPressed: () => _pageController.previousPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      ),
                      child: const Text('Back'),
                    ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _nextPage,
                    child: Text(_currentPage < 2 ? 'Continue' : 'Get Started'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What\'s your main goal?',
            style: Theme.of(context).textTheme.displaySmall,
          ).animate().fadeIn().slideY(begin: 0.2),
          const SizedBox(height: 8),
          Text(
            'This helps us personalize your experience',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
          ).animate(delay: 100.ms).fadeIn(),
          const SizedBox(height: 32),
          ...goals.asMap().entries.map((entry) {
            final goal = entry.value;
            final isSelected = _selectedGoal == goal;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () => setState(() => _selectedGoal = goal),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          goal,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: isSelected ? AppColors.primary : AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (isSelected)
                        const Icon(Icons.check_circle, color: AppColors.primary),
                    ],
                  ),
                ),
              ),
            ).animate(delay: (200 + entry.key * 100).ms).fadeIn().slideX(begin: 0.1);
          }),
        ],
      ),
    );
  }

  Widget _buildSkillsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select your skills',
            style: Theme.of(context).textTheme.displaySmall,
          ).animate().fadeIn().slideY(begin: 0.2),
          const SizedBox(height: 8),
          Text(
            'Choose technologies you work with',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
          ).animate(delay: 100.ms).fadeIn(),
          const SizedBox(height: 32),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: skills.asMap().entries.map((entry) {
              final skill = entry.value;
              final isSelected = _selectedSkills.contains(skill);
              return FilterChip(
                label: Text(skill),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedSkills.add(skill);
                    } else {
                      _selectedSkills.remove(skill);
                    }
                  });
                },
                backgroundColor: AppColors.surface,
                selectedColor: AppColors.primary.withOpacity(0.2),
                checkmarkColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                ),
                side: BorderSide(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
              );
            }).toList(),
          ).animate(delay: 200.ms).fadeIn(),
        ],
      ),
    );
  }

  Widget _buildWorkPatternPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'When do you usually code?',
            style: Theme.of(context).textTheme.displaySmall,
          ).animate().fadeIn().slideY(begin: 0.2),
          const SizedBox(height: 8),
          Text(
            'We\'ll send reminders at the right time',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
          ).animate(delay: 100.ms).fadeIn(),
          const SizedBox(height: 32),
          ...workPatterns.asMap().entries.map((entry) {
            final pattern = entry.value;
            final isSelected = _workPattern == pattern;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () => setState(() => _workPattern = pattern),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getPatternIcon(entry.key),
                        color: isSelected ? AppColors.primary : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          pattern,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: isSelected ? AppColors.primary : AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (isSelected)
                        const Icon(Icons.check_circle, color: AppColors.primary),
                    ],
                  ),
                ),
              ),
            ).animate(delay: (200 + entry.key * 100).ms).fadeIn().slideX(begin: 0.1);
          }),
        ],
      ),
    );
  }

  IconData _getPatternIcon(int index) {
    switch (index) {
      case 0:
        return Icons.wb_sunny_outlined;
      case 1:
        return Icons.wb_cloudy_outlined;
      case 2:
        return Icons.nights_stay_outlined;
      case 3:
        return Icons.dark_mode_outlined;
      default:
        return Icons.schedule;
    }
  }
}
