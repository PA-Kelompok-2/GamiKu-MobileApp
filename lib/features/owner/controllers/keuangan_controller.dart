import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/detail_keuangan_item_model.dart';
import '../models/pengeluaran_model.dart';
import '../models/bahan_baku_model.dart';
import '../models/rekap_keuangan_model.dart';
import '../models/mutasi_bahan_baku_model.dart';

enum DetailKeuanganTab {
  pemasukan,
  pengeluaran,
}

class KeuanganController extends GetxController {
  final supabase = Supabase.instance.client;

  final mutasiBahanBakuList = <MutasiBahanBakuModel>[].obs;
  final rekapBahanHarian = <RekapKeuanganModel>[].obs;
  final rekapBahanMingguan = <RekapKeuanganModel>[].obs;
  final rekapBahanBulanan = <RekapKeuanganModel>[].obs;

  final pengeluaranList = <Pengeluaran>[].obs;
  final bahanBakuList = <BahanBaku>[].obs;
  final keuanganList = <Map<String, dynamic>>[].obs;
  final completedOrders = <Map<String, dynamic>>[].obs;

  final rekapHarian = <RekapKeuanganModel>[].obs;
  final rekapMingguan = <RekapKeuanganModel>[].obs;
  final rekapBulanan = <RekapKeuanganModel>[].obs;

  final isLoadingDetailKeuangan = false.obs;
  final selectedDetailTab = DetailKeuanganTab.pemasukan.obs;
  final pemasukanDetailList = <DetailKeuanganItemModel>[].obs;
  final pengeluaranDetailList = <DetailKeuanganItemModel>[].obs;

  // tambahan untuk halaman detail mutasi
  final isLoadingMutasiBahanBaku = false.obs;
  final selectedMutasiPeriode = 'harian'.obs;
  final mutasiSearchQuery = ''.obs;

  int get totalPengeluaran => pengeluaranList.fold(0, (s, p) => s + p.nominal);

  List<DetailKeuanganItemModel> get activeDetailList {
    if (selectedDetailTab.value == DetailKeuanganTab.pemasukan) {
      return pemasukanDetailList;
    }
    return pengeluaranDetailList;
  }

  List<MutasiBahanBakuModel> get filteredMutasiBahanBaku {
    final now = DateTime.now();

    return mutasiBahanBakuList.where((item) {
      bool matchPeriode = true;
      final createdAt = item.createdAt.toLocal();

      if (selectedMutasiPeriode.value == 'harian') {
        matchPeriode =
            createdAt.year == now.year &&
            createdAt.month == now.month &&
            createdAt.day == now.day;
      } else if (selectedMutasiPeriode.value == 'mingguan') {
        final start = startOfWeek(now);
        final end = start.add(const Duration(days: 7));

        matchPeriode =
            !createdAt.isBefore(start) &&
            createdAt.isBefore(end);
      } else if (selectedMutasiPeriode.value == 'bulanan') {
        matchPeriode =
            createdAt.year == now.year &&
            createdAt.month == now.month;
      }

      final query = mutasiSearchQuery.value.trim().toLowerCase();

      if (query.isEmpty) return matchPeriode;

      final namaBahan = (item.namaBahan).toLowerCase();
      final jenis = (item.jenis).toLowerCase();

      return matchPeriode &&
          (namaBahan.contains(query) || jenis.contains(query));
    }).toList();
  }

  void changeDetailTab(DetailKeuanganTab tab) {
    selectedDetailTab.value = tab;
  }

  void setMutasiPeriode(String periode) {
    selectedMutasiPeriode.value = periode;
  }

  void setMutasiSearchQuery(String value) {
    mutasiSearchQuery.value = value;
  }

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

  Future<void> getSemuaKeuangan() async {
    final res = await supabase
        .from('keuangan')
        .select()
        .order('tanggal', ascending: false);

    keuanganList.value = List<Map<String, dynamic>>.from(res);
  }

  Future<void> fetchCompletedOrders() async {
    final res = await supabase
        .from('orders')
        .select('id, order_code, total_price, status, created_at')
        .eq('status', 'completed')
        .order('created_at', ascending: false);

    completedOrders.value = List<Map<String, dynamic>>.from(res);

    hitungRekapGabungan(completedOrders);
  }

