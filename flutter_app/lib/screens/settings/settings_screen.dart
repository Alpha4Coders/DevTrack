import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../config/router.dart';
import '../../providers/auth_provider.dart';
import '../../services/notification_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _isSendingTest = false;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final user = authState.user;

    return Scaffold(
      appBar: AppBar(title: const Text('⚙️ Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile section
          _SettingsSection(
            title: 'Profile',
            children: [
              _SettingsTile(
                icon: Icons.person_outline,
                title: user?.name ?? 'User',
                subtitle: user?.email ?? 'No email',
                leading: CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary,
                  backgroundImage: user?.avatarUrl != null
                      ? NetworkImage(user!.avatarUrl!)
                      : null,
                  child: user?.avatarUrl == null
                      ? Text(
                          user?.name.isNotEmpty == true
                              ? user!.name[0].toUpperCase()
                              : '?',
                          style: const TextStyle(color: Colors.white),
                        )
                      : null,
                ),
              ),
              _SettingsTile(
                icon: Icons.link,
                title: 'Connected Accounts',
                subtitle: user?.githubUsername != null
                    ? 'GitHub: @${user!.githubUsername}'
                    : 'GitHub connected',
                trailing: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accentGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('Connected',
                      style: TextStyle(
                          color: AppColors.accentGreen, fontSize: 12)),
                ),
              ),
            ],
          ),

          // Notifications section
          _SettingsSection(
            title: 'Notifications',
            children: [
              _SettingsTile(
                icon: Icons.notifications_outlined,
                title: 'Push Notifications',
                subtitle: 'Daily reminders & task alerts',
                trailing: Switch(
                  value: _notificationsEnabled,
                  onChanged: (value) async {
                    setState(() => _notificationsEnabled = value);
                    if (value) {
                      await NotificationService().registerToken();
                    } else {
                      await NotificationService().unregister();
                    }
                  },
                  activeThumbColor: AppColors.primary,
                ),
              ),
              _SettingsTile(
                icon: Icons.send,
                title: 'Test Notification',
                subtitle: 'Send a test push notification',
                trailing: _isSendingTest
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.chevron_right,
                        color: AppColors.textMuted),
                onTap: () async {
                  setState(() => _isSendingTest = true);
                  final success =
                      await NotificationService().sendTestNotification();
                  setState(() => _isSendingTest = false);

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(success
                            ? '✅ Test notification sent!'
                            : '❌ Failed to send notification'),
                        backgroundColor:
                            success ? AppColors.accentGreen : AppColors.error,
                      ),
                    );
                  }
                },
              ),
            ],
          ),

          // Preferences section
          _SettingsSection(
            title: 'Preferences',
            children: [
              const _SettingsTile(
                icon: Icons.dark_mode_outlined,
                title: 'Theme',
                subtitle: 'Dark mode',
              ),
              _SettingsTile(
                icon: Icons.flag_outlined,
                title: 'Goals',
                subtitle: 'Set your learning goals',
                onTap: () {},
              ),
            ],
          ),

          // Data section
          _SettingsSection(
            title: 'Data & Privacy',
            children: [
              _SettingsTile(
                icon: Icons.download_outlined,
                title: 'Export Data',
                subtitle: 'Download your learning history',
                onTap: () {},
              ),
              _SettingsTile(
                icon: Icons.delete_outline,
                title: 'Clear Cache',
                subtitle: 'Free up storage space',
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Clear Cache?'),
                      content: const Text(
                          'This will remove cached data. Your account data will remain safe.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Cache cleared')),
                            );
                          },
                          child: const Text('Clear'),
                        ),
                      ],
                    ),
                  );
                },
              ),
              _SettingsTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                onTap: () {},
              ),
            ],
          ),

          // About section
          _SettingsSection(
            title: 'About',
            children: [
              const _SettingsTile(
                icon: Icons.info_outline,
                title: 'Version',
                subtitle: '1.0.0 (Flutter)',
              ),
              _SettingsTile(
                icon: Icons.feedback_outlined,
                title: 'Send Feedback',
                onTap: () {},
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Logout button
          ElevatedButton.icon(
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Log Out'),
                  content: const Text('Are you sure you want to log out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Log Out'),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                await NotificationService().unregister();
                await ref.read(authStateProvider.notifier).logout();
                if (context.mounted) {
                  context.go(AppRoutes.login);
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error.withOpacity(0.1),
              foregroundColor: AppColors.error,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            icon: const Icon(Icons.logout),
            label: const Text('Log Out'),
          ),

          const SizedBox(height: 32),
          Text('Built with ❤️ by Alpha Coders',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: AppColors.textMuted)),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: children.asMap().entries.map((entry) {
              final isLast = entry.key == children.length - 1;
              return Column(
                children: [
                  entry.value,
                  if (!isLast) const Divider(height: 1, indent: 56),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget? leading;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.leading,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: leading ?? Icon(icon, color: AppColors.textSecondary),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: trailing ??
          (onTap != null
              ? const Icon(Icons.chevron_right, color: AppColors.textMuted)
              : null),
      onTap: onTap,
    );
  }
}
