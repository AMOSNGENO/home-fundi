import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/brutalist_panel.dart';
import 'demo_page.dart';

class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DemoPage(
      title: 'Bookings',
      subtitle: 'Customer booking list with payment and tracking shortcuts.',
      headerTag: 'Customer',
      children: [
        BrutalistPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _BookingCard(
                id: '1001',
                service: 'AC Repair',
                status: 'Awaiting payment',
                onPay: () => context.go('/payment/1001'),
                onTrack: () => context.go('/tracking/1001'),
              ),
              const SizedBox(height: 12),
              _BookingCard(
                id: '1002',
                service: 'Washing Machine',
                status: 'Technician assigned',
                onPay: () => context.go('/payment/1002'),
                onTrack: () => context.go('/tracking/1002'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({
    required this.id,
    required this.service,
    required this.status,
    required this.onPay,
    required this.onTrack,
  });

  final String id;
  final String service;
  final String status;
  final VoidCallback onPay;
  final VoidCallback onTrack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(color: Colors.black, width: 3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Booking #$id', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(service, style: theme.textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(status),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ElevatedButton(onPressed: onPay, child: const Text('PAY')),
              OutlinedButton(onPressed: onTrack, child: const Text('TRACK')),
            ],
          ),
        ],
      ),
    );
  }
}