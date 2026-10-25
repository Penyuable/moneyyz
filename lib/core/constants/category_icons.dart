import 'package:flutter/material.dart';

/// Ikon kategori disimpan sebagai string di database, lalu dipetakan ke
/// ikon Material saat ditampilkan.
const Map<String, IconData> kCategoryIcons = {
  'category': Icons.category_rounded,
  'salary': Icons.account_balance_wallet_rounded,
  'bonus': Icons.card_giftcard_rounded,
  'investment': Icons.trending_up_rounded,
  'savings': Icons.savings_rounded,
  'refund': Icons.replay_rounded,
  'food': Icons.restaurant_rounded,
  'coffee': Icons.local_cafe_rounded,
  'groceries': Icons.shopping_basket_rounded,
  'shopping': Icons.shopping_bag_rounded,
  'transport': Icons.directions_bus_rounded,
  'fuel': Icons.local_gas_station_rounded,
  'bill': Icons.receipt_long_rounded,
  'internet': Icons.wifi_rounded,
  'phone': Icons.phone_android_rounded,
  'health': Icons.favorite_rounded,
  'education': Icons.school_rounded,
  'entertainment': Icons.movie_rounded,
  'home': Icons.home_rounded,
  'pets': Icons.pets_rounded,
  'gift': Icons.redeem_rounded,
  'travel': Icons.flight_takeoff_rounded,
  'sport': Icons.sports_soccer_rounded,
  'laundry': Icons.local_laundry_service_rounded,
  'kids': Icons.child_care_rounded,
  'other': Icons.more_horiz_rounded,
};

IconData categoryIcon(String? key) {
  return kCategoryIcons[key] ?? Icons.category_rounded;
}

/// Warna pilihan untuk kategori.
const List<int> kCategoryColors = [
  0xFF5B5BD6,
  0xFF7C3AED,
  0xFF2563EB,
  0xFF0EA5E9,
  0xFF14B8A6,
  0xFF10B981,
  0xFF84CC16,
  0xFFF59E0B,
  0xFFF97316,
  0xFFF43F5E,
  0xFFEC4899,
  0xFF64748B,
];

int colorFromHex(String? hex, {int fallback = 0xFF5B5BD6}) {
  if (hex == null || hex.isEmpty) return fallback;
  final clean = hex.replaceAll('#', '').trim();
  final value = int.tryParse(clean, radix: 16);
  if (value == null) return fallback;
  return value | 0xFF000000;
}

String colorToHex(int color) {
  return '#${(color & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
}
