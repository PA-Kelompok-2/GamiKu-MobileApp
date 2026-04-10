class RekapKeuanganModel {
  final String label;
  final double pemasukan;
  final double pengeluaran;

  RekapKeuanganModel({
    required this.label,
    required this.pemasukan,
    required this.pengeluaran,
  });

  double get saldo => pemasukan - pengeluaran;
}