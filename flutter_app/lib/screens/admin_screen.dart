import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'shared/brutalist_widgets.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BrutalistPageScaffold(
      title: 'Admin',
      subtitle: 'Jump between the dashboard, bookings, technicians, and settings flows.',
      child: BrutalistScrollView(
        children: [
          const BrutalistCard(
            color: brutalAccent,
            child: Text(
              'This shell stays demo-only but the flows are fully linked so you can move through the admin area on any screen size.',
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                fontWeight: FontWeight.w700,
                color: brutalInk,
              ),
            ),
          ),
          const SizedBox(height: 18),
          const BrutalistSectionHeader(
            title: 'Admin routes',
            subtitle: 'Each button uses the same paths registered in the app router.',
          ),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              BrutalistActionButton(
                label: 'Dashboard',
                onPressed: () => context.go('/admin'),
                backgroundColor: brutalAccent,
              ),
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
            ],
          ),
          const SizedBox(height: 18),
          const _QuickStatsRow(),
        ],
      ),
    );
  }
}

class _QuickStatsRow extends StatelessWidget {
  const _QuickStatsRow();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 650;
        final cards = const [
          _MiniStat(label: 'Today', value: '24'),
          _MiniStat(label: 'Online', value: '18'),
          _MiniStat(label: 'Issues', value: '7'),
        ];

        if (narrow) {
          return Column(
            children: [
              for (var i = 0; i < cards.length; i++) ...[
                cards[i],
                if (i != cards.length - 1) const SizedBox(height: 12),
              ],
            ],
          );
        }

        return Row(
          children: [
            for (var i = 0; i < cards.length; i++) ...[
              Expanded(child: cards[i]),
              if (i != cards.length - 1) const SizedBox(width: 12),
            ],
          ],
        );
      },
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return BrutalistCard(
      color: brutalSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
        ],
      ),
    );
  }
}