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

    bahanBakuList.value =
        (res as List).map((e) => BahanBaku.fromJson(e)).toList();
  }

  Future<void> getPengeluaran() async {
    final res = await supabase
        .from('keuangan')
        .select()
        .eq('jenis', 'pengeluaran')
        .order('tanggal', ascending: false);

    pengeluaranList.value =
        (res as List).map((e) => Pengeluaran.fromJson(e)).toList();
  }

  Future<void> tambahBahan({
    required String name,
    required int stock,
    required String unit,
    required int price,
  }) async {
    final total = stock * price;

    await supabase.from('bahan_baku').insert({
      'name': name,
      'stock': stock,
      'unit': unit,
      'price': price,
    });

    await supabase.from('keuangan').insert({
      'jenis': 'pengeluaran',
      'nama': 'Pembelian bahan baku: $name',
      'nominal': total,
      'tanggal': DateTime.now().toIso8601String(),
    });

    await getBahan();
    await getPengeluaran();
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
    final data = <String, dynamic>{};

    if (name != null) data['name'] = name;
    if (stock != null) data['stock'] = stock;
    if (unit != null) data['unit'] = unit;
    if (price != null) data['price'] = price;

    await supabase.from('bahan_baku').update(data).eq('id', id);

    await getBahan();
  }

  Future<void> tambahStok(String id, int jumlah) async {
    final current = bahanBakuList.firstWhere((b) => b.id == id);
    final total = current.price * jumlah;

    await supabase
        .from('bahan_baku')
        .update({'stock': current.stock + jumlah})
        .eq('id', id);

    await supabase.from('keuangan').insert({
      'jenis': 'pengeluaran',
      'nama': 'Tambah stok bahan baku: ${current.name}',
      'nominal': total,
      'tanggal': DateTime.now().toIso8601String(),
    });

    await getBahan();
    await getPengeluaran();
  }

  Future<void> kurangiStok(String id, int jumlah) async {
    final current = bahanBakuList.firstWhere((b) => b.id == id);

    await supabase
        .from('bahan_baku')
        .update({'stock': current.stock - jumlah})
        .eq('id', id);

    await getBahan();
  }

  Future<void> tambah({
    required String nama,
    required int nominal,
    DateTime? tanggal,
  }) async {
    await supabase.from('keuangan').insert({
      'jenis': 'pengeluaran',
      'nama': nama,
      'nominal': nominal,
      'tanggal': (tanggal ?? DateTime.now()).toIso8601String(),
    });

    await getPengeluaran();
  }

  Future<void> hapus(String id) async {
    await supabase.from('keuangan').delete().eq('id', id);
    await getPengeluaran();
  }

  @override
  void onInit() {
    super.onInit();
    getBahan();
    getPengeluaran();
  }
}