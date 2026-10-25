import 'dart:math' as math;

/// Hasil pembacaan struk belanja.
class ReceiptParseResult {
  const ReceiptParseResult({
    required this.rawText,
    this.amount,
    this.date,
    this.merchant,
    this.categoryHint,
  });

  final String rawText;
  final double? amount;
  final DateTime? date;
  final String? merchant;
  final String? categoryHint;

  bool get hasData => amount != null || date != null || merchant != null;

  static const empty = ReceiptParseResult(rawText: '');
}

/// Parser teks struk (hasil OCR) untuk mengambil total, tanggal, dan nama toko.
///
/// Mendukung format umum struk Indonesia, misalnya:
/// - `TOTAL 125.000`
/// - `GRAND TOTAL : Rp 1.250.000`
/// - `24/10/2026` atau `24 Oktober 2026`
class ReceiptParser {
  const ReceiptParser._();

  static const List<String> _totalKeys = [
    'grand total',
    'total bayar',
    'total belanja',
    'total tagihan',
    'total transaksi',
    'total harga',
    'jumlah bayar',
    'jumlah total',
    'total',
    'jumlah',
    'amount',
    'tagihan',
  ];

  static const List<String> _totalLineBlockers = [
    'subtotal',
    'sub total',
    'total item',
    'total qty',
    'total diskon',
    'total potongan',
    'total hemat',
  ];

  static const List<String> _fallbackBlockers = [
    'subtotal',
    'sub total',
    'kembali',
    'kembalian',
    'change',
    'tunai',
    'cash',
    'debit',
    'kredit',
    'credit',
    'qris',
    'kartu',
    'card',
    'ppn',
    'pajak',
    'tax',
    'diskon',
    'potongan',
    'hemat',
    'total item',
    'qty',
    'harga satuan',
    'unit price',
  ];

  static final RegExp _numberPattern = RegExp(r'\d+(?:[.,]\d+)*');
  static final RegExp _isoDate = RegExp(
    r'\b(20\d{2})[\/\-.](\d{1,2})[\/\-.](\d{1,2})\b',
  );
  static final RegExp _numericDate = RegExp(
    r'\b(\d{1,2})[\/\-.](\d{1,2})[\/\-.](\d{2,4})\b',
  );
  static final RegExp _namedDate = RegExp(
    r'\b(\d{1,2})\s+([A-Za-z]{3,9})\.?\s+(\d{2,4})\b',
  );

  static const Map<String, int> _monthNames = {
    'jan': 1,
    'januari': 1,
    'feb': 2,
    'februari': 2,
    'mar': 3,
    'maret': 3,
    'apr': 4,
    'april': 4,
    'mei': 5,
    'may': 5,
    'jun': 6,
    'juni': 6,
    'jul': 7,
    'juli': 7,
    'agu': 8,
    'agt': 8,
    'aug': 8,
    'agustus': 8,
    'august': 8,
    'sep': 9,
    'sept': 9,
    'september': 9,
    'okt': 10,
    'oct': 10,
    'oktober': 10,
    'october': 10,
    'nov': 11,
    'november': 11,
    'des': 12,
    'dec': 12,
    'desember': 12,
    'december': 12,
  };

  static ReceiptParseResult parse(String rawText) {
    if (rawText.trim().isEmpty) return ReceiptParseResult.empty;

    final normalized = rawText
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n');
    final lines = normalized
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    final amount = _findTotal(lines);
    final date = _findDate(normalized);
    final merchant = _findMerchant(lines);

    return ReceiptParseResult(
      rawText: normalized.trim(),
      amount: amount,
      date: date,
      merchant: merchant,
      categoryHint: _findCategoryHint('${merchant ?? ''} $normalized'),
    );
  }

  // ---------------------------------------------------------------------------
  // Nominal
  // ---------------------------------------------------------------------------
  static double? _findTotal(List<String> lines) {
    for (final key in _totalKeys) {
      for (final line in lines) {
        final lower = line.toLowerCase();
        if (!lower.contains(key)) continue;
        if (_totalLineBlockers.any(lower.contains)) continue;

        final amounts = _amountsIn(line);
        if (amounts.isEmpty) continue;

        final candidate = amounts.reduce(math.max);
        if (_isPlausibleAmount(candidate)) return candidate;
      }
    }

    // Cadangan: ambil nominal terbesar yang wajar dari seluruh struk.
    final candidates = <double>[];
    for (final line in lines) {
      final lower = line.toLowerCase();
      if (_fallbackBlockers.any(lower.contains)) continue;
      candidates.addAll(_amountsIn(line));
    }
    if (candidates.isEmpty) return null;
    final best = candidates.reduce(math.max);
    return _isPlausibleAmount(best) ? best : null;
  }

