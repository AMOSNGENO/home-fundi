import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/brutalist_panel.dart';
import 'demo_page.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DemoPage(
      title: 'Messages',
      subtitle: 'Inbox-style list with direct chat routes.',
      headerTag: 'Support',
      children: [
        BrutalistPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ThreadCard(
                title: 'Technician Raj',
                preview: 'On the way. ETA 12 minutes.',
                chatId: 'raj-12',
                onOpen: () => context.go('/chat/raj-12'),
              ),
              const SizedBox(height: 12),
              _ThreadCard(
                title: 'Admin Desk',
                preview: 'Your booking has been approved.',
                chatId: 'admin-01',
                onOpen: () => context.go('/chat/admin-01'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ThreadCard extends StatelessWidget {
  const _ThreadCard({
    required this.title,
    required this.preview,
    required this.chatId,
    required this.onOpen,
  });

  final String title;
  final String preview;
  final String chatId;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary.withOpacity(0.2),
        border: Border.all(color: Colors.black, width: 3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(preview),
          const SizedBox(height: 4),
          Text('/chat/$chatId', style: theme.textTheme.labelLarge),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onOpen, child: const Text('OPEN CHAT')),
        ],
      ),
    );
  }
}