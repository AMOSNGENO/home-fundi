import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../state/homefundi_state.dart';
import 'shared/brutalist_widgets.dart';

class TechnicianScreen extends StatelessWidget {
  const TechnicianScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final bookingsProvider = context.watch<BookingProvider>();
    final user = auth.user;
    final pendingJobs = _pendingJobs(bookingsProvider.bookings);
    final activeJobs = _activeJobs(bookingsProvider.bookings, user);
    final completedJobs = _completedJobs(bookingsProvider.bookings, user);
    final totalEarnings = _totalEarnings(completedJobs);

    return BrutalistPageScaffold(
      title: 'Technician Dashboard',
      subtitle: 'Review incoming requests, track active work, and keep your profile up to date.',
      actions: [
        BrutalistActionButton(
          label: 'Active',
          backgroundColor: brutalMint,
          onPressed: () => context.go('/technician/active'),
        ),
        BrutalistActionButton(
          label: 'Earnings',
          backgroundColor: brutalSky,
          onPressed: () => context.go('/technician/earnings'),
        ),
      ],
      child: BrutalistScrollView(
        children: [
          _OverviewCard(
            user: user,
            pendingCount: pendingJobs.length,
            activeCount: activeJobs.length,
            completedCount: completedJobs.length,
            earnings: totalEarnings,
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              BrutalistActionButton(
                label: 'Profile settings',
                backgroundColor: brutalPink,
                onPressed: () => context.go('/technician/profile'),
              ),
              BrutalistActionButton(
                label: 'Refresh jobs',
                backgroundColor: brutalAccent,
                onPressed: () => context.read<BookingProvider>().refreshBookings(),
              ),
            ],
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 900;
              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _SectionPanel(
                        title: 'Job requests',
                        subtitle: 'New jobs waiting for a technician to accept them.',
                        child: _BookingsList(
                          bookings: pendingJobs,
                          emptyMessage: 'No new job requests right now.',
                          emptyIcon: Icons.inbox_outlined,
                          bookingBuilder: (booking) => _RequestCard(
                            booking: booking,
                            onAccept: () => _acceptBooking(context, bookingsProvider, booking),
                            onDecline: () => _declineBooking(context, bookingsProvider, booking),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _SectionPanel(
                        title: 'Active jobs',
                        subtitle: 'Accepted jobs currently in progress.',
                        child: _BookingsList(
                          bookings: activeJobs,
                          emptyMessage: 'No active jobs assigned to you yet.',
                          emptyIcon: Icons.work_outline,
                          bookingBuilder: (booking) => _ActiveJobCard(
                            booking: booking,
                            onStart: () => _markInProgress(context, bookingsProvider, booking),
                            onComplete: () => _completeBooking(context, bookingsProvider, booking),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }

              return Column(
                children: [
                  _SectionPanel(
                    title: 'Job requests',
                    subtitle: 'New jobs waiting for a technician to accept them.',
                    child: _BookingsList(
                      bookings: pendingJobs,
                      emptyMessage: 'No new job requests right now.',
                      emptyIcon: Icons.inbox_outlined,
                      bookingBuilder: (booking) => _RequestCard(
                        booking: booking,
                        onAccept: () => _acceptBooking(context, bookingsProvider, booking),
                        onDecline: () => _declineBooking(context, bookingsProvider, booking),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SectionPanel(
                    title: 'Active jobs',
                    subtitle: 'Accepted jobs currently in progress.',
                    child: _BookingsList(
                      bookings: activeJobs,
                      emptyMessage: 'No active jobs assigned to you yet.',
                      emptyIcon: Icons.work_outline,
                      bookingBuilder: (booking) => _ActiveJobCard(
                        booking: booking,
                        onStart: () => _markInProgress(context, bookingsProvider, booking),
                        onComplete: () => _completeBooking(context, bookingsProvider, booking),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  void _acceptBooking(BuildContext context, BookingProvider provider, Booking booking) {
    final user = context.read<AuthProvider>().user;
    provider.updateBooking(
      booking.id,
      <String, dynamic>{
        'status': BookingStatus.accepted,
        'technicianId': user?.id,
        'technicianName': user?.name,
      },
    );
    _showMessage(context, 'Job request accepted.');
  }

  void _declineBooking(BuildContext context, BookingProvider provider, Booking booking) {
    provider.updateBooking(
      booking.id,
      <String, dynamic>{
        'status': BookingStatus.cancelled,
      },
    );
    _showMessage(context, 'Job request declined.');
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
    _showMessage(context, 'Job completed.');
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({
    required this.user,
    required this.pendingCount,
    required this.activeCount,
    required this.completedCount,
    required this.earnings,
  });

  final AppUser? user;
  final int pendingCount;
  final int activeCount;
  final int completedCount;
  final int earnings;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isCompact = screenWidth < 520;

    return BrutalistCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome${user == null ? '' : ', ${user.name}'}',
            style: const TextStyle(
              fontSize: 26,
              height: 1.0,
              fontWeight: FontWeight.w900,
              color: brutalInk,
              letterSpacing: -0.7,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            user == null
                ? 'Track your jobs and earnings from one place.'
                : '${user.location ?? 'Nairobi, Kenya'} • ${user.isAvailable == true ? 'Available' : 'Busy'}',
            style: const TextStyle(
              fontSize: 13,
              height: 1.4,
              fontWeight: FontWeight.w700,
              color: brutalInk,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _StatTile(
                label: 'Requests',
                value: pendingCount.toString(),
                color: brutalAccent,
              ),
              _StatTile(
                label: 'Active',
                value: activeCount.toString(),
                color: brutalMint,
              ),
              _StatTile(
                label: 'Completed',
                value: completedCount.toString(),
                color: brutalSky,
              ),
              _StatTile(
                label: 'Earnings',
                value: _currency(earnings),
                color: brutalPink,
                wide: !isCompact,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionPanel extends StatelessWidget {
  const _SectionPanel({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BrutalistCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BrutalistSectionHeader(
            title: title,
            subtitle: subtitle,
          ),
          child,
        ],
      ),
    );
  }
}

class _BookingsList extends StatelessWidget {
  const _BookingsList({
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
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(emptyIcon, size: 38, color: brutalInk),
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
        for (var index = 0; index < bookings.length; index++) ...[
          bookingBuilder(bookings[index]),
          if (index != bookings.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({
    required this.booking,
    required this.onAccept,
    required this.onDecline,
  });

  final Booking booking;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    return _BookingCard(
      booking: booking,
      footer: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          BrutalistActionButton(
            label: 'Decline',
            backgroundColor: brutalSurface,
            onPressed: onDecline,
          ),
          BrutalistActionButton(
            label: 'Accept',
            backgroundColor: brutalAccent,
            onPressed: onAccept,
          ),
        ],
      ),
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
    return _BookingCard(
      booking: booking,
      footer: Wrap(
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
            label: 'Mark complete',
            backgroundColor: brutalSky,
            onPressed: onComplete,
          ),
        ],
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({
    required this.booking,
    this.footer,
  });

  final Booking booking;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: brutalPaper,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: brutalInk, width: 2.5),
        boxShadow: const [
          BoxShadow(
            color: brutalInk,
            offset: Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
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
                        height: 1.35,
                        fontWeight: FontWeight.w700,
                        color: brutalInk,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              _StatusPill(status: booking.status),
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
            spacing: 10,
            runSpacing: 8,
            children: [
              _MetaChip(icon: Icons.place_outlined, label: booking.location),
              _MetaChip(icon: Icons.calendar_month_outlined, label: booking.preferredDate),
              _MetaChip(icon: Icons.schedule_outlined, label: booking.preferredTime),
              if (booking.price != null) _MetaChip(icon: Icons.payments_outlined, label: _currency(booking.price!)),
            ],
          ),
          if (footer != null) ...[
            const SizedBox(height: 14),
            footer!,
          ],
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.color,
    this.wide = false,
  });

  final String label;
  final String value;
  final Color color;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: wide ? 180 : 150,
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

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final BookingStatus status;

  @override
  Widget build(BuildContext context) {
    final String label = status.label;
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
        label,
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

List<Booking> _pendingJobs(List<Booking> bookings) {
  return bookings.where((booking) => booking.status == BookingStatus.pending).toList(growable: false);
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

int _totalEarnings(List<Booking> bookings) {
  return bookings.fold<int>(0, (sum, booking) => sum + (booking.price ?? 0));
}

String _currency(int value) => '₦${value.toString()}';

void _showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}