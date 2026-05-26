import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/homefundi_state.dart';
import '../shared/brutalist_widgets.dart';

class TechnicianEarningsScreen extends StatelessWidget {
  const TechnicianEarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final bookingsProvider = context.watch<BookingProvider>();
    final user = auth.user;
    final completedJobs = _completedJobs(bookingsProvider.bookings, user);
    final totalEarnings = _totalEarnings(completedJobs);
    final walletBalance = user?.wallet ?? 0;
    final averageTicket = completedJobs.isEmpty ? 0 : (totalEarnings / completedJobs.length).round();

    return BrutalistPageScaffold(
      title: 'Earnings',
      subtitle: 'See how much you have earned and review the jobs that contributed to your balance.',
      child: BrutalistScrollView(
        children: [
          BrutalistCard(
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _SummaryTile(
                  label: 'Total earnings',
                  value: _currency(totalEarnings),
                  color: brutalAccent,
                ),
                _SummaryTile(
                  label: 'Wallet balance',
                  value: _currency(walletBalance),
                  color: brutalMint,
                ),
                _SummaryTile(
                  label: 'Completed jobs',
                  value: completedJobs.length.toString(),
                  color: brutalSky,
                ),
                _SummaryTile(
                  label: 'Avg. ticket',
                  value: _currency(averageTicket),
                  color: brutalPink,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          BrutalistSectionHeader(
            title: 'Completed jobs',
            subtitle: 'These finished bookings make up your earnings summary.',
          ),
          _BookingList(
            bookings: completedJobs,
            emptyMessage: 'No completed jobs yet.',
            emptyIcon: Icons.payments_outlined,
            bookingBuilder: (booking) => _CompletedJobCard(booking: booking),
          ),
        ],
      ),
    );
  }
}

class _BookingList extends StatelessWidget {
  const _BookingList({
    required this.bookings,
    required this.emptyMessage,
    required this.emptyIcon,
    required this.bookingBuilder,
  });

  final List<Booking> bookings;
  final String emptyMessage;
  final IconData emptyIcon;
  final Widget Function(Booking booking) bookingBuilder;

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(emptyIcon, size: 40, color: brutalInk),
              const SizedBox(height: 10),
              Text(
                emptyMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  fontWeight: FontWeight.w700,
                  color: brutalInk,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        for (var i = 0; i < bookings.length; i++) ...[
          bookingBuilder(bookings[i]),
          if (i != bookings.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _CompletedJobCard extends StatelessWidget {
  const _CompletedJobCard({required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final earned = booking.price ?? 0;

    return BrutalistCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${booking.brand} ${booking.model}',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: brutalInk,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      booking.category,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: brutalInk,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusBadge(status: booking.status),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            booking.problem,
            style: const TextStyle(
              fontSize: 13,
              height: 1.4,
              fontWeight: FontWeight.w700,
              color: brutalInk,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetaChip(icon: Icons.place_outlined, label: booking.location),
              _MetaChip(icon: Icons.calendar_month_outlined, label: booking.preferredDate),
              _MetaChip(icon: Icons.payments_outlined, label: _currency(earned)),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: brutalInk, width: 2.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: brutalInk,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: brutalInk,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final BookingStatus status;

  @override
  Widget build(BuildContext context) {
    final Color background = switch (status) {
      BookingStatus.pending => brutalAccent,
      BookingStatus.accepted => brutalMint,
      BookingStatus.inProgress => brutalSky,
      BookingStatus.completed => Colors.green.shade200,
      BookingStatus.cancelled => Colors.red.shade200,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: brutalInk, width: 2),
      ),
      child: Text(
        status.label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: brutalInk,
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: brutalSurface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: brutalInk, width: 1.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: brutalInk),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: brutalInk,
            ),
          ),
        ],
      ),
    );
  }
}

List<Booking> _completedJobs(List<Booking> bookings, AppUser? user) {
  return bookings.where((booking) {
    final assigned = _belongsToTechnician(booking, user);
    return assigned && booking.status == BookingStatus.completed;
  }).toList(growable: false);
}

bool _belongsToTechnician(Booking booking, AppUser? user) {
  if (user == null) {
    return true;
  }

  final assignedId = booking.technicianId?.trim() ?? '';
  final assignedName = booking.technicianName?.trim().toLowerCase() ?? '';
  final userName = user.name.trim().toLowerCase();

  return assignedId.isEmpty ||
      assignedId == user.id ||
      assignedName == userName ||
      assignedName.isEmpty;
}

int _totalEarnings(List<Booking> bookings) {
  return bookings.fold<int>(0, (sum, booking) => sum + (booking.price ?? 0));
}

String _currency(int value) => '₦${value.toString()}';