  Future<void> fetchDetailKeuangan() async {
    try {
      isLoadingDetailKeuangan.value = true;

      final ordersRes = await supabase
          .from('orders')
          .select('id, order_code, total_price, status, created_at')
          .eq('status', 'completed')
          .order('created_at', ascending: false);

      final keuanganRes = await supabase
          .from('keuangan')
          .select('id, nama, nominal, jenis, created_at, tanggal, order_id')
          .eq('jenis', 'pengeluaran')
          .order('created_at', ascending: false);

      pemasukanDetailList.value = (ordersRes as List)
          .map(
            (e) => DetailKeuanganItemModel(
              id: e['id'].toString(),
              type: DetailKeuanganType.pemasukan,
              title: (e['order_code'] ?? 'Order').toString(),
              subtitle: 'Order completed',
              nominal: (e['total_price'] as num?)?.toInt() ?? 0,
              createdAt: DateTime.parse(
                (e['created_at'] ?? DateTime.now().toIso8601String())
                    .toString(),
              ),
            ),
          )
          .toList();

      pengeluaranDetailList.value = (keuanganRes as List)
          .map(
            (e) => DetailKeuanganItemModel(
              id: e['id'].toString(),
              type: DetailKeuanganType.pengeluaran,
              title: (e['nama'] ?? 'Pengeluaran').toString(),
              subtitle: e['order_id'] != null
                  ? 'Dari order'
                  : _buildPengeluaranSubtitle(e),
              nominal: (e['nominal'] as num?)?.toInt() ?? 0,
              createdAt: DateTime.parse(
                (e['created_at'] ??
                        e['tanggal'] ??
                        DateTime.now().toIso8601String())
                    .toString(),
              ),
            ),
          )
          .toList();
    } catch (e) {
      Get.snackbar('Error', 'Gagal ambil detail keuangan: $e');
    } finally {
      isLoadingDetailKeuangan.value = false;
    }
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

    await catatPengeluaranBahanBaku(
      namaBahan: name,
      jumlah: stock,
      unit: unit,
      hargaSatuan: price,
      sumber: 'stok_awal',
    );

    await getBahan();
    await getPengeluaran();
    await getSemuaKeuangan();
    await fetchDetailKeuangan();
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
    final current = bahanBakuList.firstWhere((b) => b.id == id);

    final data = <String, dynamic>{};

    if (name != null) data['name'] = name;
    if (stock != null) data['stock'] = stock;
    if (unit != null) data['unit'] = unit;
    if (price != null) data['price'] = price;

    if (data.isEmpty) return;

    if (stock != null && stock != current.stock) {
      final selisih = stock - current.stock;

      await catatMutasiBahanBaku(
        bahanBakuId: current.id,
        namaBahan: name ?? current.name,
        jenis: selisih > 0 ? 'masuk' : 'keluar',
        jumlah: selisih.abs(),
      );
    }

    await supabase.from('bahan_baku').update(data).eq('id', id);

    await getBahan();
    await getMutasiBahanBaku();
  }

  Future<void> catatPengeluaranBahanBaku({
    required String namaBahan,
    required int jumlah,
    required String unit,
    required int hargaSatuan,
    String sumber = 'tambah_stok',
  }) async {
    final nominal = jumlah * hargaSatuan;

    await supabase.from('keuangan').insert({
      'jenis': 'pengeluaran',
      'nama': 'Pembelian stok bahan baku: $namaBahan',
      'nominal': nominal,
      'tanggal': DateTime.now().toIso8601String(),
      'created_at': DateTime.now().toIso8601String(),
      'keterangan':
          'Sumber: $sumber | Qty: $jumlah $unit | Harga satuan: Rp $hargaSatuan',
    });
  }

  String _buildPengeluaranSubtitle(Map<String, dynamic> data) {
    final nama = (data['nama'] ?? '').toString().toLowerCase();
    final keterangan = (data['keterangan'] ?? '').toString();

    if (nama.contains('bahan baku') || nama.contains('stok bahan baku')) {
      return keterangan.isNotEmpty ? keterangan : 'Pembelian bahan baku';
    }

    return 'Manual / operasional';
  }

