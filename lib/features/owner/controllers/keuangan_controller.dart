import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/pengeluaran_model.dart';
import '../models/bahan_baku_model.dart';

class KeuanganController extends GetxController {
  final supabase = Supabase.instance.client;

  final pengeluaranList = <Pengeluaran>[].obs;
  final bahanBakuList = <BahanBaku>[].obs;

  int get totalPengeluaran => pengeluaranList.fold(0, (s, p) => s + p.nominal);

  Future<void> getBahan() async {
    final res = await supabase.from('bahan_baku').select();

    bahanBakuList.value = (res as List)
        .map((e) => BahanBaku.fromJson(e))
        .toList();
  }

  Future<void> tambahBahan({
    required String name,
    required int stock,
    required String unit,
    required int price,
  }) async {
    await supabase.from('bahan_baku').insert({
      'name': name,
      'stock': stock,
      'unit': unit,
      'price': price,
    });

    await getBahan();
  }

  Future<void> hapusBahan(String id) async {
    await supabase.from('bahan_baku').delete().eq('id', id);
    await getBahan();
  }

  Future<void> updateBahan(
    String id, {
    String? name,
    int? stock,
    String? unit,
    int? price,
  }) async {
    await supabase
        .from('bahan_baku')
        .update({
          if (name != null) 'name': name,
          if (stock != null) 'stock': stock,
          if (unit != null) 'unit': unit,
          if (price != null) 'price': price,
        })
        .eq('id', id);

    await getBahan();
  }

  Future<void> tambahStok(String id, int jumlah) async {
    final current = bahanBakuList.firstWhere((b) => b.id == id);

    await supabase
        .from('bahan_baku')
        .update({'stock': current.stock + jumlah})
        .eq('id', id);

    await getBahan();
  }

  Future<void> kurangiStok(String id, int jumlah) async {
    final current = bahanBakuList.firstWhere((b) => b.id == id);

    await supabase
        .from('bahan_baku')
        .update({'stock': current.stock - jumlah})
        .eq('id', id);

    await getBahan();
  }

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

  @override
  void onInit() {
    super.onInit();
    getBahan();
  }
}
