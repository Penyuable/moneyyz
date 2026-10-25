/// Jenis transaksi.
enum TxType {
  income('income', 'Pemasukan'),
  expense('expense', 'Pengeluaran');

  const TxType(this.value, this.label);

  final String value;
  final String label;

  bool get isIncome => this == TxType.income;

  static TxType fromString(String? value) {
    return value == 'income' ? TxType.income : TxType.expense;
  }
}
