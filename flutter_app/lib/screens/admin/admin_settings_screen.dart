import 'package:flutter/material.dart';

import '../shared/brutalist_widgets.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  final TextEditingController _platformNameController =
      TextEditingController(text: 'HOMEFUNDI Admin');
  final TextEditingController _supportPhoneController =
      TextEditingController(text: '+254 700 000 000');
  final TextEditingController _commissionController =
      TextEditingController(text: '12');

  bool _acceptBookings = true;
  bool _autoAssignTechnicians = false;
  bool _requireVerification = true;
  bool _maintenanceMode = false;
  bool _allowCustomerChat = true;

  @override
  void dispose() {
    _platformNameController.dispose();
    _supportPhoneController.dispose();
    _commissionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin settings'),
      ),
      body: BrutalistScrollView(
        children: [
          const BrutalistCard(
            color: brutalAccent,
            child: Text(
              'Tune booking rules, support details, and platform controls from one admin panel.',
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                fontWeight: FontWeight.w700,
                color: brutalInk,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const BrutalistSectionHeader(
            title: 'General configuration',
            subtitle: 'Update the platform label and support contact details.',
          ),
          BrutalistCard(
            child: Column(
              children: [
                _LabeledInput(
                  label: 'Platform name',
                  controller: _platformNameController,
                ),
                const SizedBox(height: 12),
                _LabeledInput(
                  label: 'Support phone',
                  controller: _supportPhoneController,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                _LabeledInput(
                  label: 'Commission percentage',
                  controller: _commissionController,
                  keyboardType: TextInputType.number,
                  suffix: '%',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const BrutalistSectionHeader(
            title: 'Operational toggles',
            subtitle: 'Enable or disable the most important admin switches.',
          ),
          BrutalistCard(
            child: Column(
              children: [
                _ToggleRow(
                  title: 'Accept new bookings',
                  subtitle: 'Allow customers to create new requests.',
                  value: _acceptBookings,
                  onChanged: (value) => setState(() => _acceptBookings = value),
                ),
                const Divider(height: 24, color: brutalInk),
                _ToggleRow(
                  title: 'Auto-assign technicians',
                  subtitle: 'Match incoming jobs to the next available technician.',
                  value: _autoAssignTechnicians,
                  onChanged: (value) => setState(() => _autoAssignTechnicians = value),
                ),
                const Divider(height: 24, color: brutalInk),
                _ToggleRow(
                  title: 'Require technician verification',
                  subtitle: 'Keep new technicians pending until they are approved.',
                  value: _requireVerification,
                  onChanged: (value) => setState(() => _requireVerification = value),
                ),
                const Divider(height: 24, color: brutalInk),
                _ToggleRow(
                  title: 'Allow customer chat',
                  subtitle: 'Keep conversations open between customers and technicians.',
                  value: _allowCustomerChat,
                  onChanged: (value) => setState(() => _allowCustomerChat = value),
                ),
                const Divider(height: 24, color: brutalInk),
                _ToggleRow(
                  title: 'Maintenance mode',
                  subtitle: 'Temporarily pause public booking access.',
                  value: _maintenanceMode,
                  onChanged: (value) => setState(() => _maintenanceMode = value),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const BrutalistSectionHeader(
            title: 'Actions',
            subtitle: 'Save your settings or reset the current draft values.',
          ),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              BrutalistActionButton(
                label: 'Save settings',
                onPressed: _saveSettings,
                backgroundColor: brutalMint,
              ),
              BrutalistActionButton(
                label: 'Reset',
                onPressed: _resetSettings,
                backgroundColor: brutalPink,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _saveSettings() {
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Admin settings saved')),
    );
  }

  void _resetSettings() {
    setState(() {
      _platformNameController.text = 'HOMEFUNDI Admin';
      _supportPhoneController.text = '+254 700 000 000';
      _commissionController.text = '12';
      _acceptBookings = true;
      _autoAssignTechnicians = false;
      _requireVerification = true;
      _maintenanceMode = false;
      _allowCustomerChat = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Admin settings reset')),
    );
  }
}

class _LabeledInput extends StatelessWidget {
  const _LabeledInput({
    required this.label,
    required this.controller,
    this.keyboardType,
    this.suffix,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: brutalInk,
            letterSpacing: 0.7,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            suffixText: suffix,
            filled: true,
            fillColor: brutalSurface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: brutalInk, width: 2.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: brutalInk, width: 2.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: brutalInk, width: 3),
            ),
          ),
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: brutalInk,
          ),
        ),
      ],
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: brutalInk,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
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
        const SizedBox(width: 12),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: brutalInk,
          activeTrackColor: brutalMint,
          inactiveTrackColor: brutalSurface,
        ),
      ],
    );
  }
}