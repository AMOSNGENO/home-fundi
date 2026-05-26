import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/brutalist_panel.dart';
import 'demo_page.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key, required this.bookingId});

  final String bookingId;

  @override
  Widget build(BuildContext context) {
    return DemoPage(
      title: 'Payment $bookingId',
      subtitle: 'Checkout route for /payment/:bookingId.',
      headerTag: 'Checkout',
      children: [
        BrutalistPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Amount due', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 12),
              Text('₹1,499', style: Theme.of(context).textTheme.displayLarge),
              const SizedBox(height: 12),
              const Text('Card, cash, and wallet choices can be shown here.'),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  ElevatedButton(
                    onPressed: () => context.go('/tracking/$bookingId'),
                    child: const Text('MARK PAID'),
                  ),
                  OutlinedButton(
                    onPressed: () => context.go('/bookings'),
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