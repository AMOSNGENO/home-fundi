import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../state/homefundi_state.dart';
import '../../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<HomefundiState>();
    final user = state.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.canvas,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppTheme.canvas,
        foregroundColor: AppTheme.ink,
        elevation: 0,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth =
                constraints.maxWidth >= 900 ? 820.0 : double.infinity;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _Panel(
                          title: 'Account',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _InfoRow(
                                  label: 'Name',
                                  value: user?.displayName ?? 'Guest'),
                              const SizedBox(height: 8),
                              _InfoRow(
                                  label: 'Phone',
                                  value: user?.phone ?? 'Not set'),
                              const SizedBox(height: 8),
                              _InfoRow(
                                  label: 'Email',
                                  value: user?.email ?? 'Not set'),
                              const SizedBox(height: 8),
                              _InfoRow(
                                  label: 'Role',
                                  value:
                                      user?.role?.toUpperCase() ?? 'CUSTOMER'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _Panel(
                          title: 'Quick actions',
                          child: Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              _NavButton(
                                  label: 'Bookings',
                                  onPressed: () =>
                                      context.go('/tabs/bookings')),
                              _NavButton(
                                  label: 'Messages',
                                  onPressed: () =>
                                      context.go('/tabs/messages')),
                              _NavButton(
                                  label: 'Home',
                                  onPressed: () => context.go('/tabs/home')),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        const _Panel(
                          title: 'Preferences',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _Bullet(text: 'Notification settings'),
                              _Bullet(text: 'Saved addresses'),
                              _Bullet(text: 'Support and help'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () async {
                            await context.read<HomefundiState>().logout();
                            if (context.mounted) {
                              context.go('/auth');
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.danger,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('LOG OUT'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppTheme.ink, width: 2),
        boxShadow: const [
          BoxShadow(color: AppTheme.leaf, offset: Offset(4, 4), blurRadius: 0),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1.2),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.canvas,
        border: Border.all(color: AppTheme.ink, width: 1.5),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 84,
            child: Text(
              label.toUpperCase(),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  ', style: TextStyle(fontSize: 20, height: 1)),
          Expanded(
              child: Text(text,
                  style: const TextStyle(fontSize: 14, height: 1.35))),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.ink,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      child: Text(label.toUpperCase()),
    );
  }
}
