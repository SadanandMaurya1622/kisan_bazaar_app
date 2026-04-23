import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/app_user.dart';
import '../../providers/app_providers.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  String _role = 'buyer';
  bool _loading = false;
  static const _demoBuyerEmail = 'buyer@agroconnect.local';
  static const _demoSellerEmail = 'seller@agroconnect.local';
  static const _demoPassword = '123456';

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final auth = ref.read(authServiceProvider);
      final email = _role == 'seller' ? _demoSellerEmail : _demoBuyerEmail;
      try {
        await auth.signIn(email: email, password: _demoPassword);
      } catch (_) {
        final credential = await auth.signUp(
          email: email,
          password: _demoPassword,
        );
        await ref.read(firestoreServiceProvider).saveUser(
              AppUser(uid: credential.user!.uid, email: email, role: _role),
            );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _googleLogin() async {
    setState(() => _loading = true);
    try {
      final auth = ref.read(authServiceProvider);
      final credential = await auth.signInWithGoogle();
      final user = credential.user;
      if (user != null) {
        final firestore = ref.read(firestoreServiceProvider);
        final existing = await firestore.getUserById(user.uid);
        await firestore.saveUser(
          AppUser(
            uid: user.uid,
            email: user.email ?? _demoBuyerEmail,
            // Keep existing role for returning Google users.
            role: existing?.role ?? _role,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      String message = 'Google login failed. Please try again.';
      final raw = e.toString();
      if (raw.contains('10') || raw.contains('DEVELOPER_ERROR')) {
        message = 'Google sign-in config issue: add SHA key in Firebase, enable Google auth, then download latest google-services.json.';
      } else if (raw.contains('google-sign-in-cancelled')) {
        message = 'Google sign-in cancelled.';
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Agro Connect', style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _emailCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        hintText: 'Ignored in hardcoded mode',
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _passwordCtrl,
                      decoration: const InputDecoration(labelText: 'Password'),
                      obscureText: true,
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _role,
                      decoration: const InputDecoration(labelText: 'Role'),
                      items: const [
                        DropdownMenuItem(value: 'buyer', child: Text('Buyer')),
                        DropdownMenuItem(value: 'seller', child: Text('Seller (Farmer)')),
                      ],
                      onChanged: (v) => setState(() => _role = v ?? 'buyer'),
                    ),
                    const SizedBox(height: 18),
                    FilledButton(
                      onPressed: _loading ? null : _submit,
                      child: _loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Continue (Hardcoded Demo)'),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: _loading ? null : _googleLogin,
                      icon: const Icon(Icons.login),
                      label: const Text('Login with Google'),
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
