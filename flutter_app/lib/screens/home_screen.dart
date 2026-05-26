import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/demo_destination.dart';
import '../widgets/brutalist_panel.dart';
import 'demo_page.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DemoPage(
      title: 'Home',
      subtitle: 'Cartoon brutalist demo shell for HOMEFUNDI routes.',
      headerTag: 'App shell',
      children: [
        _RouteGroup(
          title: 'Customer routes',
          destinations: demoPublicDestinations,
        ),
        _RouteGroup(
          title: 'Admin routes',
          destinations: demoAdminDestinations,
        ),
        _RouteGroup(
          title: 'Technician routes',
          destinations: demoTechnicianDestinations,
        ),
        BrutalistPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Deep links', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  ElevatedButton(
                    onPressed: () => context.go('/chat/demo-1'),
                    child: const Text('CHAT'),
                  ),
                  ElevatedButton(
                    onPressed: () => context.go('/payment/1001'),
                    child: const Text('PAYMENT'),
                  ),
                  ElevatedButton(
                    onPressed: () => context.go('/tracking/1001'),
                    child: const Text('TRACKING'),
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

class _RouteGroup extends StatelessWidget {
  const _RouteGroup({
    required this.title,
    required this.destinations,
  });

  final String title;
  final List<DemoDestination> destinations;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BrutalistPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(), style: theme.textTheme.headlineMedium),
          const SizedBox(height: 12),
          ...destinations.map(
            (destination) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () => context.go(destination.path),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary.withOpacity(0.25),
                    border: Border.all(color: Colors.black, width: 3),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(destination.label, style: theme.textTheme.titleLarge),
                      const SizedBox(height: 4),
                      Text(destination.description),
                      const SizedBox(height: 4),
                      Text(destination.path, style: theme.textTheme.labelLarge),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}