  Future<void> tambahStok(String id, int jumlah) async {
    final current = bahanBakuList.firstWhere((b) => b.id == id);

    await supabase
        .from('bahan_baku')
        .update({'stock': current.stock + jumlah})
        .eq('id', id);

    await catatMutasiBahanBaku(
      bahanBakuId: current.id,
      namaBahan: current.name,
      jenis: 'masuk',
      jumlah: jumlah,
    );

    await catatPengeluaranBahanBaku(
      namaBahan: current.name,
      jumlah: jumlah,
      unit: current.unit,
      hargaSatuan: current.price,
      sumber: 'tambah_stok',
    );

    await getBahan();
    await getPengeluaran();
    await getSemuaKeuangan();
    await getMutasiBahanBaku();
    await fetchDetailKeuangan();
  }

  Future<void> kurangiStok(String id, int jumlah) async {
    final current = bahanBakuList.firstWhere((b) => b.id == id);

    await supabase
        .from('bahan_baku')
        .update({'stock': current.stock - jumlah})
        .eq('id', id);

    await catatMutasiBahanBaku(
      bahanBakuId: current.id,
      namaBahan: current.name,
      jenis: 'keluar',
      jumlah: jumlah,
    );

    await getBahan();
    await getMutasiBahanBaku();
  }

  Future<void> catatMutasiBahanBaku({
    required String bahanBakuId,
    required String namaBahan,
    required String jenis,
    required int jumlah,
  }) async {
    await supabase.from('mutasi_bahan_baku').insert({
      'bahan_baku_id': bahanBakuId,
      'nama_bahan': namaBahan,
      'jenis': jenis,
      'jumlah': jumlah,
      'created_at': DateTime.now().toIso8601String(),
    });
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
    await getSemuaKeuangan();
    await fetchDetailKeuangan();
  }

  Future<void> hapus(String id) async {
    await supabase.from('keuangan').delete().eq('id', id);
    await getPengeluaran();
    await getSemuaKeuangan();
    await fetchDetailKeuangan();
  }

  List<Map<String, dynamic>> gabungkanTransaksiDenganOrders(
    List<Map<String, dynamic>> orders,
  ) {
    final List<Map<String, dynamic>> gabungan = [];

    gabungan.addAll(keuanganList);

    for (final order in orders) {
      gabungan.add({
        'jenis': 'pemasukan',
        'nama': order['order_code'] ?? 'Order',
        'nominal': (order['total_price'] as num?)?.toInt() ?? 0,
        'tanggal': order['created_at'],
      });
    }

    return gabungan;
  }

  Future<void> getMutasiBahanBaku() async {
    try {
      isLoadingMutasiBahanBaku.value = true;

      final res = await supabase
          .from('mutasi_bahan_baku')
          .select()
          .order('created_at', ascending: false);

      mutasiBahanBakuList.value =
          (res as List).map((e) => MutasiBahanBakuModel.fromJson(e)).toList();

      hitungRekapMutasiBahanBaku();
    } catch (e) {
      Get.snackbar('Error', 'Gagal ambil mutasi bahan baku: $e');
    } finally {
      isLoadingMutasiBahanBaku.value = false;
    }
  }

  void hitungRekapGabungan(List<Map<String, dynamic>> orders) {
    final dataGabungan = gabungkanTransaksiDenganOrders(orders);

    rekapHarian.value = getRekapHarian(dataGabungan);
    rekapMingguan.value = getRekapMingguan(dataGabungan);
    rekapBulanan.value = getRekapBulanan(dataGabungan);
  }

  int getTotalPemasukanGabungan(List<Map<String, dynamic>> orders) {
    return orders.fold(
      0,
      (sum, order) => sum + ((order['total_price'] as num?)?.toInt() ?? 0),
    );
  }

  int getTotalPengeluaranGabungan() {
    return keuanganList.fold(0, (sum, item) {
      final jenis = (item['jenis'] ?? '').toString().toLowerCase();
      final nominal = (item['nominal'] as num?)?.toInt() ?? 0;
      return jenis == 'pengeluaran' ? sum + nominal : sum;
    });
  }

