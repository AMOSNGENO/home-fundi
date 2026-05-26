import 'package:flutter/material.dart';

import '../widgets/brutalist_panel.dart';

class DemoPage extends StatelessWidget {
  const DemoPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
    this.actions = const [],
    this.headerTag,
  });

  final String title;
  final String subtitle;
  final String? headerTag;
  final List<Widget> children;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(title.toUpperCase()),
        actions: actions,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            BrutalistPanel(
              backgroundColor: theme.colorScheme.secondary.withOpacity(0.95),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (headerTag != null) ...[
                    Text(
                      headerTag!.toUpperCase(),
                      style: theme.textTheme.labelLarge?.copyWith(
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  Text(title, style: theme.textTheme.displayLarge),
                  const SizedBox(height: 10),
                  Text(subtitle, style: theme.textTheme.bodyLarge),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ...children.expand(
              (child) => [child, const SizedBox(height: 16)],
            ),
          ],
        ),
      ),
    );
  }
}