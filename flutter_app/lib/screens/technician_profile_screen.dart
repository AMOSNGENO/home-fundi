import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/homefundi_state.dart';
import 'shared/brutalist_widgets.dart';

class TechnicianProfileScreen extends StatefulWidget {
  const TechnicianProfileScreen({super.key});

  @override
  State<TechnicianProfileScreen> createState() => _TechnicianProfileScreenState();
}

class _TechnicianProfileScreenState extends State<TechnicianProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  bool _isAvailable = true;
  bool _isSaving = false;
  String? _loadedUserId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncFromUser(context.read<AuthProvider>().user);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isWide = screenWidth >= 900;

    return BrutalistPageScaffold(
      title: 'Technician Profile',
      subtitle: 'Update your contact details, availability, and public technician info.',
      child: BrutalistScrollView(
        children: [
          _ProfileHeader(user: user),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final wideLayout = isWide && constraints.maxWidth >= 900;
              final formCard = _ProfileFormCard(
                formKey: _formKey,
                nameController: _nameController,
                phoneController: _phoneController,
                locationController: _locationController,
                isAvailable: _isAvailable,
                isSaving: _isSaving,
                onAvailabilityChanged: (value) => setState(() => _isAvailable = value),
                onSave: user == null ? null : () => _saveProfile(context),
              );
              final summaryCard = _ProfileSummaryCard(user: user);

              if (wideLayout) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: formCard),
                    const SizedBox(width: 16),
                    Expanded(child: summaryCard),
                  ],
                );
              }

              return Column(
                children: [
                  formCard,
                  const SizedBox(height: 16),
                  summaryCard,
                ],
              );
            },
          ),
          const SizedBox(height: 18),
          const BrutalistSectionHeader(
            title: 'Profile tips',
            subtitle: 'Use the form to keep the dashboard and customer-facing details accurate.',
          ),
          const BrutalistCard(
            child: Text(
              'Availability affects whether you appear as online for new assignments. Keep your phone and location current so dispatch and customers can reach you quickly.',
              style: TextStyle(
                fontSize: 13,
                height: 1.45,
                fontWeight: FontWeight.w700,
                color: brutalInk,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _syncFromUser(AppUser? user) {
    final currentUserId = user?.id;
    if (_loadedUserId == currentUserId) {
      return;
    }

    _loadedUserId = currentUserId;
    _nameController.text = user?.name ?? '';
    _phoneController.text = user?.phone ?? '';
    _locationController.text = user?.location ?? '';
    _isAvailable = user?.isAvailable ?? true;
  }

  Future<void> _saveProfile(BuildContext context) async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final auth = context.read<AuthProvider>();
    final user = auth.user;
    if (user == null) {
      _showMessage(context, 'Please sign in before updating the profile.');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await auth.updateUser(
        <String, dynamic>{
          'name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'location': _locationController.text.trim(),
          'isAvailable': _isAvailable,
        },
      );

      if (!mounted) {
        return;
      }

      _showMessage(context, 'Profile updated successfully.');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user});

  final AppUser? user;

  @override
  Widget build(BuildContext context) {
    final initials = _initials(user?.name ?? 'Technician');
    final location = user?.location?.isNotEmpty == true ? user!.location! : 'Add your preferred service area';
    final availability = user?.isAvailable == true ? 'Available for bookings' : 'Offline / busy';

    return BrutalistCard(
      color: brutalAccent,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 74,
            height: 74,
            decoration: BoxDecoration(
              color: brutalSurface,
              shape: BoxShape.circle,
              border: Border.all(color: brutalInk, width: 3),
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
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
                Text(
                  user?.name ?? 'Technician profile',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: brutalInk,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  location,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                    color: brutalInk,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  availability,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.35,
                    fontWeight: FontWeight.w800,
                    color: brutalInk,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _Badge(label: user?.rating == null ? 'Rating N/A' : '${user!.rating!.toStringAsFixed(1)} rating'),
                    _Badge(label: '${user?.jobsCompleted ?? 0} jobs completed'),
                    _Badge(label: _walletLabel(user)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileFormCard extends StatelessWidget {
  const _ProfileFormCard({
    required this.formKey,
    required this.nameController,
    required this.phoneController,
    required this.locationController,
    required this.isAvailable,
    required this.isSaving,
    required this.onAvailabilityChanged,
    required this.onSave,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController locationController;
  final bool isAvailable;
  final bool isSaving;
  final ValueChanged<bool> onAvailabilityChanged;
  final VoidCallback? onSave;

  @override
  Widget build(BuildContext context) {
    return BrutalistCard(
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BrutalistSectionHeader(
              title: 'Edit details',
              subtitle: 'Keep the visible profile fields accurate for customers and dispatch.',
            ),
            _Field(
              controller: nameController,
              label: 'Full name',
              hint: 'Enter your display name',
              icon: Icons.person_outline,
              validator: (value) => value == null || value.trim().isEmpty ? 'Name is required' : null,
            ),
            const SizedBox(height: 12),
            _Field(
              controller: phoneController,
              label: 'Phone number',
              hint: 'Enter your phone number',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (value) => value == null || value.trim().isEmpty ? 'Phone number is required' : null,
            ),
            const SizedBox(height: 12),
            _Field(
              controller: locationController,
              label: 'Service area',
              hint: 'e.g. Westlands, Nairobi',
              icon: Icons.place_outlined,
              validator: (value) => value == null || value.trim().isEmpty ? 'Service area is required' : null,
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: brutalSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: brutalInk, width: 2.5),
              ),
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Available for new jobs',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: brutalInk,
                  ),
                ),
                subtitle: const Text(
                  'Turn this on when you are ready to receive fresh requests.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                    color: brutalInk,
                  ),
                ),
                value: isAvailable,
                onChanged: onAvailabilityChanged,
                activeColor: brutalInk,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                BrutalistActionButton(
                  label: isSaving ? 'Saving...' : 'Save profile',
                  backgroundColor: brutalMint,
                  onPressed: onSave ?? () => _showMessage(
                    context,
                    'Please sign in before saving changes.',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileSummaryCard extends StatelessWidget {
  const _ProfileSummaryCard({required this.user});

  final AppUser? user;

  @override
  Widget build(BuildContext context) {
    return BrutalistCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BrutalistSectionHeader(
            title: 'Account summary',
            subtitle: 'A quick look at the values that drive your technician dashboard.',
          ),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _StatCard(
                label: 'Rating',
                value: user?.rating == null ? 'N/A' : user!.rating!.toStringAsFixed(1),
                color: brutalSky,
              ),
              _StatCard(
                label: 'Jobs completed',
                value: (user?.jobsCompleted ?? 0).toString(),
                color: brutalMint,
              ),
              _StatCard(
                label: 'Wallet balance',
                value: _walletValue(user),
                color: brutalPink,
              ),
              _StatCard(
                label: 'Availability',
                value: user?.isAvailable == true ? 'Online' : 'Offline',
                color: brutalAccent,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Your profile data is shared across the technician dashboard so job counts, earnings, and availability stay in sync.',
            style: TextStyle(
              fontSize: 13,
              height: 1.45,
              fontWeight: FontWeight.w700,
              color: brutalInk,
            ),
          ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.validator,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final String? Function(String? value) validator;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: brutalInk,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: brutalInk),
        filled: true,
        fillColor: brutalSurface,
        enabledBorder: _border(),
        focusedBorder: _border(width: 3),
        errorBorder: _border(color: Colors.red.shade700),
        focusedErrorBorder: _border(color: Colors.red.shade700, width: 3),
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w800,
          color: brutalInk,
        ),
        hintStyle: TextStyle(
          color: brutalInk.withOpacity(0.6),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  OutlineInputBorder _border({Color color = brutalInk, double width = 2.5}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
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
      width: 150,
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

class _Badge extends StatelessWidget {
  const _Badge({required this.label});

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

String _initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((part) => part.isNotEmpty).toList();
  if (parts.isEmpty) {
    return 'T';
  }
  if (parts.length == 1) {
    final value = parts.first;
    return value.length >= 2 ? value.substring(0, 2).toUpperCase() : value.toUpperCase();
  }
  final first = parts.first;
  final last = parts.last;
  final firstInitial = first.isNotEmpty ? first.substring(0, 1) : 'T';
  final lastInitial = last.isNotEmpty ? last.substring(0, 1) : 'T';
  return (firstInitial + lastInitial).toUpperCase();
}

String _walletLabel(AppUser? user) {
  final wallet = user?.wallet;
  if (wallet == null) {
    return 'Wallet N/A';
  }
  return '₦$wallet';
}

String _walletValue(AppUser? user) {
  final wallet = user?.wallet;
  if (wallet == null) {
    return 'N/A';
  }
  return '₦$wallet';
}

void _showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}