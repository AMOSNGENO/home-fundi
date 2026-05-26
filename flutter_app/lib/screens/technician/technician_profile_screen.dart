import 'package:flutter/material.dart';
import '../shared/brutalist_widgets.dart';

class TechnicianProfileScreen extends StatefulWidget {
  const TechnicianProfileScreen({super.key});

  @override
  State<TechnicianProfileScreen> createState() => _TechnicianProfileScreenState();
}

class _TechnicianProfileScreenState extends State<TechnicianProfileScreen> {
  bool _online = true;
  bool _smsAlerts = true;
  bool _nightShifts = false;

  @override
  Widget build(BuildContext context) {
    return BrutalistPageScaffold(
      title: 'Technician Profile',
      subtitle: 'Demo profile screen with availability controls, identity details, and quick status tools.',
      child: BrutalistScrollView(
        children: [
          BrutalistCard(
            color: brutalAccent,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: brutalSurface,
                    shape: BoxShape.circle,
                    border: Border.all(color: brutalInk, width: 3),
                  ),
                  child: const Center(
                    child: Text(
                      'T',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: brutalInk,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tara Miles',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: brutalInk,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Senior field technician • East district',
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.35,
                          fontWeight: FontWeight.w700,
                          color: brutalInk,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: const [
                          _ProfileBadge(label: '4.9 rating'),
                          _ProfileBadge(label: '218 jobs'),
                          _ProfileBadge(label: '3 years'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const BrutalistSectionHeader(
            title: 'Availability',
            subtitle: 'These switches are local-only and intended to mirror the app flow.',
          ),
          BrutalistCard(
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Online status',
                    style: TextStyle(fontWeight: FontWeight.w900, color: brutalInk),
                  ),
                  subtitle: const Text(
                    'Let admins know you are ready for the next job.',
                    style: TextStyle(fontWeight: FontWeight.w700, color: brutalInk),
                  ),
                  value: _online,
                  onChanged: (value) => setState(() => _online = value),
                  activeColor: brutalInk,
                ),
                const Divider(color: brutalInk, thickness: 2),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'SMS alerts',
                    style: TextStyle(fontWeight: FontWeight.w900, color: brutalInk),
                  ),
                  subtitle: const Text(
                    'Receive reminder texts for assignments and changes.',
                    style: TextStyle(fontWeight: FontWeight.w700, color: brutalInk),
                  ),
                  value: _smsAlerts,
                  onChanged: (value) => setState(() => _smsAlerts = value),
                  activeColor: brutalInk,
                ),
                const Divider(color: brutalInk, thickness: 2),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Night shifts',
                    style: TextStyle(fontWeight: FontWeight.w900, color: brutalInk),
                  ),
                  subtitle: const Text(
                    'Make yourself visible for evening bookings.',
                    style: TextStyle(fontWeight: FontWeight.w700, color: brutalInk),
                  ),
                  value: _nightShifts,
                  onChanged: (value) => setState(() => _nightShifts = value),
                  activeColor: brutalInk,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const BrutalistSectionHeader(
            title: 'Contact details',
            subtitle: 'Simple blocks stay readable without needing a wide layout.',
          ),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: const [
              _ContactCard(label: 'Phone', value: '+1 (555) 218-4420', color: brutalMint),
              _ContactCard(label: 'Email', value: 'tara.miles@example.com', color: brutalSky),
              _ContactCard(label: 'Vehicle', value: 'White van • HFM-203', color: brutalPink),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileBadge extends StatelessWidget {
  const _ProfileBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: brutalSurface,
        borderRadius: BorderRadius.circular(14),
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

class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return BrutalistCard(
      color: color,
      child: SizedBox(
        width: 170,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: brutalInk,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
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
    );
  }
}