  static bool _isPlausibleAmount(double value) {
    return value >= 100 && value < 10000000000;
  }

  static List<double> _amountsIn(String line) {
    final results = <double>[];
    for (final match in _numberPattern.allMatches(line)) {
      final parsed = _parseNumber(match.group(0)!);
      if (parsed != null && _isPlausibleAmount(parsed)) {
        results.add(parsed);
      }
    }
    return results;
  }

  /// Mengubah `1.234.567`, `1,234,567`, `1.234,50`, atau `1234567`
  /// menjadi angka.
  static double? _parseNumber(String raw) {
    var value = raw.replaceAll(RegExp(r'[^0-9.,]'), '');
    value = value.replaceAll(RegExp(r'^[.,]+|[.,]+$'), '');
    if (value.isEmpty) return null;

    final hasDot = value.contains('.');
    final hasComma = value.contains(',');

    if (hasDot && hasComma) {
      if (value.lastIndexOf(',') > value.lastIndexOf('.')) {
        // Format Indonesia: 1.234.567,89
        value = value.replaceAll('.', '').replaceAll(',', '.');
      } else {
        // Format Inggris: 1,234,567.89
        value = value.replaceAll(',', '');
      }
    } else if (hasComma) {
      final parts = value.split(',');
      if (parts.length == 2 && parts[1].length <= 2) {
        value = '${parts[0]}.${parts[1]}';
      } else {
        value = value.replaceAll(',', '');
      }
    } else if (hasDot) {
      final parts = value.split('.');
      if (parts.length > 2) {
        value = value.replaceAll('.', '');
      } else if (parts[1].length == 3) {
        value = value.replaceAll('.', '');
      }
      // Selain itu dibiarkan sebagai desimal (contoh: 12.5).
    }

    return double.tryParse(value);
  }

  // ---------------------------------------------------------------------------
  // Tanggal
  // ---------------------------------------------------------------------------
  static DateTime? _findDate(String text) {
    for (final match in _isoDate.allMatches(text)) {
      final date = _safeDate(
        int.parse(match.group(1)!),
        int.parse(match.group(2)!),
        int.parse(match.group(3)!),
      );
      if (date != null) return date;
    }

    for (final match in _numericDate.allMatches(text)) {
      final first = int.parse(match.group(1)!);
      final second = int.parse(match.group(2)!);
      var year = int.parse(match.group(3)!);

      // Prioritaskan format Indonesia dd/MM/yyyy.
      if (first <= 31 && second <= 12) {
        if (year < 100) year += 2000;
        final date = _safeDate(year, second, first);
        if (date != null) return date;
      }

      // Jika terbalik (MM/dd/yyyy).
      if (first <= 12 && second <= 31) {
        if (year < 100) year += 2000;
        final date = _safeDate(year, first, second);
        if (date != null) return date;
      }
    }

    for (final match in _namedDate.allMatches(text)) {
      final day = int.parse(match.group(1)!);
      final monthKey = match.group(2)!.toLowerCase();
      final month = _monthNames[monthKey] ??
          _monthNames[monthKey.substring(0, math.min(3, monthKey.length))];
      if (month == null) continue;
      var year = int.parse(match.group(3)!);
      if (year < 100) year += 2000;
      final date = _safeDate(year, month, day);
      if (date != null) return date;
    }

    return null;
  }

  static DateTime? _safeDate(int year, int month, int day) {
    if (year < 2000 || year > DateTime.now().year + 1) return null;
    if (month < 1 || month > 12) return null;
    if (day < 1 || day > 31) return null;
    final date = DateTime(year, month, day);
    if (date.year != year || date.month != month || date.day != day) {
      return null;
    }
    return date;
  }

