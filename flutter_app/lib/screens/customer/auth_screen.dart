import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../state/homefundi_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/brand_mark.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _registerMode = false;
  bool _submitting = false;
  String? _message;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final state = context.read<HomefundiState>();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty ||
        password.isEmpty ||
        (_registerMode && _nameController.text.trim().isEmpty)) {
      setState(() => _message = 'Fill in the required fields.');
      return;
    }

    setState(() {
      _submitting = true;
      _message = null;
    });

    try {
      final session = _registerMode
          ? await state.register(<String, dynamic>{
              'name': _nameController.text.trim(),
              'email': email,
              'phone': _phoneController.text.trim(),
              'password': password,
              'password_confirmation': password,
              'role': 'customer',
            })
          : await state.login(email: email, password: password);

      if (!mounted) return;
      if (session == null || session.accessToken.isEmpty) {
        setState(
            () => _message = state.errorMessage ?? 'Authentication failed.');
        return;
      }

      context.go('/tabs/home');
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.canvas,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppTheme.paper,
                  border: Border.all(color: AppTheme.ink, width: 3),
                  boxShadow: const [
                    BoxShadow(
                        color: AppTheme.ink,
                        offset: Offset(5, 5),
                        blurRadius: 0),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const BrandMark(showWordmark: true),
                      const SizedBox(height: 24),
                      Text(
                        _registerMode
                            ? 'Create your customer account'
                            : 'Log in to book and track repairs',
                        style: const TextStyle(
                          color: AppTheme.ink,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          height: 1.05,
                        ),
                      ),
                      const SizedBox(height: 18),
                      if (_registerMode) ...[
                        _Field(
                            controller: _nameController,
                            label: 'Name',
                            textInputAction: TextInputAction.next),
                        const SizedBox(height: 12),
                        _Field(
                          controller: _phoneController,
                          label: 'Phone',
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 12),
                      ],
                      _Field(
                        controller: _emailController,
                        label: 'Email',
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 12),
                      _Field(
                        controller: _passwordController,
                        label: 'Password',
                        obscureText: true,
                        onSubmitted: (_) => _submit(),
                      ),
                      if (_message != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _message!,
                          style: const TextStyle(
                              color: AppTheme.danger,
                              fontWeight: FontWeight.w800),
                        ),
                      ],
                      const SizedBox(height: 18),
                      ElevatedButton(
                        onPressed: _submitting ? null : _submit,
                        child: Text(_submitting
                            ? 'PLEASE WAIT...'
                            : (_registerMode ? 'CREATE ACCOUNT' : 'LOG IN')),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _submitting
                            ? null
                            : () => setState(() {
                                  _registerMode = !_registerMode;
                                  _message = null;
                                }),
                        child: Text(_registerMode
                            ? 'I ALREADY HAVE AN ACCOUNT'
                            : 'CREATE A NEW ACCOUNT'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(labelText: label),
    );
  }
}
