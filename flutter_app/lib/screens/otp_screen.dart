import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/brutalist_panel.dart';
import 'demo_page.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DemoPage(
      title: 'OTP',
      subtitle: 'Verification step for the demo login flow.',
      headerTag: 'Verification',
      children: [
        BrutalistPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Enter code', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 16),
              const Row(
                children: [
                  _OtpBox(value: '1'),
                  SizedBox(width: 8),
                  _OtpBox(value: '8'),
                  SizedBox(width: 8),
                  _OtpBox(value: '2'),
                  SizedBox(width: 8),
                  _OtpBox(value: '4'),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  ElevatedButton(
                    onPressed: () => context.go('/home'),
                    child: const Text('VERIFY'),
                  ),
                  OutlinedButton(
                    onPressed: () => context.go('/login'),
                    child: const Text('BACK'),
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

class _OtpBox extends StatelessWidget {
  const _OtpBox({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: Colors.black, width: 3),
      ),
      child: Text(
        value,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
            ),
      ),
    );
  }
}