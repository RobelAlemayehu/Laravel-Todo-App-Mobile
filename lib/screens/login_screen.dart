import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers.dart';
import '../services/api.dart';
import '../theme/app_colors.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';
import '../widgets/logo_mark.dart';
import '../widgets/app_toast.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final bool showLogoutMessage;
  const LoginScreen({super.key, this.showLogoutMessage = false});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  String? _emailError;
  String? _passwordError;
  String? _generalError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.showLogoutMessage && mounted) {
        showAppToast(context, "You've been signed out");
      }
    });
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _clearErrors() {
    _emailError = null;
    _passwordError = null;
    _generalError = null;
  }

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _clearErrors();
    });
    try {
      final api = ref.read(apiProvider);
      await api.login(_email.text.trim(), _password.text);
      ref.invalidate(loggedInProvider);
    } catch (e) {
      final msg = Api.errorMessage(e);
      setState(() {
        if (msg.toLowerCase().contains('email')) {
          _emailError = msg;
        } else if (msg.toLowerCase().contains('password')) {
          _passwordError = msg;
        } else {
          _generalError = msg;
        }
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: appSurface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: appBorder),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x144B2E1E),
                      blurRadius: 20,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo mark
                    Center(child: LogoMark(size: 48)),
                    const SizedBox(height: 20),
                    // Serif heading
                    Center(
                      child: Text(
                        'Welcome back',
                        style: GoogleFonts.fraunces(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: choc900,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Center(
                      child: Text(
                        'Sign in to your chocolate workspace',
                        style: GoogleFonts.inter(fontSize: 14, color: choc500),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Email
                    AppTextField(
                      label: 'Email',
                      controller: _email,
                      hintText: 'you@example.com',
                      errorText: _emailError,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                    ),
                    const SizedBox(height: 16),

                    // Password
                    AppTextField(
                      label: 'Password',
                      controller: _password,
                      hintText: '••••••••',
                      errorText: _passwordError,
                      obscureText: _obscure,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      onSubmitted: (_) => _loading ? null : _submit(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure ? Icons.visibility_off : Icons.visibility,
                          size: 20,
                          color: choc500,
                        ),
                        tooltip: _obscure ? 'Show password' : 'Hide password',
                        onPressed: () =>
                            setState(() => _obscure = !_obscure),
                      ),
                    ),

                    // General error
                    if (_generalError != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: appDangerBg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: appDanger.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline,
                                color: appDanger, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(_generalError!,
                                  style: GoogleFonts.inter(
                                      fontSize: 13, color: appDanger)),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Submit button
                    AppButton(
                      label: 'Sign in',
                      onPressed: _loading ? null : _submit,
                      isLoading: _loading,
                      isFullWidth: true,
                    ),

                    const SizedBox(height: 20),

                    // Hint: register on web
                    Center(
                      child: Text(
                        'No account? Register on the website.',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: choc500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}