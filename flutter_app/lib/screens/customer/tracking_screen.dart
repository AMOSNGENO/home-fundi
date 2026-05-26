import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../state/homefundi_state.dart';
import '../../theme/app_theme.dart';

class TrackingScreen extends StatelessWidget {
  const TrackingScreen({
    super.key,
    this.bookingId,
  });

  final String? bookingId;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<HomefundiState>();
    final booking = bookingId == null ? null : state.bookingById(bookingId!);
    final thread = state.threads.isNotEmpty
        ? state.threads.firstWhere(
            (item) => item.bookingId == bookingId,
            orElse: () => state.threads.first,
          )
        : null;

    final status = booking?.status ?? 'pending';
    final isActive = status != 'completed' && status != 'cancelled';

    return Scaffold(
      backgroundColor: AppTheme.canvas,
      appBar: AppBar(
        title: const Text('Tracking'),
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
                          title: 'Live status',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                booking == null
                                    ? 'Booking not found'
                                    : 'Booking ${booking.id}',
                                style: const TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.w900),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                booking?.notes ??
                                    'Open bookings and choose a real job to track progress.',
                                style:
                                    const TextStyle(fontSize: 14, height: 1.35),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'STATUS: ${status.toUpperCase()}',
                                style: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w900),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _Panel(
                          title: 'Timeline',
                          child: Column(
                            children: [
                              _TimelineStep(
                                index: '1',
                                title: 'Booking confirmed',
                                subtitle: 'Your request has been accepted.',
                                active: status != 'pending',
                              ),
                              const SizedBox(height: 12),
                              _TimelineStep(
                                index: '2',
                                title: 'Technician assigned',
                                subtitle:
                                    'A professional is heading to your location.',
                                active: status == 'accepted' ||
                                    status == 'in_progress' ||
                                    status == 'completed',
                              ),
                              const SizedBox(height: 12),
                              _TimelineStep(
                                index: '3',
                                title: 'Work completed',
                                subtitle:
                                    'Confirm the one-time PIN to close the job.',
                                active: status == 'completed',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _Panel(
                          title: 'Actions',
                          child: Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              _NavButton(
                                label: 'Open chat',
                                onPressed: thread == null
                                    ? null
                                    : () => context.go('/chat/${thread.id}'),
                              ),
                              _NavButton(
                                label: 'Verify OTP',
                                onPressed: booking != null && isActive
                                    ? () => context.go('/otp/${booking.id}')
                                    : null,
                              ),
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

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.index,
    required this.title,
    required this.subtitle,
    required this.active,
  });

  final String index;
  final String title;
  final String subtitle;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: active ? AppTheme.canvas : Colors.white,
        border: Border.all(color: AppTheme.ink, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
                color: AppTheme.leaf, shape: BoxShape.circle),
            child: Text(
              index,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: const TextStyle(fontSize: 13, height: 1.25)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.ink,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      child: Text(label.toUpperCase()),
    );
  }
}
