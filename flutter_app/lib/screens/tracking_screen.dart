import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/brutalist_panel.dart';
import 'demo_page.dart';

class TrackingScreen extends StatelessWidget {
  const TrackingScreen({super.key, required this.bookingId});

  final String bookingId;

  @override
  Widget build(BuildContext context) {
    return DemoPage(
      title: 'Tracking $bookingId',
      subtitle: 'Simple status tracker for /tracking/:bookingId.',
      headerTag: 'Live status',
      children: [
        BrutalistPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Technician en route', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 12),
              const Text('ETA: 12 minutes'),
              const Text('Address verified: Yes'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/messages'),
                child: const Text('CONTACT SUPPORT'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}