import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/brutalist_panel.dart';
import 'demo_page.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DemoPage(
      title: 'Login',
      subtitle: 'Demo authentication entry point with no backend integration.',
      headerTag: 'Auth',
      children: [
        BrutalistPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sign in', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 16),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Phone or email',
                  hintText: 'jane@homefundi.app',
                ),
              ),
              const SizedBox(height: 12),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: '••••••••',
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  ElevatedButton(
                    onPressed: () => context.go('/otp'),
                    child: const Text('SEND OTP'),
                  ),
                  OutlinedButton(
                    onPressed: () => context.go('/home'),
                    child: const Text('ENTER HOME'),
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