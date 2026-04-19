import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math';
import 'dart:io';
import 'package:path/path.dart';

class SupabaseService {
  final supabase = Supabase.instance.client;

  Future<AuthResponse> login(String email, String password) async {
    return await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> register(String email, String password) {
    return supabase.auth.signUp(email: email, password: password);
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
  }

  User? get currentUser => supabase.auth.currentUser;

  Future<void> setRole(String role) async {
    final user = supabase.auth.currentUser;

    await supabase.from('profiles').update({'role': role}).eq('id', user!.id);
  }

  Future<String?> getRole() async {
    final user = supabase.auth.currentUser;

    if (user == null) return null;

    final data = await supabase
        .from('profiles')
        .select('role')
        .eq('id', user.id)
        .maybeSingle();

    return data?['role'];
  }

  Future<void> insertProfile({
    required String id,
    required String email,
    required String name,
  }) async {
    await supabase.from('profiles').insert({
      'id': id,
      'email': email,
      'name': name,
      'role': 'pembeli',
    });
  }

  Future<Map<String, dynamic>?> getProfile() async {
    final user = supabase.auth.currentUser;

    if (user == null) return null;

    final data = await supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    return data;
  }

  Future<String?> getUserRole() async {
    final user = supabase.auth.currentUser;

    if (user == null) return null;

    final data = await supabase
        .from('profiles')
        .select('role')
        .eq('id', user.id)
        .single();

    return data['role'];
  }

  Future<List<Map<String, dynamic>>> getMenus() async {
    final res = await supabase
        .from('menus')
        .select('*, categories(name)')
        .order('created_at');

    return List<Map<String, dynamic>>.from(res);
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    final res = await supabase.from('categories').select().order('name');

    return List<Map<String, dynamic>>.from(res);
  }

  Future<void> addMenu({
    required String name,
    required int price,
    String? imageUrl,
    required String categoryId,
  }) async {
    final data = {'name': name, 'price': price, 'category_id': categoryId};

    if (imageUrl != null && imageUrl.trim().isNotEmpty) {
      data['image_url'] = imageUrl;
    }

    await supabase.from('menus').insert(data);
  }

  Future<void> updateMenu({
    required dynamic id,
    required String name,
    required int price,
    String? imageUrl,
    required String categoryId,
  }) async {
    final data = {'name': name, 'price': price, 'category_id': categoryId};

    if (imageUrl != null && imageUrl.trim().isNotEmpty) {
      data['image_url'] = imageUrl;
    }

    await supabase.from('menus').update(data).eq('id', id);
  }

  Future<void> deleteMenu(dynamic id) async {
    await supabase.from('menus').delete().eq('id', id);
  }

  Future<void> updateMenuAvailability(String id, bool isAvailable) async {
    await supabase
        .from('menus')
        .update({'is_available': isAvailable})
        .eq('id', id);
  }

  Future<List<Map<String, dynamic>>> getOrders() async {
    final res = await supabase
        .from('orders')
        .select('*, order_items(*, menus(*))')
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(res);
  }

  Future<void> updateOrderStatus(String id, String status) async {
    await supabase.from('orders').update({'status': status}).eq('id', id);
  }

  String generateToken() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';

    return List.generate(
      20,
      (index) => chars[Random().nextInt(chars.length)],
    ).join();
  }

  Future<Map<String, dynamic>> createOrder({
    required int total,
    required List<Map<String, dynamic>> items,
    required String orderType,
    required String paymentMethod,
  }) async {
    final user = supabase.auth.currentUser;
    final token = generateToken();

    final order = await supabase
        .from('orders')
        .insert({
          'user_id': user!.id,
          'total_price': total,
          'status': 'pending',
          'payment_status': 'pending',
          'payment_method': paymentMethod,
          'qr_token': token,
          'order_type': orderType,
        })
        .select()
        .single();

    final orderId = order['id'];

    final orderItems = items.map((i) {
      return {
        'order_id': orderId,
        'menu_id': i['id'],
        'quantity': i['qty'],
        'price': i['price'],
      };
    }).toList();

    await supabase.from('order_items').insert(orderItems);

    return order;
  }

