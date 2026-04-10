class Pengeluaran {
  final String id;
  final String nama;
  final int nominal;
  final DateTime tanggal;

  Pengeluaran({
    required this.id,
    required this.nama,
    required this.nominal,
    required this.tanggal,
  });

  factory Pengeluaran.fromJson(Map<String, dynamic> json) {
    return Pengeluaran(
      id: json['id'].toString(),
      nama: json['nama'] ?? '',
      nominal: json['nominal'] ?? 0,
      tanggal: DateTime.parse(json['tanggal']),
    );
  }
}