import 'package:get/get.dart';
import '../models/pengeluaran_model.dart';
import '../models/bahan_baku_model.dart';

class KeuanganController extends GetxController {
  final pengeluaranList = <Pengeluaran>[].obs;
  final bahanBakuList = <BahanBaku>[].obs;

  int get totalPengeluaran => pengeluaranList.fold(0, (s, p) => s + p.nominal);

  void tambah({required String nama, required int nominal, DateTime? tanggal}) {
    pengeluaranList.insert(
      0,
      Pengeluaran(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nama: nama,
        nominal: nominal,
        tanggal: tanggal ?? DateTime.now(),
      ),
    );
  }

  void hapus(String id) {
    pengeluaranList.removeWhere((p) => p.id == id);
  }

  void tambahBahan({
    required String nama,
    required double stok,
    required String satuan,
    required int harga,
  }) {
    bahanBakuList.add(
      BahanBaku(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nama: nama,
        stok: stok,
        satuan: satuan,
        harga: harga,
      ),
    );
  }

  void hapusBahan(String id) {
    bahanBakuList.removeWhere((b) => b.id == id);
  }

  void updateBahan(
    String id, {
    String? nama,
    double? stok,
    String? satuan,
    int? harga,
  }) {
    final index = bahanBakuList.indexWhere((b) => b.id == id);
    if (index == -1) return;
    final b = bahanBakuList[index];
    bahanBakuList[index] = BahanBaku(
      id: b.id,
      nama: nama ?? b.nama,
      stok: stok ?? b.stok,
      satuan: satuan ?? b.satuan,
      harga: harga ?? b.harga,
    );
  }

  void tambahStok(String id, double jumlah) {
    final index = bahanBakuList.indexWhere((b) => b.id == id);
    if (index == -1) return;
    final b = bahanBakuList[index];
    bahanBakuList[index] = BahanBaku(
      id: b.id,
      nama: b.nama,
      stok: b.stok + jumlah,
      satuan: b.satuan,
      harga: b.harga,
    );
  }

  void kurangiStok(String id, double jumlah) {
    final index = bahanBakuList.indexWhere((b) => b.id == id);
    if (index == -1) return;
    final b = bahanBakuList[index];
    bahanBakuList[index] = BahanBaku(
      id: b.id,
      nama: b.nama,
      stok: b.stok - jumlah,
      satuan: b.satuan,
      harga: b.harga,
    );
  }
}
