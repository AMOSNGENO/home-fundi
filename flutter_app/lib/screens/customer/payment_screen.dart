import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../state/homefundi_state.dart';
import '../../theme/app_theme.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({
    super.key,
    this.bookingId,
    this.amountLabel = 'R 850.00',
  });

  final String? bookingId;
  final String amountLabel;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final TextEditingController _cardHolderController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  bool _rememberCard = true;
  bool _submitting = false;

  @override
  void dispose() {
    _cardHolderController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  double _amountForBooking(HomefundiState state) {
    final booking =
        widget.bookingId == null ? null : state.bookingById(widget.bookingId!);
    return booking?.amount ?? 850.0;
  }

  Future<void> _payNow() async {
    final state = context.read<HomefundiState>();
    setState(() => _submitting = true);

    try {
      final bookingId = widget.bookingId;
      if (bookingId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Choose a booking before paying.')),
        );
        return;
      }
      final amount = _amountForBooking(state);
      final payment = await state.createPayment(<String, dynamic>{
        'booking_id': bookingId,
        'method': 'card',
        'amount': amount,
        'currency': 'TZS',
        'reference': 'HF-$bookingId',
        'status': 'pending',
      });

      if (!mounted) return;

      if (payment == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(state.errorMessage ?? 'Payment could not be created.')),
        );
        return;
      }

      await state.verifyPayment(payment.id);
      if (!mounted) return;

      context.go('/tracking/$bookingId');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Payment captured. Continue to tracking.')),
      );
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<HomefundiState>();
    final booking =
        widget.bookingId == null ? null : state.bookingById(widget.bookingId!);
    final amount = booking?.amount ?? 850.0;
    final bookingTitle =
        booking?.serviceName ?? booking?.serviceId ?? 'Booking';

    return Scaffold(
      backgroundColor: AppTheme.canvas,
      appBar: AppBar(
        title: const Text('Payment'),
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
                          title: 'Amount due',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'TZS ${amount.toStringAsFixed(0)}',
                                style: const TextStyle(
                                    fontSize: 30, fontWeight: FontWeight.w900),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Review the estimate for $bookingTitle, then continue to confirm your booking and payment.',
                                style:
                                    const TextStyle(fontSize: 14, height: 1.35),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _Panel(
                          title: 'Payment details',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _InputField(
                                controller: _cardHolderController,
                                label: 'Card holder',
                                hintText: 'Your name',
                              ),
                              const SizedBox(height: 12),
                              _InputField(
                                controller: _cardNumberController,
                                label: 'Card number',
                                hintText: '4242 4242 4242 4242',
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _InputField(
                                      controller: _expiryController,
                                      label: 'Expiry',
                                      hintText: '12/28',
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _InputField(
                                      controller: _cvvController,
                                      label: 'CVV',
                                      hintText: '123',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              CheckboxListTile(
                                contentPadding: EdgeInsets.zero,
                                value: _rememberCard,
                                onChanged: (value) => setState(
                                    () => _rememberCard = value ?? false),
                                title: const Text('Remember this card'),
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _Panel(
                          title: 'Summary',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _SummaryRow(
                                label: 'Service fee',
                                value:
                                    'TZS ${((amount - 200).clamp(0.0, amount)).toStringAsFixed(0)}',
                              ),
                              const SizedBox(height: 8),
                              const _SummaryRow(
                                  label: 'Call-out', value: 'TZS 200'),
                              const SizedBox(height: 8),
                              const Divider(color: AppTheme.ink, thickness: 2),
                              const SizedBox(height: 8),
                              _SummaryRow(
                                  label: 'Total',
                                  value: 'TZS ${amount.toStringAsFixed(0)}'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _submitting ? null : _payNow,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.ink,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child:
                              Text(_submitting ? 'PROCESSING...' : 'PAY NOW'),
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

class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    required this.label,
    required this.hintText,
  });

  final TextEditingController controller;
  final String label;
  final String hintText;

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

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
            child: Text(label,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600))),
        Text(value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
      ],
    );
  }
}
