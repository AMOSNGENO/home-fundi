import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/brutalist_panel.dart';
import 'demo_page.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key, required this.chatId});

  final String chatId;

  @override
  Widget build(BuildContext context) {
    return DemoPage(
      title: 'Chat $chatId',
      subtitle: 'Route parameter demo for /chat/:id.',
      headerTag: 'Conversation',
      children: [
        BrutalistPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Messages', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 12),
              const Text('Technician: I am 5 minutes away.'),
              const SizedBox(height: 8),
              const Text('Customer: Great, thank you!'),
              const SizedBox(height: 8),
              const Text('System: Status changed to en route.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/messages'),
                child: const Text('BACK TO INBOX'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}