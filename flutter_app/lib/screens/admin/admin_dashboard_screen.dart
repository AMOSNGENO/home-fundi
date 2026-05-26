import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../state/homefundi_state.dart';
import '../shared/brutalist_widgets.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final bookingProvider = context.watch<BookingProvider>();

    final bookings = bookingProvider.bookings;
    final technicians = mockTechnicians;
    final adminName = authProvider.user?.name ?? 'Admin';
    final metrics = _DashboardMetrics.fromData(bookings, technicians);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin dashboard'),
        actions: [
          IconButton(
            tooltip: 'Hub',
            onPressed: () => context.go('/admin/hub'),
            icon: const Icon(Icons.apps_outlined),
          ),
          IconButton(
            tooltip: 'Settings',
            onPressed: () => context.go('/admin/settings'),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: BrutalistScrollView(
        children: [
          BrutalistCard(
            color: brutalAccent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'OPERATIONS OVERVIEW',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Welcome back, $adminName',
                  style: const TextStyle(
                    fontSize: 26,
                    height: 1.0,
                    fontWeight: FontWeight.w900,
                    color: brutalInk,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Monitor bookings, approve technicians, and keep the platform moving from one brutalist control panel.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    fontWeight: FontWeight.w700,
                    color: brutalInk,
                  ),
                ),
              ],
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
                  _MetricCard(
                    label: 'Bookings',
                    value: metrics.totalBookings.toString(),
                    detail: '${metrics.pendingBookings} pending',
                    color: brutalSurface,
                  ),
                  _MetricCard(
                    label: 'Technicians',
                    value: metrics.totalTechnicians.toString(),
                    detail: '${metrics.verifiedTechnicians} verified',
                    color: brutalMint,
                  ),
                  _MetricCard(
                    label: 'Revenue',
                    value: 'R${metrics.completedRevenue.toStringAsFixed(0)}',
                    detail: 'Completed jobs',
                    color: brutalSky,
                  ),
                  _MetricCard(
                    label: 'Alerts',
                    value: metrics.openAlerts.toString(),
                    detail: 'Need attention',
                    color: brutalPink,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          const BrutalistSectionHeader(
            title: 'Quick actions',
            subtitle: 'Move straight into the key admin flows.',
          ),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              BrutalistActionButton(
                label: 'Bookings',
                onPressed: () => context.go('/admin/bookings'),
                backgroundColor: brutalMint,
              ),
              BrutalistActionButton(
                label: 'Technicians',
                onPressed: () => context.go('/admin/technicians'),
                backgroundColor: brutalSky,
              ),
              BrutalistActionButton(
                label: 'Settings',
                onPressed: () => context.go('/admin/settings'),
                backgroundColor: brutalPink,
              ),
              BrutalistActionButton(
                label: 'Hub',
                onPressed: () => context.go('/admin/hub'),
                backgroundColor: brutalAccent,
              ),
            ],
          ),
          const SizedBox(height: 18),
          BrutalistSectionHeader(
            title: 'Recent bookings',
            subtitle: 'The latest requests and their current status.',
            trailing: TextButton(
              onPressed: () => context.go('/admin/bookings'),
              child: const Text('See all'),
            ),
          ),
          ...bookings.take(3).map(
                (booking) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _BookingPreviewCard(booking: booking),
                ),
              ),
          const SizedBox(height: 6),
          BrutalistSectionHeader(
            title: 'Technician snapshot',
            subtitle: 'A quick look at availability and performance.',
            trailing: TextButton(
              onPressed: () => context.go('/admin/technicians'),
              child: const Text('View team'),
            ),
          ),
          ...technicians.take(3).map(
                (technician) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _TechnicianPreviewCard(technician: technician),
                ),
              ),
        ],
      ),
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

class _BookingPreviewCard extends StatelessWidget {
  const _BookingPreviewCard({required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    return BrutalistCard(
      child: Row(
        children: [
          _StatusBadge(label: booking.status.label, color: _statusColor(booking.status)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.category,
                  style: const TextStyle(
                    fontSize: 15,
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
                const SizedBox(height: 4),
                Text(
                  '${booking.location} • ${booking.preferredDate} at ${booking.preferredTime}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: brutalInk,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TechnicianPreviewCard extends StatelessWidget {
  const _TechnicianPreviewCard({required this.technician});

  final Technician technician;

  @override
  Widget build(BuildContext context) {
    return BrutalistCard(
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: brutalInk,
            child: Text(
              technician.name.isNotEmpty ? technician.name[0].toUpperCase() : '?',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  technician.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: brutalInk,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  technician.location,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: brutalInk,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${technician.rating.toStringAsFixed(1)} rating • ${technician.jobsCompleted} jobs',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: brutalInk,
                  ),
                ),
              ],
            ),
          ),
          _StatusBadge(
            label: technician.isAvailable ? 'Available' : 'Busy',
            color: technician.isAvailable ? brutalMint : brutalPink,
          ),
        ],
      ),
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

class _DashboardMetrics {
  const _DashboardMetrics({
    required this.totalBookings,
    required this.pendingBookings,
    required this.totalTechnicians,
    required this.verifiedTechnicians,
    required this.completedRevenue,
    required this.openAlerts,
  });

  final int totalBookings;
  final int pendingBookings;
  final int totalTechnicians;
  final int verifiedTechnicians;
  final double completedRevenue;
  final int openAlerts;

  factory _DashboardMetrics.fromData(List<Booking> bookings, List<Technician> technicians) {
    var pendingBookings = 0;
    var completedRevenue = 0.0;
    var verifiedTechnicians = 0;
    var openAlerts = 0;

    for (final booking in bookings) {
      if (booking.status == BookingStatus.pending) {
        pendingBookings += 1;
      }
      if (booking.status == BookingStatus.completed && booking.price != null) {
        completedRevenue += booking.price!.toDouble();
      }
    }

    for (final technician in technicians) {
      if (technician.isAvailable) {
        verifiedTechnicians += 1;
      } else {
        openAlerts += 1;
      }
    }

    openAlerts += pendingBookings;

    return _DashboardMetrics(
      totalBookings: bookings.length,
      pendingBookings: pendingBookings,
      totalTechnicians: technicians.length,
      verifiedTechnicians: verifiedTechnicians,
      completedRevenue: completedRevenue,
      openAlerts: openAlerts,
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