  int getSaldoGabungan(List<Map<String, dynamic>> orders) {
    return getTotalPemasukanGabungan(orders) - getTotalPengeluaranGabungan();
  }

  List<RekapKeuanganModel> getRekapHarian(List<Map<String, dynamic>> data) {
    final Map<String, RekapKeuanganModel> hasil = {};

    for (final item in data) {
      final tanggal = DateTime.parse(item['tanggal']).toLocal();
      final jenis = (item['jenis'] ?? '').toString().toLowerCase();
      final nominal = (item['nominal'] as num?)?.toInt() ?? 0;

      final key =
          '${tanggal.year}-${tanggal.month.toString().padLeft(2, '0')}-${tanggal.day.toString().padLeft(2, '0')}';

      if (!hasil.containsKey(key)) {
        hasil[key] = RekapKeuanganModel(
          label: key,
          pemasukan: 0,
          pengeluaran: 0,
        );
      }

      final current = hasil[key]!;

      hasil[key] = RekapKeuanganModel(
        label: current.label,
        pemasukan: jenis == 'pemasukan'
            ? current.pemasukan + nominal
            : current.pemasukan,
        pengeluaran: jenis == 'pengeluaran'
            ? current.pengeluaran + nominal
            : current.pengeluaran,
      );
    }

    final list = hasil.values.toList();
    list.sort((a, b) => b.label.compareTo(a.label));
    return list;
  }

  void hitungRekapMutasiBahanBaku() {
    rekapBahanHarian.value = getRekapBahanHarian(mutasiBahanBakuList);
    rekapBahanMingguan.value = getRekapBahanMingguan(mutasiBahanBakuList);
    rekapBahanBulanan.value = getRekapBahanBulanan(mutasiBahanBakuList);
  }

  List<RekapKeuanganModel> getRekapBahanHarian(
    List<MutasiBahanBakuModel> data,
  ) {
    final Map<String, RekapKeuanganModel> hasil = {};

    for (final item in data) {
      final tanggal = item.createdAt.toLocal();

      final key =
          '${tanggal.year}-${tanggal.month.toString().padLeft(2, '0')}-${tanggal.day.toString().padLeft(2, '0')}';

      if (!hasil.containsKey(key)) {
        hasil[key] = RekapKeuanganModel(
          label: key,
          pemasukan: 0,
          pengeluaran: 0,
        );
      }

      final current = hasil[key]!;

      hasil[key] = RekapKeuanganModel(
        label: current.label,
        pemasukan:
            item.isMasuk ? current.pemasukan + item.jumlah : current.pemasukan,
        pengeluaran:
            item.isKeluar ? current.pengeluaran + item.jumlah : current.pengeluaran,
      );
    }

    final list = hasil.values.toList();
    list.sort((a, b) => b.label.compareTo(a.label));
    return list;
  }

