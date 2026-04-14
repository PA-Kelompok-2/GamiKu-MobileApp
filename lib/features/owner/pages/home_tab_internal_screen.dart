import 'package:flutter/material.dart';
import '/core/constants/app_colors.dart';
import '/core/services/supabase_services.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import '/routes/app_routes.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeTabInternalScreen extends StatefulWidget {

  final VoidCallback? onOpenOrders;

  const HomeTabInternalScreen({
    super.key,
    this.onOpenOrders,
  });

  @override
  State<HomeTabInternalScreen> createState() => _HomeTabInternalScreenState();
}

class _HomeTabInternalScreenState extends State<HomeTabInternalScreen> {

  final service = SupabaseService();

  String role = '';
  bool isLoading = true;

  int pending = 0;
  int processed = 0;
  int completed = 0;

  int pemasukan = 0;
  int pengeluaran = 0;
  int saldo = 0;
  int totalMenu = 0;

  @override
  void initState() {
    super.initState();
    loadProfile();
    loadOrders();
    loadStatistik();
  }

  Future<void> loadProfile() async {
    final data = await service.getProfile();

    if (data != null) {
      setState(() {
        role = data['role'];
        isLoading = false;
      });
    }
  }

  Future<void> loadOrders() async {

    final data = await service.getOrdersWithItems();

    pending = data.where((o) => o['status'] == 'pending').length;
    processed = data.where((o) => o['status'] == 'paid').length;
    completed = data.where((o) => o['status'] == 'completed').length;

    setState(() {});
  }

  Future<void> loadStatistik() async {
    final menu = await Supabase.instance.client.from('menus').select();
    totalMenu = menu.length;
    final completedOrders = await Supabase.instance.client
        .from('orders')
        .select('total_price, status')
        .eq('status', 'completed');
    pemasukan = completedOrders.fold<int>(
      0,
      (sum, item) => sum + ((item['total_price'] ?? 0) as num).toInt(),
    );
    final pengeluaranData = await Supabase.instance.client
        .from('keuangan')
        .select('nominal, jenis')
        .eq('jenis', 'pengeluaran');
    pengeluaran = pengeluaranData.fold<int>(
      0,
      (sum, item) => sum + ((item['nominal'] ?? 0) as num).toInt(),
    );
    saldo = pemasukan - pengeluaran;
    setState(() {});
  }

  String formatRupiah(int value) {
    return 'Rp ${NumberFormat.decimalPattern('id').format(value)}';
  }

  @override
  Widget build(BuildContext context) {

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const SizedBox(height: 10),

              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadow,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Image.asset('assets/logo.png', height: 24),
                        const SizedBox(width: 8),
                        const Text(
                          'GAMIKU',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Text(
                            role == "owner"
                                ? "Welcome Owner!"
                                : "Welcome Karyawan!",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          const SizedBox(height: 6),

                          const Text(
                            "Kelola semua data usaha kamu disini",
                            style: TextStyle(color: Colors.grey),
                          ),

                        ],
                      ),
                    ),

                    Image.asset(
                      'assets/owner.png',
                      width: 100,
                    ),

                  ],
                ),
              ),

              const SizedBox(height: 28),

              if(role == "owner") ...[

                const Text(
                  "Statistik Hari Ini",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 12),

                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 2.2,
                  children: [

                    _statCard("Pemasukan", formatRupiah(pemasukan), Icons.payments_outlined, Colors.green),
                    _statCard("Pengeluaran", formatRupiah(pengeluaran), Icons.money_off_csred_outlined, Colors.red),
                    _statCard("Saldo", formatRupiah(saldo), Icons.account_balance_wallet_outlined, AppColors.primary),
                    _statCard("Total Menu", "$totalMenu Menu", Icons.restaurant_menu, Colors.orange),

                  ],
                ),

                const SizedBox(height: 28),

              ],

              if(role == "karyawan") ...[

                const Text(
                  "Pesanan Hari Ini",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 12),

                Row(
                  children: [

                    Expanded(child: _orderCard("Menunggu", pending, Colors.orange)),
                    const SizedBox(width: 10),
                    Expanded(child: _orderCard("Diproses", processed, Colors.blue)),
                    const SizedBox(width: 10),
                    Expanded(child: _orderCard("Selesai", completed, Colors.green)),

                  ],
                ),

                const SizedBox(height: 24),
              ],

              const Text(
                "Kelola Usaha",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 12),

              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.05,
                children: [
                  if(role == "owner") ...[

                    _menuCard(
                      "Bahan Baku",
                      "Kelola stok bahan",
                      Icons.countertops_outlined,
                      () => Get.toNamed(Routes.bahanBaku),
                    ),

                    _menuCard(
                      "Keuangan",
                      "Laporan usaha",
                      Icons.account_balance_wallet_outlined,
                      () => Get.toNamed(Routes.keuangan),
                    ),

                    _menuCard(
                      "Karyawan",
                      "Kelola tim",
                      Icons.people_outline,
                      () => Get.toNamed(Routes.karyawanManagement),
                    ),

                    _menuCard(
                      "Kelola Menu",
                      "Kelola menu makanan",
                      Icons.restaurant_menu,
                      () => Get.toNamed(Routes.menuManagement),
                    ),

                  ] else ...[

                    _menuCard(
                      "Kelola Menu",
                      "Kelola menu makanan",
                      Icons.restaurant_menu,
                      () => Get.toNamed(Routes.menuManagement),
                    ),

                    _menuCard(
                      "Bahan Baku",
                      "Kelola stok bahan",
                      Icons.countertops_outlined,
                      () => Get.toNamed(Routes.bahanBaku),
                    ),

                  ],

                ],
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _orderCard(String title, int value, Color color) {
    return GestureDetector(
      onTap: widget.onOpenOrders,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text("$value",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: color)),
            const SizedBox(height: 4),
            Text(title,style: const TextStyle(fontSize: 12,color: AppColors.textGrey)),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String title,String value,IconData icon,Color color){
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: AppColors.shadow,blurRadius: 6,offset: const Offset(0,2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon,color: color,size: 22),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,style: const TextStyle(fontSize: 12,color: AppColors.textGrey)),
              const SizedBox(height: 2),
              Text(value,style: const TextStyle(fontSize: 14,fontWeight: FontWeight.w800)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _menuCard(String title,String subtitle,IconData icon,VoidCallback onTap){
    return Material(
      color: AppColors.red55,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(title,style: const TextStyle(fontSize: 16,fontWeight: FontWeight.bold))),
                  Icon(icon,color: AppColors.primary),
                ],
              ),

              const SizedBox(height: 10),

              Text(subtitle,style: const TextStyle(fontSize: 13)),

              const Spacer(),

              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Buka",style: TextStyle(fontWeight: FontWeight.w600,color: AppColors.primary)),
                  Icon(Icons.arrow_forward,color: AppColors.primary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}