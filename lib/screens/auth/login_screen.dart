import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_ext.dart';
import '../../core/utils/error_messages.dart';
import '../../providers/app_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref.read(authRepositoryProvider).signIn(
        email: _email.text,
        password: _password.text,
      );
      if (!mounted) return;
      context.go('/home');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(friendlyError(e))),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.brand,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: borderColor, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: borderColor,
                          offset: const Offset(6, 6),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.pets_rounded, color: Colors.white, size: 34),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('SAKU', style: context.texts.headlineSmall?.copyWith(fontWeight: FontWeight.w900, letterSpacing: 4)),
                      Text('CATATAN KEUANGAN', style: context.texts.labelSmall?.copyWith(fontWeight: FontWeight.w900, letterSpacing: 2)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: borderColor, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: borderColor,
                      offset: const Offset(8, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.cruelty_free_rounded, size: 26),
                        const SizedBox(width: 10),
                        Text('MEONG & GUK', style: context.texts.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Masuk biar kucing & anjing puddel bisa diajak ngatur duit!',
                      style: context.texts.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 26),
              Text('LOGIN', style: context.texts.headlineSmall?.copyWith(fontWeight: FontWeight.w900, letterSpacing: 6)),
              const SizedBox(height: 16),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: borderColor,
                            offset: const Offset(6, 6),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'EMAIL',
                          hintText: 'nama@email.com',
                          prefixIcon: Icon(Icons.mail_outline_rounded),
                        ),
                        validator: (v) {
                          final value = v?.trim() ?? '';
                          if (value.isEmpty) return 'Email wajib diisi';
                          if (!value.contains('@')) return 'Format email tidak valid';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: borderColor,
                            offset: const Offset(6, 6),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _password,
                        obscureText: _obscure,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _submit(),
                        decoration: InputDecoration(
                          labelText: 'PASSWORD',
                          hintText: 'Masukkan password',
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          suffixIcon: IconButton(
                            onPressed: () => setState(() => _obscure = !_obscure),
                            icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                          ),
                        ),
                        validator: (v) {
                          if ((v ?? '').isEmpty) return 'Password wajib diisi';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: borderColor,
                      offset: const Offset(8, 8),
                    ),
                  ],
                ),
                child: FilledButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
                        )
                      : const Text('MASUK'),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('BELUM PUNYA AKUN?', style: context.texts.labelMedium?.copyWith(fontWeight: FontWeight.w900)),
                  TextButton(
                    onPressed: () => context.go('/register'),
                    child: const Text('DAFTAR'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
