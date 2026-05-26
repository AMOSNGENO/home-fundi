import 'package:flutter/material.dart';

import '../../state/homefundi_state.dart';
import '../shared/brutalist_widgets.dart';

class AdminTechniciansScreen extends StatefulWidget {
  const AdminTechniciansScreen({super.key});

  @override
  State<AdminTechniciansScreen> createState() => _AdminTechniciansScreenState();
}

class _AdminTechniciansScreenState extends State<AdminTechniciansScreen> {
  String _filter = 'all';
  late final Map<String, bool> _verifiedById;
  late final Map<String, bool> _suspendedById;

  @override
  void initState() {
    super.initState();
    _verifiedById = <String, bool>{
      for (final technician in mockTechnicians) technician.id: technician.isAvailable,
    };
    _suspendedById = <String, bool>{
      for (final technician in mockTechnicians) technician.id: false,
    };
  }

  @override
  Widget build(BuildContext context) {
    final technicians = mockTechnicians;
    final filtered = technicians.where((technician) {
      final verified = _isVerified(technician.id);
      final suspended = _isSuspended(technician.id);

      switch (_filter) {
        case 'verified':
          return verified && !suspended;
        case 'pending':
          return !verified && !suspended;
        case 'suspended':
          return suspended;
        default:
          return true;
      }
    }).toList(growable: false);

    final stats = _TechnicianStats.fromTechnicians(
      technicians,
      isVerified: _isVerified,
      isSuspended: _isSuspended,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Technician management'),
      ),
      body: BrutalistScrollView(
        children: [
          const BrutalistCard(
            color: brutalAccent,
            child: Text(
              'Verify trusted technicians, suspend accounts that need review, and keep the marketplace clean.',
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
                  _MetricCard(label: 'Total', value: stats.total.toString(), detail: 'All technicians'),
                  _MetricCard(label: 'Verified', value: stats.verified.toString(), detail: 'Approved to accept jobs'),
                  _MetricCard(label: 'Pending', value: stats.pending.toString(), detail: 'Needs review'),
                  _MetricCard(label: 'Suspended', value: stats.suspended.toString(), detail: 'Temporarily blocked'),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          const BrutalistSectionHeader(
            title: 'Filters',
            subtitle: 'Narrow the team down by current review status.',
          ),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              BrutalistChip(
                label: 'All',
                selected: _filter == 'all',
                color: brutalAccent,
                onTap: () => setState(() => _filter = 'all'),
              ),
              BrutalistChip(
                label: 'Verified',
                selected: _filter == 'verified',
                color: brutalMint,
                onTap: () => setState(() => _filter = 'verified'),
              ),
              BrutalistChip(
                label: 'Pending',
                selected: _filter == 'pending',
                color: brutalSky,
                onTap: () => setState(() => _filter = 'pending'),
              ),
              BrutalistChip(
                label: 'Suspended',
                selected: _filter == 'suspended',
                color: brutalPink,
                onTap: () => setState(() => _filter = 'suspended'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const BrutalistSectionHeader(
            title: 'Technician roster',
            subtitle: 'Tap an action to verify or suspend a technician.',
          ),
          ...filtered.map(
            (technician) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _TechnicianCard(
                technician: technician,
                verified: _isVerified(technician.id),
                suspended: _isSuspended(technician.id),
                onVerify: () => _setVerified(technician.id, true),
                onSuspend: () => _setSuspended(technician.id, true),
                onReinstate: () => _setSuspended(technician.id, false),
              ),
            ),
          ),
          if (filtered.isEmpty)
            const BrutalistCard(
              child: Text(
                'No technicians match the selected filter.',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  fontWeight: FontWeight.w700,
                  color: brutalInk,
                ),
              ),
            ),
        ],
      ),
    );
  }

  bool _isVerified(String id) => _verifiedById[id] ?? false;

  bool _isSuspended(String id) => _suspendedById[id] ?? false;

  void _setVerified(String id, bool value) {
    setState(() {
      _verifiedById[id] = value;
      if (value) {
        _suspendedById[id] = false;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(value ? 'Technician verified' : 'Technician moved to pending')),
    );
  }

  void _setSuspended(String id, bool value) {
    setState(() {
      _suspendedById[id] = value;
      if (value) {
        _verifiedById[id] = false;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(value ? 'Technician suspended' : 'Technician reinstated')),
    );
  }
}

class _TechnicianCard extends StatelessWidget {
  const _TechnicianCard({
    required this.technician,
    required this.verified,
    required this.suspended,
    required this.onVerify,
    required this.onSuspend,
    required this.onReinstate,
  });

  final Technician technician;
  final bool verified;
  final bool suspended;
  final VoidCallback onVerify;
  final VoidCallback onSuspend;
  final VoidCallback onReinstate;

  @override
  Widget build(BuildContext context) {
    final statusLabel = suspended
        ? 'Suspended'
        : verified
            ? 'Verified'
            : 'Pending';

    return BrutalistCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                        fontSize: 16,
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
                  ],
                ),
              ),
              _StatusPill(
                label: statusLabel,
                color: suspended
                    ? brutalPink
                    : verified
                        ? brutalMint
                        : brutalAccent,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            technician.phone,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: brutalInk,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${technician.rating.toStringAsFixed(1)} rating • ${technician.jobsCompleted} jobs completed',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: brutalInk,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: technician.specializations
                .map(
                  (skill) => BrutalistChip(
                    label: skill,
                    selected: true,
                    color: brutalSky,
                  ),
                )
                .toList(growable: false),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              if (!verified && !suspended)
                BrutalistActionButton(
                  label: 'Verify',
                  onPressed: onVerify,
                  backgroundColor: brutalMint,
                ),
              if (!suspended)
                BrutalistActionButton(
                  label: 'Suspend',
                  onPressed: onSuspend,
                  backgroundColor: brutalPink,
                ),
              if (suspended)
                BrutalistActionButton(
                  label: 'Reinstate',
                  onPressed: onReinstate,
                  backgroundColor: brutalAccent,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
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

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.detail,
  });

  final String label;
  final String value;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return BrutalistCard(
      color: brutalSurface,
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
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: brutalInk,
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

class _TechnicianStats {
  const _TechnicianStats({
    required this.total,
    required this.verified,
    required this.pending,
    required this.suspended,
  });

  final int total;
  final int verified;
  final int pending;
  final int suspended;

  factory _TechnicianStats.fromTechnicians(
    List<Technician> technicians, {
    required bool Function(String id) isVerified,
    required bool Function(String id) isSuspended,
  }) {
    var verifiedCount = 0;
    var pendingCount = 0;
    var suspendedCount = 0;

    for (final technician in technicians) {
      final verified = isVerified(technician.id);
      final suspended = isSuspended(technician.id);
      if (suspended) {
        suspendedCount += 1;
      } else if (verified) {
        verifiedCount += 1;
      } else {
        pendingCount += 1;
      }
    }

    return _TechnicianStats(
      total: technicians.length,
      verified: verifiedCount,
      pending: pendingCount,
      suspended: suspendedCount,
    );
  }
}