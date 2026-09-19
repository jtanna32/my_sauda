import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final SupabaseClient _client = Supabase.instance.client;

  Future<void> register({
    required String email,
    required String password,
    String? fullName,
    String? phone,
  }) async {
    await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        if (fullName != null && fullName.isNotEmpty) 'full_name': fullName,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
      },
    );
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  String? get currentEmail => _client.auth.currentUser?.email;

  Future<void> logout() async {
    await _client.auth.signOut();
  }

  Future<void> resetPassword({
    required String email,
  }) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  Future<void> ensureProfile() async {
    final user = _client.auth.currentUser;

    if (user == null) return;

    final existing = await _client
        .from('profiles')
        .select('id')
        .eq('id', user.id)
        .maybeSingle();

    if (existing == null) {
      final metadata = user.userMetadata;

      await _client.from('profiles').insert({
        'id': user.id,
        'email': user.email,
        'name': metadata?['full_name'],
        'company_name': metadata?['company_name'],
        'phone': metadata?['phone'],
      });
    }
  }
}
