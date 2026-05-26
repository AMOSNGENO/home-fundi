import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../state/homefundi_state.dart';
import '../../theme/app_theme.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<HomefundiState>();

    return Scaffold(
      backgroundColor: AppTheme.canvas,
      appBar: AppBar(
        title: const Text('Messages'),
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
                          title: 'Inbox',
                          child: state.threads.isEmpty
                              ? const _EmptyState()
                              : Column(
                                  children: state.threads.map((thread) {
                                    final title = thread.participants.isNotEmpty
                                        ? thread.participants.first.displayName
                                        : thread.bookingId ?? thread.id;
                                    final subtitle =
                                        thread.lastMessage ?? 'No messages yet';
                                    final unread = thread.unreadCount ?? 0;
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 12),
                                      child: _ThreadTile(
                                        title: title,
                                        subtitle: subtitle,
                                        meta: unread > 0
                                            ? '$unread unread'
                                            : 'read',
                                        onTap: () => context.go(
                                          '/chat/${thread.id}?title=${Uri.encodeComponent(title)}',
                                        ),
                                      ),
                                    );
                                  }).toList(growable: false),
                                ),
                        ),
                        const SizedBox(height: 16),
                        _Panel(
                          title: 'Fast actions',
                          child: Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              _NavButton(
                                  label: 'Open bookings',
                                  onPressed: () =>
                                      context.go('/tabs/bookings')),
                              _NavButton(
                                label: 'Track a job',
                                onPressed: state.bookings.isNotEmpty
                                    ? () => context.go(
                                        '/tracking/${state.bookings.first.id}')
                                    : () => context.go('/tabs/bookings'),
                              ),
                            ],
                          ),
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

class _ThreadTile extends StatelessWidget {
  const _ThreadTile({
    required this.title,
    required this.subtitle,
    required this.meta,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String meta;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.canvas,
          border: Border.all(color: AppTheme.ink, width: 1.5),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              backgroundColor: AppTheme.ink,
              foregroundColor: Colors.white,
              child: Icon(Icons.chat_bubble_outline, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: const TextStyle(fontSize: 13, height: 1.25)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(meta.toUpperCase(),
                style:
                    const TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
          ],
        ),
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

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.canvas,
        border: Border.all(color: AppTheme.ink, width: 1.5),
      ),
      child: const Text(
        'No conversations yet. Booking updates will appear here.',
        style: TextStyle(fontSize: 14, height: 1.35),
      ),
    );
  }
}
