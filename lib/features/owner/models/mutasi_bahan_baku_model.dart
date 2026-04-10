class MutasiBahanBakuModel {
  final String id;
  final String bahanBakuId;
  final String namaBahan;
  final String jenis;
  final int jumlah;
  final DateTime createdAt;

  MutasiBahanBakuModel({
    required this.id,
    required this.bahanBakuId,
    required this.namaBahan,
    required this.jenis,
    required this.jumlah,
    required this.createdAt,
  });

  factory MutasiBahanBakuModel.fromJson(Map<String, dynamic> json) {
    return MutasiBahanBakuModel(
      id: json['id'].toString(),
      bahanBakuId: json['bahan_baku_id'].toString(),
      namaBahan: (json['nama_bahan'] ?? '').toString(),
      jenis: (json['jenis'] ?? '').toString(),
      jumlah: (json['jumlah'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(
        (json['created_at'] ?? DateTime.now().toIso8601String()).toString(),
      ),
    );
  }

  bool get isMasuk => jenis == 'masuk';
  bool get isKeluar => jenis == 'keluar';
}      