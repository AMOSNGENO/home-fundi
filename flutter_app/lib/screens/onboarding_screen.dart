import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/brutalist_panel.dart';
import 'demo_page.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DemoPage(
      title: 'Welcome to HOMEFUNDI',
      subtitle: 'Pick a flow and jump straight into the demo routes.',
      headerTag: 'Onboarding',
      children: [
        BrutalistPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Choose a path', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 12),
              Text(
                'This shell mirrors the React Native HOMEFUNDI flows with strong outlines and chunky shadows.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  ElevatedButton(
                    onPressed: () => context.go('/login'),
                    child: const Text('LOGIN'),
                  ),
                  OutlinedButton(
                    onPressed: () => context.go('/home'),
                    child: const Text('SKIP TO HOME'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}