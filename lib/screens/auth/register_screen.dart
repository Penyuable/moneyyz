import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_ext.dart';
import '../../core/utils/error_messages.dart';
import '../../providers/app_providers.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final res = await ref.read(authRepositoryProvider).signUp(
        name: _name.text,
        email: _email.text,
        password: _password.text,
      );
      if (!mounted) return;
      if (res.session == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Akun berhasil dibuat. Silakan masuk untuk melanjutkan.'),
          ),
        );
        context.go('/login');
        return;
      }
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
      appBar: AppBar(
        leading: IconButton(
          icon: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: borderColor,
                  offset: const Offset(4, 4),
                ),
              ],
            ),
            child: const Icon(Icons.arrow_back_rounded),
          ),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.violet,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: borderColor, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: borderColor,
                          offset: const Offset(6, 6),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.pets_rounded, color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('WOFF & MEONG', style: context.texts.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                      Text('JOIN THE PACK', style: context.texts.labelSmall?.copyWith(fontWeight: FontWeight.w900, letterSpacing: 2)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: borderColor,
                      offset: const Offset(7, 7),
                    ),
                  ],
                ),
                child: Text(
                  'Buat akun buat mulai ngatur duit bareng puddel squad!',
                  style: context.texts.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(height: 24),
              Text('DAFTAR', style: context.texts.headlineSmall?.copyWith(fontWeight: FontWeight.w900, letterSpacing: 6)),
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
                        controller: _name,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'NAMA LENGKAP',
                          hintText: 'Siapa namamu?',
                          prefixIcon: Icon(Icons.person_outline_rounded),
                        ),
                        validator: (v) {
                          if ((v ?? '').trim().isEmpty) return 'Nama wajib diisi';
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
                          hintText: 'Minimal 6 karakter',
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          suffixIcon: IconButton(
                            onPressed: () => setState(() => _obscure = !_obscure),
                            icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                          ),
                        ),
                        validator: (v) {
                          final value = v ?? '';
                          if (value.isEmpty) return 'Password wajib diisi';
                          if (value.length < 6) return 'Minimal 6 karakter';
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
                      : const Text('DAFTAR'),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('SUDAH PUNYA AKUN?', style: context.texts.labelMedium?.copyWith(fontWeight: FontWeight.w900)),
                  TextButton(
                    onPressed: () => context.go('/login'),
                    child: const Text('MASUK'),
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