  Future<List<Map<String, dynamic>>> getOrdersWithItems() async {
    final res = await supabase
        .from('orders')
        .select('*, order_items(*, menus(*))')
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(res);
  }

  Future<List<Map<String, dynamic>>> getKaryawan() async {
    final res = await supabase
        .from('profiles')
        .select()
        .eq('role', 'karyawan')
        .order('name');

    return List<Map<String, dynamic>>.from(res);
  }

  Future<void> addKaryawan({
    required String name,
    required String email,
    required String password,
  }) async {
    final session = Supabase.instance.client.auth.currentSession;

    if (session == null) {
      throw Exception("User belum login (session null)");
    }

    final res = await supabase.functions.invoke(
      'create-karyawan',
      body: {'name': name, 'email': email, 'password': password},
    );

    if (res.status != 200) {
      final msg = res.data is Map<String, dynamic>
          ? (res.data['error'] ?? 'Gagal tambah karyawan')
          : 'Gagal tambah karyawan';

      throw Exception(msg);
    }
  }

  Future<void> updateKaryawan({
    required String id,
    required String name,
    required String email,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    final existing = await supabase
        .from('profiles')
        .select('id')
        .eq('email', normalizedEmail)
        .maybeSingle();

    if (existing != null && existing['id'] != id) {
      throw Exception('Email sudah digunakan');
    }

    await supabase
        .from('profiles')
        .update({'name': name.trim(), 'email': normalizedEmail})
        .eq('id', id);
  }

  Future<void> deleteKaryawan(String id) async {
    await supabase.from('profiles').delete().eq('id', id);
  }

  Future<Map<String, dynamic>?> getOrderByToken(String token) async {
    final data = await supabase
        .from('orders')
        .select()
        .eq('qr_token', token)
        .maybeSingle();

    return data;
  }

  Future<void> markAsPaid(String id) async {
    await supabase
        .from('orders')
        .update({'payment_status': 'success', 'status': 'paid'})
        .eq('id', id);
  }

  Future<String> uploadMenuImage(File file) async {
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${basename(file.path)}';

    final path = fileName;

    await supabase.storage
        .from('menu-images')
        .upload(path, file, fileOptions: const FileOptions(upsert: true));

    final publicUrl = supabase.storage.from('menu-images').getPublicUrl(path);
    return publicUrl;
  }

  Future<void> uploadPaymentProof(String orderId, String imageUrl) async {
    await supabase
        .from('orders')
        .update({
          'payment_proof': imageUrl,
          'payment_method': 'midtrans',
          'payment_status': 'pending',
        })
        .eq('id', orderId)
        .select();
  }

  Future<void> confirmPayment(String orderId) async {
    await supabase
        .from('orders')
        .update({'payment_status': 'failed', 'status': 'cancelled'})
        .eq('id', orderId);
  }

  Future<Map<String, dynamic>?> getOrderById(String id) async {
    final res = await supabase
        .from('orders')
        .select(
          'id, total_price, status, payment_status, payment_method, payment_proof, order_items(*, menus(*))',
        )
        .eq('id', id)
        .maybeSingle();

    return res;
  }

  Future<void> markAsFailed(String id) async {
    await supabase
        .from('orders')
        .update({'payment_status': 'failed', 'status': 'cancelled'})
        .eq('id', id);
  }

  Future<void> cancelOrder(String id) async {
    await supabase
        .from('orders')
        .update({'status': 'cancelled', 'payment_status': 'failed'})
        .eq('id', id);
  }

  void listenOrder(String orderId, Function(Map) callback) {
    supabase
        .channel('orders-realtime')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'orders',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: orderId,
          ),
          callback: (payload) {
            final data = payload.newRecord;
            print("REALTIME PAYLOAD: $data");

            callback(data);
          },
        )
        .subscribe();
  }
}