  // ---------------------------------------------------------------------------
  // Nama toko
  // ---------------------------------------------------------------------------
  static const List<String> _merchantBlockers = [
    'jl.',
    'jl ',
    'jalan',
    'alamat',
    'telp',
    'telpon',
    'telepon',
    'phone',
    'npwp',
    'invoice',
    'struk',
    'kasir',
    'tanggal',
    'date',
    'waktu',
    'terima kasih',
    'selamat',
    'member',
    'www.',
    'http',
    'email',
    'instagram',
    'kode',
    'shift',
    'no.',
    'nota',
  ];

  static String? _findMerchant(List<String> lines) {
    for (final line in lines.take(12)) {
      final cleaned = line
          .replaceAll(RegExp(r'^[^A-Za-z0-9]+'), '')
          .replaceAll(RegExp(r'[^A-Za-z0-9]+$'), '')
          .trim();
      if (cleaned.length < 3 || cleaned.length > 48) continue;

      final lower = cleaned.toLowerCase();
      if (_merchantBlockers.any(lower.contains)) continue;
      if (cleaned.contains(':') || cleaned.contains('@')) continue;

      final letters = RegExp('[A-Za-z]').allMatches(cleaned).length;
      final digits = RegExp('[0-9]').allMatches(cleaned).length;
      if (letters < 3 || digits > letters) continue;
      if (RegExp(r'^\d').hasMatch(cleaned)) continue;

      if (cleaned == cleaned.toUpperCase() && cleaned.contains(' ')) {
        return _titleCase(cleaned);
      }
      return cleaned;
    }
    return null;
  }

  static String _titleCase(String input) {
    return input
        .toLowerCase()
        .split(' ')
        .where((word) => word.isNotEmpty)
        .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }

  // ---------------------------------------------------------------------------
  // Tebakan kategori
  // ---------------------------------------------------------------------------
  static const List<MapEntry<String, List<String>>> _categoryKeywords = [
    MapEntry('Makan & Minum', [
      'resto',
      'restoran',
      'restaurant',
      'cafe',
      'kafe',
      'coffee',
      'kopi',
      'warung',
      'bakso',
      'sate',
      'nasi',
      'ayam',
      'makan',
      'food',
      'kfc',
      'mcd',
      'mcdonald',
      'burger',
      'pizza',
      'starbucks',
      'jco',
      'donat',
      'donut',
      'roti',
      'boba',
      'teh',
    ]),
    MapEntry('Transportasi', [
      'pertamina',
      'spbu',
      'shell',
      'bensin',
      'parkir',
      'parking',
      'tol',
      'gojek',
      'grab',
      'ojek',
      'taksi',
      'taxi',
      'bengkel',
      'tiket',
      'bus',
      'kereta',
    ]),
    MapEntry('Belanja', [
      'indomaret',
      'alfamart',
      'alfamidi',
      'superindo',
      'hypermart',
      'transmart',
      'carrefour',
      'mart',
      'minimarket',
      'supermarket',
      'toko',
      'belanja',
      'groceries',
    ]),
    MapEntry('Kesehatan', [
      'apotek',
      'apotik',
      'klinik',
      'rumah sakit',
      'hospital',
      'farmasi',
      'dokter',
      'gym',
    ]),
    MapEntry('Tagihan', [
      'pln',
      'listrik',
      'pdam',
      'telkom',
      'indihome',
      'internet',
      'pulsa',
      'token',
      'tagihan',
      'air ',
    ]),
    MapEntry('Hiburan', [
      'bioskop',
      'cinema',
      'xxi',
      'cgv',
      'game',
      'netflix',
      'spotify',
      'hiburan',
    ]),
    MapEntry('Pendidikan', [
      'sekolah',
      'kampus',
      'buku',
      'kursus',
      'pendidikan',
      'gramedia',
    ]),
    MapEntry('Laundry', ['laundry', 'binatu']),
    MapEntry('Pets', ['pet', 'kucing', 'hewan']),
    MapEntry('Rumah', [
      'perabot',
      'furniture',
      'ace hardware',
      'mebel',
      'dekorasi',
    ]),
  ];

  static String? _findCategoryHint(String text) {
    final lower = text.toLowerCase();
    for (final entry in _categoryKeywords) {
      for (final keyword in entry.value) {
        if (lower.contains(keyword)) return entry.key;
      }
    }
    return null;
  }
}
