import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../state/homefundi_state.dart';
import '../../theme/app_theme.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({
    super.key,
    this.bookingId,
  });

  final String? bookingId;

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());
  bool _submitting = false;

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _verify() async {
    final otp = _controllers.map((controller) => controller.text.trim()).join();
    if (otp.length != 4) return;
    final bookingId = widget.bookingId;
    if (bookingId == null) return;

    setState(() => _submitting = true);

    try {
      final updated = await context.read<HomefundiState>().submitOtp(
            bookingId: bookingId,
            otp: otp,
          );

      if (!mounted) return;
      if (updated != null) {
        context.go('/tracking/$bookingId');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP verified successfully.')),
        );
      }
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

    return Scaffold(
      backgroundColor: AppTheme.canvas,
      appBar: AppBar(
        title: const Text('OTP Verification'),
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
                          title: 'Confirm job completion',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                booking == null
                                    ? 'Booking not found'
                                    : 'Booking ${booking.id}',
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w900),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Ask the technician for the one-time code and enter it below to close the booking.',
                                style: TextStyle(fontSize: 14, height: 1.35),
                              ),
                              if (booking?.otpCode != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Expected code: ${booking!.otpCode}',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _Panel(
                          title: 'Enter code',
                          child: Row(
                            children: List.generate(
                              4,
                              (index) => Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      right: index == 3 ? 0 : 8),
                                  child: TextField(
                                    controller: _controllers[index],
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.number,
                                    maxLength: 1,
                                    decoration: const InputDecoration(
                                      counterText: '',
                                      border: OutlineInputBorder(),
                                      filled: true,
                                      fillColor: AppTheme.canvas,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _submitting ? null : _verify,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.ink,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(
                              _submitting ? 'VERIFYING...' : 'VERIFY CODE'),
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
