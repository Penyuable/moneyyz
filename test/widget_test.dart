import 'package:flutter_test/flutter_test.dart';
import 'package:saku/core/utils/formatters.dart';
import 'package:saku/core/utils/initials.dart' as init;

void main() {
  group('formatters', () {
    test('formatRupiah memakai pemisah ribuan', () {
      expect(formatRupiah(1234567), 'Rp 1.234.567');
    });

    test('formatSignedRupiah menambahkan tanda sesuai jenis', () {
      expect(formatSignedRupiah(50000, isIncome: true), '+Rp 50.000');
      expect(formatSignedRupiah(50000, isIncome: false), '-Rp 50.000');
    });
  });

  group('initialsOf', () {
    test('mengambil inisial dua kata', () {
      expect(init.initialsOf('Samuel Bryant'), 'SB');
    });

    test('memberi fallback saat nama kosong', () {
      expect(init.initialsOf(''), 'S');
    });
  });
}
