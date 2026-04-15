enum DetailKeuanganType { pemasukan, pengeluaran }

class DetailKeuanganItemModel {
  final String id;
  final DetailKeuanganType type;
  final String title;
  final String? subtitle;
  final int nominal;
  final DateTime createdAt;

  const DetailKeuanganItemModel({
    required this.id,
    required this.type,
    required this.title,
    this.subtitle,
    required this.nominal,
    required this.createdAt,
  });

  bool get isPemasukan => type == DetailKeuanganType.pemasukan;
  bool get isPengeluaran => type == DetailKeuanganType.pengeluaran;
}