  List<MutasiBahanBakuModel> getMutasiByBahanId(String bahanBakuId) {
    final items = mutasiBahanBakuList
        .where((item) => item.bahanBakuId == bahanBakuId)
        .toList();

    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  List<RekapKeuanganModel> getRekapBahanMingguan(
    List<MutasiBahanBakuModel> data,
  ) {
    final Map<String, RekapKeuanganModel> hasil = {};

    for (final item in data) {
      final tanggal = item.createdAt.toLocal();
      final awalMinggu = startOfWeek(tanggal);

      final key =
          '${awalMinggu.year}-${awalMinggu.month.toString().padLeft(2, '0')}-${awalMinggu.day.toString().padLeft(2, '0')}';

      if (!hasil.containsKey(key)) {
        hasil[key] = RekapKeuanganModel(
          label: 'Minggu $key',
          pemasukan: 0,
          pengeluaran: 0,
        );
      }

      final current = hasil[key]!;

      hasil[key] = RekapKeuanganModel(
        label: current.label,
        pemasukan:
            item.isMasuk ? current.pemasukan + item.jumlah : current.pemasukan,
        pengeluaran:
            item.isKeluar ? current.pengeluaran + item.jumlah : current.pengeluaran,
      );
    }

    final list = hasil.values.toList();
    list.sort((a, b) => b.label.compareTo(a.label));
    return list;
  }

  List<RekapKeuanganModel> getRekapBahanBulanan(
    List<MutasiBahanBakuModel> data,
  ) {
    final Map<String, RekapKeuanganModel> hasil = {};

    for (final item in data) {
      final tanggal = item.createdAt.toLocal();

      final key =
          '${tanggal.year}-${tanggal.month.toString().padLeft(2, '0')}';

      if (!hasil.containsKey(key)) {
        hasil[key] = RekapKeuanganModel(
          label: key,
          pemasukan: 0,
          pengeluaran: 0,
        );
      }

      final current = hasil[key]!;

      hasil[key] = RekapKeuanganModel(
        label: current.label,
        pemasukan:
            item.isMasuk ? current.pemasukan + item.jumlah : current.pemasukan,
        pengeluaran:
            item.isKeluar ? current.pengeluaran + item.jumlah : current.pengeluaran,
      );
    }

    final list = hasil.values.toList();
    list.sort((a, b) => b.label.compareTo(a.label));
    return list;
  }

  DateTime startOfWeek(DateTime date) {
    final onlyDate = DateTime(date.year, date.month, date.day);
    final diff = onlyDate.weekday - DateTime.monday;
    return onlyDate.subtract(Duration(days: diff));
  }

  List<RekapKeuanganModel> getRekapMingguan(List<Map<String, dynamic>> data) {
    final Map<String, RekapKeuanganModel> hasil = {};

    for (final item in data) {
      final tanggal = DateTime.parse(item['tanggal']).toLocal();
      final jenis = (item['jenis'] ?? '').toString().toLowerCase();
      final nominal = (item['nominal'] as num?)?.toInt() ?? 0;

      final awalMinggu = startOfWeek(tanggal);

      final key =
          '${awalMinggu.year}-${awalMinggu.month.toString().padLeft(2, '0')}-${awalMinggu.day.toString().padLeft(2, '0')}';

      if (!hasil.containsKey(key)) {
        hasil[key] = RekapKeuanganModel(
          label: 'Minggu $key',
          pemasukan: 0,
          pengeluaran: 0,
        );
      }

      final current = hasil[key]!;

      hasil[key] = RekapKeuanganModel(
        label: current.label,
        pemasukan: jenis == 'pemasukan'
            ? current.pemasukan + nominal
            : current.pemasukan,
        pengeluaran: jenis == 'pengeluaran'
            ? current.pengeluaran + nominal
            : current.pengeluaran,
      );
    }

    final list = hasil.values.toList();
    list.sort((a, b) => b.label.compareTo(a.label));
    return list;
  }

  List<RekapKeuanganModel> getRekapBulanan(List<Map<String, dynamic>> data) {
    final Map<String, RekapKeuanganModel> hasil = {};

    for (final item in data) {
      final tanggal = DateTime.parse(item['tanggal']).toLocal();
      final jenis = (item['jenis'] ?? '').toString().toLowerCase();
      final nominal = (item['nominal'] as num?)?.toInt() ?? 0;

      final key = '${tanggal.year}-${tanggal.month.toString().padLeft(2, '0')}';

      if (!hasil.containsKey(key)) {
        hasil[key] = RekapKeuanganModel(
          label: key,
          pemasukan: 0,
          pengeluaran: 0,
        );
      }

      final current = hasil[key]!;

      hasil[key] = RekapKeuanganModel(
        label: current.label,
        pemasukan: jenis == 'pemasukan'
            ? current.pemasukan + nominal
            : current.pemasukan,
        pengeluaran: jenis == 'pengeluaran'
            ? current.pengeluaran + nominal
            : current.pengeluaran,
      );
    }

    final list = hasil.values.toList();
    list.sort((a, b) => b.label.compareTo(a.label));
    return list;
  }

  @override
  void onInit() {
    super.onInit();
    getMutasiBahanBaku();
    getBahan();
    getPengeluaran();
    getSemuaKeuangan();
    fetchCompletedOrders();
    fetchDetailKeuangan();
  }
}