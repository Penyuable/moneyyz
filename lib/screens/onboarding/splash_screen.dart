import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6D5DFB), Color(0xFF8B5CF6)],
        )),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                ),
                child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 38),
              ),
              const SizedBox(height: 16),
              Text(
                'Saku',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 28),
              ),
              const SizedBox(height: 6),
              Text(
                'Catatan keuangan pribadi',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 15),
              ),
              const SizedBox(height: 28),
              const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
