import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/homefundi_state.dart';
import '../shared/brutalist_widgets.dart';

class TechnicianActiveScreen extends StatelessWidget {
  const TechnicianActiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final bookingsProvider = context.watch<BookingProvider>();
    final user = auth.user;
    final activeJobs = _activeJobs(bookingsProvider.bookings, user);
    final completedJobs = _completedJobs(bookingsProvider.bookings, user);

    return BrutalistPageScaffold(
      title: 'Active Jobs',
      subtitle: 'Keep track of work that has been accepted and is currently underway.',
      child: BrutalistScrollView(
        children: [
          BrutalistCard(
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _SummaryTile(
                  label: 'Active jobs',
                  value: activeJobs.length.toString(),
                  color: brutalMint,
                ),
                _SummaryTile(
                  label: 'Completed',
                  value: completedJobs.length.toString(),
                  color: brutalSky,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          BrutalistSectionHeader(
            title: 'Current jobs',
            subtitle: 'Update the status of each job from the list below.',
          ),
          _BookingList(
            bookings: activeJobs,
            emptyMessage: 'No active jobs found right now.',
            emptyIcon: Icons.work_outline,
            bookingBuilder: (booking) => _ActiveJobCard(
              booking: booking,
              onStart: () => _markInProgress(context, bookingsProvider, booking),
              onComplete: () => _completeBooking(context, bookingsProvider, booking),
            ),
          ),
        ],
      ),
    );
  }

  void _markInProgress(BuildContext context, BookingProvider provider, Booking booking) {
    provider.updateBooking(
      booking.id,
      <String, dynamic>{
        'status': BookingStatus.inProgress,
      },
    );
    _showMessage(context, 'Job marked as in progress.');
  }

  void _completeBooking(BuildContext context, BookingProvider provider, Booking booking) {
    final user = context.read<AuthProvider>().user;
    provider.updateBooking(
      booking.id,
      <String, dynamic>{
        'status': BookingStatus.completed,
        'technicianId': user?.id ?? booking.technicianId,
        'technicianName': user?.name ?? booking.technicianName,
      },
    );
    _showMessage(context, 'Job marked as completed.');
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

class _ActiveJobCard extends StatelessWidget {
  const _ActiveJobCard({
    required this.booking,
    required this.onStart,
    required this.onComplete,
  });

  final Booking booking;
  final VoidCallback onStart;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    final canStart = booking.status == BookingStatus.accepted;

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
              _MetaChip(icon: Icons.schedule_outlined, label: booking.preferredTime),
              if (booking.price != null) _MetaChip(icon: Icons.payments_outlined, label: _currency(booking.price!)),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (canStart)
                BrutalistActionButton(
                  label: 'Start job',
                  backgroundColor: brutalMint,
                  onPressed: onStart,
                ),
              BrutalistActionButton(
                label: 'Complete',
                backgroundColor: brutalSky,
                onPressed: onComplete,
              ),
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

List<Booking> _activeJobs(List<Booking> bookings, AppUser? user) {
  return bookings.where((booking) {
    final assigned = _belongsToTechnician(booking, user);
    return assigned && (booking.status == BookingStatus.accepted || booking.status == BookingStatus.inProgress);
  }).toList(growable: false);
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

String _currency(int value) => '₦${value.toString()}';

void _showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}