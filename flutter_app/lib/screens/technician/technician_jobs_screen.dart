import 'package:flutter/material.dart';
import '../shared/brutalist_widgets.dart';

class TechnicianJobsScreen extends StatefulWidget {
  const TechnicianJobsScreen({super.key});

  @override
  State<TechnicianJobsScreen> createState() => _TechnicianJobsScreenState();
}

class _TechnicianJobsScreenState extends State<TechnicianJobsScreen> {
  String _filter = 'Nearby';

  final List<_JobItem> _jobs = const [
    _JobItem(
      title: 'Deep clean at Oak Street',
      distance: '1.2 km',
      payout: '\$82',
      eta: 'Starts in 25 min',
      priority: 'Nearby',
      color: brutalAccent,
    ),
    _JobItem(
      title: 'HVAC check at River Road',
      distance: '2.8 km',
      payout: '\$140',
      eta: 'Starts in 50 min',
      priority: 'High payout',
      color: brutalMint,
    ),
    _JobItem(
      title: 'Repairs at Market Lane',
      distance: '0.8 km',
      payout: '\$65',
      eta: 'Starts in 15 min',
      priority: 'Nearby',
      color: brutalSky,
    ),
    _JobItem(
      title: 'Move-out clean at Bay View',
      distance: '4.5 km',
      payout: '\$175',
      eta: 'Starts tomorrow',
      priority: 'Today',
      color: brutalPink,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _jobs.where((job) => _filter == 'All' || job.priority == _filter).toList();

    return BrutalistPageScaffold(
      title: 'Technician Jobs',
      subtitle: 'Available work, sorted into chunky cards for easy scanning on mobile.',
      child: BrutalistScrollView(
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final option in const ['Nearby', 'High payout', 'Today', 'All'])
                BrutalistChip(
                  label: option,
                  selected: _filter == option,
                  color: option == 'Nearby'
                      ? brutalAccent
                      : option == 'High payout'
                          ? brutalMint
                          : option == 'Today'
                              ? brutalPink
                              : brutalSurface,
                  onTap: () => setState(() => _filter = option),
                ),
            ],
          ),
          const SizedBox(height: 16),
          const BrutalistSectionHeader(
            title: 'Open jobs',
            subtitle: 'Tap accept to simulate a quick claim and keep the flow moving.',
          ),
          if (filtered.isEmpty)
            const BrutalistCard(
              child: Text(
                'No jobs match this filter in the demo view.',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  fontWeight: FontWeight.w700,
                  color: brutalInk,
                ),
              ),
            )
          else
            ...[
              for (var i = 0; i < filtered.length; i++) ...[
                _JobCard(
                  job: filtered[i],
                  onAccept: () => _showDemoSnack(context, 'Accepted ${filtered[i].title}'),
                  onPreview: () => _showDemoSnack(context, 'Previewing ${filtered[i].title}'),
                ),
                if (i != filtered.length - 1) const SizedBox(height: 12),
              ],
            ],
        ],
      ),
    );
  }

  void _showDemoSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: brutalInk),
    );
  }
}

class _JobItem {
  const _JobItem({
    required this.title,
    required this.distance,
    required this.payout,
    required this.eta,
    required this.priority,
    required this.color,
  });

  final String title;
  final String distance;
  final String payout;
  final String eta;
  final String priority;
  final Color color;
}

class _JobCard extends StatelessWidget {
  const _JobCard({
    required this.job,
    required this.onAccept,
    required this.onPreview,
  });

  final _JobItem job;
  final VoidCallback onAccept;
  final VoidCallback onPreview;

  @override
  Widget build(BuildContext context) {
    return BrutalistCard(
      color: job.color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            job.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: brutalInk,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _InfoBox(label: 'Distance', value: job.distance),
              _InfoBox(label: 'Payout', value: job.payout),
              _InfoBox(label: 'ETA', value: job.eta),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              BrutalistChip(label: job.priority, selected: true, color: brutalSurface),
              const Spacer(),
              Flexible(
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.end,
                  children: [
                    BrutalistActionButton(
                      label: 'Preview',
                      onPressed: onPreview,
                      backgroundColor: brutalSurface,
                    ),
                    BrutalistActionButton(
                      label: 'Accept',
                      onPressed: onAccept,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  const _InfoBox({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: brutalSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: brutalInk, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: brutalInk,
            ),
          ),
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