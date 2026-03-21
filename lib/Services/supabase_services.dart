import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final supabase = Supabase.instance.client;

  Future<AuthResponse> login(String email, String password) {
    return supabase.auth.signInWithPassword(email: email, password: password);
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
        .single();

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
}
