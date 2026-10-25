import 'package:flutter/material.dart';

import '../../core/constants/category_icons.dart';
import 'tx_type.dart';

class Category {
  const Category({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.icon,
    required this.color,
  });

  final String id;
  final String userId;
  final String name;
  final TxType type;
  final String icon;
  final Color color;

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as String,
      userId: map['user_id'] as String? ?? '',
      name: map['name'] as String? ?? 'Tanpa nama',
      type: TxType.fromString(map['type'] as String?),
      icon: map['icon'] as String? ?? 'category',
      color: Color(colorFromHex(map['color'] as String?)),
    );
  }

  Map<String, dynamic> toInsert({required String userId}) {
    return {
      'user_id': userId,
      'name': name,
      'type': type.value,
      'icon': icon,
      'color': colorToHex(color.toARGB32()),
    };
  }

  Map<String, dynamic> toUpdate() {
    return {
      'name': name,
      'type': type.value,
      'icon': icon,
      'color': colorToHex(color.toARGB32()),
    };
  }

  Category copyWith({
    String? name,
    TxType? type,
    String? icon,
    Color? color,
  }) {
    return Category(
      id: id,
      userId: userId,
      name: name ?? this.name,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      color: color ?? this.color,
    );
  }
}

/// Kategori bawaan saat pengguna baru mendaftar.
const List<CategorySeed> kDefaultCategories = [
  CategorySeed('Gaji', TxType.income, 'salary', Color(0xFF5B5BD6)),
  CategorySeed('Bonus', TxType.income, 'bonus', Color(0xFF7C3AED)),
  CategorySeed('Investasi', TxType.income, 'investment', Color(0xFF14B8A6)),
  CategorySeed('Pemasukan Lain', TxType.income, 'other', Color(0xFF64748B)),
  CategorySeed(
    'Makan & Minum',
    TxType.expense,
    'food',
    Color(0xFFF97316),
  ),
  CategorySeed(
    'Transportasi',
    TxType.expense,
    'transport',
    Color(0xFF0EA5E9),
  ),
  CategorySeed('Belanja', TxType.expense, 'groceries', Color(0xFFEC4899)),
  CategorySeed('Tagihan', TxType.expense, 'bill', Color(0xFFF59E0B)),
  CategorySeed('Kesehatan', TxType.expense, 'health', Color(0xFF10B981)),
  CategorySeed(
    'Hiburan',
    TxType.expense,
    'entertainment',
    Color(0xFF8B5CF6),
  ),
  CategorySeed('Pendidikan', TxType.expense, 'education', Color(0xFF2563EB)),
  CategorySeed('Pengeluaran Lain', TxType.expense, 'other', Color(0xFF64748B)),
];

class CategorySeed {
  const CategorySeed(this.name, this.type, this.icon, this.color);

  final String name;
  final TxType type;
  final String icon;
  final Color color;

  Map<String, dynamic> toMap(String userId) {
    return {
      'user_id': userId,
      'name': name,
      'type': type.value,
      'icon': icon,
      'color': colorToHex(color.toARGB32()),
    };
  }
}
