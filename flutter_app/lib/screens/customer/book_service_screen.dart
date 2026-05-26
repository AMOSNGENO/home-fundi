import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../state/homefundi_state.dart';
import '../../theme/app_theme.dart';

class BookServiceScreen extends StatefulWidget {
  const BookServiceScreen({
    super.key,
    this.category,
  });

  final String? category;

  @override
  State<BookServiceScreen> createState() => _BookServiceScreenState();
}

class _BookServiceScreenState extends State<BookServiceScreen> {
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _problemController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  String _urgency = 'normal';
  bool _submitting = false;

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _problemController.dispose();
    _addressController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final state = context.read<HomefundiState>();
    final notes = _problemController.text.trim();
    final address = _addressController.text.trim();

    if (notes.isEmpty || address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Add the service address and problem description.')),
      );
      return;
    }

    setState(() => _submitting = true);

    try {
      final category = widget.category ?? 'home repair';
      final booking = await state.bookService(<String, dynamic>{
        'category': category,
        'service_name': category,
        'brand': _brandController.text.trim(),
        'model': _modelController.text.trim(),
        'notes': notes,
        'address': address,
        'preferredDate': _dateController.text.trim(),
        'preferredTime': _timeController.text.trim(),
        'urgency': _urgency,
        'amount': _urgency == 'urgent' ? 12000 : 8500,
        'currency': 'TZS',
      });

      if (!mounted) return;
      if (booking == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(state.errorMessage ?? 'Could not create booking.')),
        );
        return;
      }
      context.go('/payment/${booking.id}');
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<HomefundiState>();
    final category = widget.category ?? 'home repair';
    final recommended =
        state.filteredServices.isNotEmpty ? state.filteredServices.first : null;

    return Scaffold(
      backgroundColor: AppTheme.canvas,
      appBar: AppBar(
        title: const Text('Book service'),
        backgroundColor: AppTheme.canvas,
        foregroundColor: AppTheme.ink,
        elevation: 0,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth =
                constraints.maxWidth >= 720 ? 680.0 : double.infinity;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _Panel(
                          title: 'Selected category',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                category.toUpperCase(),
                                style: const TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.w900),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Book a repair request and we will prepare the estimate, chat, and payment flow.',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              if (recommended != null) ...[
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppTheme.canvas,
                                    border: Border.all(
                                        color: AppTheme.ink, width: 1.5),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        recommended.title?.toUpperCase() ??
                                            'RECOMMENDED SERVICE',
                                        style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w900),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        recommended.description ?? '',
                                        style: const TextStyle(
                                            fontSize: 14, height: 1.35),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${recommended.currency ?? 'TZS'} ${recommended.price?.toStringAsFixed(0) ?? '0'}',
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _Panel(
                          title: 'Booking details',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _Field(
                                controller: _brandController,
                                label: 'Brand',
                                hintText: 'e.g. Samsung, LG, Hisense',
                              ),
                              const SizedBox(height: 12),
                              _Field(
                                controller: _modelController,
                                label: 'Model',
                                hintText: 'e.g. Galaxy S21, RT267',
                              ),
                              const SizedBox(height: 12),
                              _Field(
                                controller: _addressController,
                                label: 'Service address',
                                hintText: 'Street address, city, suburb',
                              ),
                              const SizedBox(height: 12),
                              if (constraints.maxWidth < 420) ...[
                                _Field(
                                  controller: _dateController,
                                  label: 'Preferred date',
                                  hintText: 'DD/MM/YYYY',
                                ),
                                const SizedBox(height: 12),
                                _Field(
                                  controller: _timeController,
                                  label: 'Preferred time',
                                  hintText: '09:00 AM',
                                ),
                              ] else
                                Row(
                                  children: [
                                    Expanded(
                                      child: _Field(
                                        controller: _dateController,
                                        label: 'Preferred date',
                                        hintText: 'DD/MM/YYYY',
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _Field(
                                        controller: _timeController,
                                        label: 'Preferred time',
                                        hintText: '09:00 AM',
                                      ),
                                    ),
                                  ],
                                ),
                              const SizedBox(height: 12),
                              _Field(
                                controller: _problemController,
                                label: 'Problem description',
                                hintText:
                                    'Describe the issue or special instructions',
                                maxLines: 4,
                              ),
                              const SizedBox(height: 12),
                              _DropdownField(
                                label: 'Urgency',
                                value: _urgency,
                                items: const [
                                  DropdownMenuItem(
                                      value: 'low', child: Text('Low')),
                                  DropdownMenuItem(
                                      value: 'normal', child: Text('Normal')),
                                  DropdownMenuItem(
                                      value: 'urgent', child: Text('Urgent')),
                                ],
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() => _urgency = value);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        const _Panel(
                          title: 'What happens next',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _Bullet(
                                  text:
                                      'We create a booking and review the request.'),
                              _Bullet(
                                  text:
                                      'You will see the payment and tracking steps next.'),
                              _Bullet(
                                  text:
                                      'The technician can message you once assigned.'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _submitting ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.ink,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(_submitting
                              ? 'CREATING BOOKING...'
                              : 'CONTINUE TO PAYMENT'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppTheme.ink, width: 2),
        boxShadow: const [
          BoxShadow(color: AppTheme.leaf, offset: Offset(4, 4), blurRadius: 0),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1.2),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    required this.hintText,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final String hintText;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hintText,
            border: const OutlineInputBorder(),
            isDense: true,
            filled: true,
            fillColor: AppTheme.canvas,
          ),
        ),
      ],
    );
  }
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: value,
          items: items,
          onChanged: onChanged,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            isDense: true,
            filled: true,
            fillColor: AppTheme.canvas,
          ),
        ),
      ],
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  ', style: TextStyle(fontSize: 20, height: 1)),
          Expanded(
              child: Text(text,
                  style: const TextStyle(fontSize: 14, height: 1.35))),
        ],
      ),
    );
  }
}
