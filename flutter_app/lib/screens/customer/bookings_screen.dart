import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../state/homefundi_state.dart';
import '../../theme/app_theme.dart';

class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<HomefundiState>();

    return Scaffold(
      backgroundColor: AppTheme.canvas,
      appBar: AppBar(
        title: const Text('Bookings'),
        backgroundColor: AppTheme.canvas,
        foregroundColor: AppTheme.ink,
        elevation: 0,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth =
                constraints.maxWidth >= 900 ? 820.0 : double.infinity;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _Panel(
                          title: 'Active booking',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                state.bookings.isEmpty
                                    ? 'No bookings yet.'
                                    : 'You have ${state.bookings.length} booking(s) in your account.',
                                style: const TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Start a new booking or open a previous job to continue tracking, payment, or chat.',
                                style: TextStyle(fontSize: 14, height: 1.35),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: [
                                  ElevatedButton(
                                    onPressed: () =>
                                        context.go('/book/home-repair'),
                                    style: _buttonStyle(),
                                    child: const Text('BOOK A SERVICE'),
                                  ),
                                  ElevatedButton(
                                    onPressed: state.bookings.isNotEmpty
                                        ? () => context.go(
                                            '/tracking/${state.bookings.first.id}')
                                        : null,
                                    style: _buttonStyle(),
                                    child: const Text('OPEN TRACKING'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _Panel(
                          title: 'Recent jobs',
                          child: state.bookings.isEmpty
                              ? const _EmptyState()
                              : Column(
                                  children: state.bookings
                                      .map(
                                        (booking) => Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 12),
                                          child: _BookingCard(
                                            title: booking.serviceName ??
                                                booking.serviceId ??
                                                'Booking',
                                            status: booking.status ?? 'pending',
                                            subtitle: booking.notes ??
                                                booking.address ??
                                                'Booking details unavailable',
                                            onTracking: () => context
                                                .go('/tracking/${booking.id}'),
                                            onPayment: () => context
                                                .go('/payment/${booking.id}'),
                                          ),
                                        ),
                                      )
                                      .toList(growable: false),
                                ),
                        ),
                        const SizedBox(height: 16),
                        const _Panel(
                          title: 'What you can do here',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _Bullet(text: 'Review the current job status.'),
                              _Bullet(
                                  text:
                                      'Open payment when the estimate is ready.'),
                              _Bullet(
                                  text: 'Jump into the chat room for updates.'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: AppTheme.ink,
      foregroundColor: Colors.white,
      elevation: 0,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppTheme.ink, width: 2),
        boxShadow: const [
          BoxShadow(color: AppTheme.leaf, offset: Offset(4, 4), blurRadius: 0),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1.2),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({
    required this.title,
    required this.status,
    required this.subtitle,
    required this.onTracking,
    required this.onPayment,
  });

  final String title;
  final String status;
  final String subtitle;
  final VoidCallback onTracking;
  final VoidCallback onPayment;

  @override
  Widget build(BuildContext context) {
    final statusLabel = status.toUpperCase();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.canvas,
        border: Border.all(color: AppTheme.ink, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(statusLabel,
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text(subtitle, style: const TextStyle(fontSize: 13, height: 1.25)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              TextButton(onPressed: onTracking, child: const Text('TRACK')),
              TextButton(onPressed: onPayment, child: const Text('PAY')),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.canvas,
        border: Border.all(color: AppTheme.ink, width: 1.5),
      ),
      child: const Text(
        'No bookings yet. Create your first repair request to see it listed here.',
        style: TextStyle(fontSize: 14, height: 1.35),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  ', style: TextStyle(fontSize: 20, height: 1)),
          Expanded(
              child: Text(text,
                  style: const TextStyle(fontSize: 14, height: 1.35))),
        ],
      ),
    );
  }
}
