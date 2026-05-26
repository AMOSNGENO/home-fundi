import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/homefundi_state.dart';
import '../shared/brutalist_widgets.dart';

class AdminBookingsScreen extends StatefulWidget {
  const AdminBookingsScreen({super.key});

  @override
  State<AdminBookingsScreen> createState() => _AdminBookingsScreenState();
}

class _AdminBookingsScreenState extends State<AdminBookingsScreen> {
  BookingStatus? _filter;

  @override
  Widget build(BuildContext context) {
    final bookingProvider = context.watch<BookingProvider>();
    final bookings = bookingProvider.bookings;

    final visibleBookings = bookings.where((booking) {
      if (_filter == null) {
        return true;
      }
      return booking.status == _filter;
    }).toList(growable: false);

    final stats = _BookingStats.fromBookings(bookings);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking management'),
      ),
      body: BrutalistScrollView(
        children: [
          const BrutalistCard(
            color: brutalAccent,
            child: Text(
              'Review incoming jobs, update their status, and keep the service queue moving.',
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                fontWeight: FontWeight.w700,
                color: brutalInk,
              ),
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 900 ? 4 : 2;
              return GridView.count(
                crossAxisCount: columns,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.35,
                children: [
                  _MetricCard(label: 'Total', value: stats.total.toString(), detail: 'All bookings', color: brutalSurface),
                  _MetricCard(label: 'Pending', value: stats.pending.toString(), detail: 'Waiting review', color: brutalSky),
                  _MetricCard(label: 'Active', value: stats.active.toString(), detail: 'Accepted or in progress', color: brutalMint),
                  _MetricCard(label: 'Completed', value: stats.completed.toString(), detail: 'Done and closed', color: brutalPink),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          const BrutalistSectionHeader(
            title: 'Filters',
            subtitle: 'Narrow the queue down by status.',
          ),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              BrutalistChip(
                label: 'All',
                selected: _filter == null,
                color: brutalAccent,
                onTap: () => setState(() => _filter = null),
              ),
              BrutalistChip(
                label: 'Pending',
                selected: _filter == BookingStatus.pending,
                color: brutalSky,
                onTap: () => setState(() => _filter = BookingStatus.pending),
              ),
              BrutalistChip(
                label: 'Accepted',
                selected: _filter == BookingStatus.accepted,
                color: brutalMint,
                onTap: () => setState(() => _filter = BookingStatus.accepted),
              ),
              BrutalistChip(
                label: 'In progress',
                selected: _filter == BookingStatus.inProgress,
                color: brutalPink,
                onTap: () => setState(() => _filter = BookingStatus.inProgress),
              ),
              BrutalistChip(
                label: 'Completed',
                selected: _filter == BookingStatus.completed,
                color: brutalAccent,
                onTap: () => setState(() => _filter = BookingStatus.completed),
              ),
              BrutalistChip(
                label: 'Cancelled',
                selected: _filter == BookingStatus.cancelled,
                color: brutalPink,
                onTap: () => setState(() => _filter = BookingStatus.cancelled),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const BrutalistSectionHeader(
            title: 'Bookings',
            subtitle: 'Use the action buttons to change booking status.',
          ),
          if (visibleBookings.isEmpty)
            const BrutalistCard(
              child: Text(
                'No bookings match the selected filter.',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  fontWeight: FontWeight.w700,
                  color: brutalInk,
                ),
              ),
            )
          else
            ...visibleBookings.map(
              (booking) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _BookingCard(
                  booking: booking,
                  onUpdate: (status) => _updateStatus(context, booking.id, status),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _updateStatus(BuildContext context, String bookingId, BookingStatus status) {
    final provider = context.read<BookingProvider>();
    provider.updateBooking(bookingId, <String, dynamic>{'status': status});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Booking updated to ${status.label.toLowerCase()}')),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({
    required this.booking,
    required this.onUpdate,
  });

  final Booking booking;
  final ValueChanged<BookingStatus> onUpdate;

  @override
  Widget build(BuildContext context) {
    final actions = <Widget>[
      if (booking.status != BookingStatus.accepted)
        BrutalistActionButton(
          label: 'Accept',
          onPressed: () => onUpdate(BookingStatus.accepted),
          backgroundColor: brutalMint,
        ),
      if (booking.status != BookingStatus.inProgress)
        BrutalistActionButton(
          label: 'In progress',
          onPressed: () => onUpdate(BookingStatus.inProgress),
          backgroundColor: brutalSky,
        ),
      if (booking.status != BookingStatus.completed)
        BrutalistActionButton(
          label: 'Complete',
          onPressed: () => onUpdate(BookingStatus.completed),
          backgroundColor: brutalAccent,
        ),
      if (booking.status != BookingStatus.cancelled)
        BrutalistActionButton(
          label: 'Cancel',
          onPressed: () => onUpdate(BookingStatus.cancelled),
          backgroundColor: brutalPink,
        ),
    ];

    return BrutalistCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _StatusBadge(
                label: booking.status.label,
                color: _statusColor(booking.status),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.category,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: brutalInk,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${booking.brand} ${booking.model}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: brutalInk,
                      ),
                    ),
                  ],
                ),
              ),
              if (booking.price != null)
                Text(
                  'R${booking.price}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: brutalInk,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          _InfoRow(label: 'Problem', value: booking.problem),
          const SizedBox(height: 6),
          _InfoRow(label: 'Location', value: booking.location),
          const SizedBox(height: 6),
          _InfoRow(label: 'Schedule', value: '${booking.preferredDate} at ${booking.preferredTime}'),
          const SizedBox(height: 6),
          _InfoRow(label: 'Technician', value: booking.technicianName ?? 'Unassigned'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: actions,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.7,
              color: brutalInk,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              height: 1.35,
              fontWeight: FontWeight.w700,
              color: brutalInk,
            ),
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.detail,
    required this.color,
  });

  final String label;
  final String value;
  final String detail;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return BrutalistCard(
      color: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: brutalInk,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: brutalInk,
              letterSpacing: 0.7,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            detail,
            style: const TextStyle(
              fontSize: 11,
              height: 1.3,
              fontWeight: FontWeight.w700,
              color: brutalInk,
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingStats {
  const _BookingStats({
    required this.total,
    required this.pending,
    required this.active,
    required this.completed,
  });

  final int total;
  final int pending;
  final int active;
  final int completed;

  factory _BookingStats.fromBookings(List<Booking> bookings) {
    var pending = 0;
    var active = 0;
    var completed = 0;

    for (final booking in bookings) {
      switch (booking.status) {
        case BookingStatus.pending:
          pending += 1;
          break;
        case BookingStatus.accepted:
        case BookingStatus.inProgress:
          active += 1;
          break;
        case BookingStatus.completed:
          completed += 1;
          break;
        case BookingStatus.cancelled:
          break;
      }
    }

    return _BookingStats(
      total: bookings.length,
      pending: pending,
      active: active,
      completed: completed,
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: brutalInk, width: 2.5),
        boxShadow: const [
          BoxShadow(
            color: brutalInk,
            offset: Offset(3, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: brutalInk,
        ),
      ),
    );
  }
}

Color _statusColor(BookingStatus status) {
  switch (status) {
    case BookingStatus.pending:
      return brutalAccent;
    case BookingStatus.accepted:
      return brutalSky;
    case BookingStatus.inProgress:
      return brutalMint;
    case BookingStatus.completed:
      return brutalMint;
    case BookingStatus.cancelled:
      return brutalPink;
  }
}