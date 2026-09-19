import 'package:supabase_flutter/supabase_flutter.dart';

class SuggestionService {
  SuggestionService._();
  static final SuggestionService instance = SuggestionService._();

  final SupabaseClient _client = Supabase.instance.client;

  /// 📋 FETCH SUGGESTIONS BY TYPE
  Future<List<String>> fetchSuggestions(String type) async {
    final userId = _client.auth.currentUser!.id;

    final response = await _client
        .from('user_suggestions')
        .select('value')
        .eq('user_id', userId)
        .eq('type', type)
        .order('created_at', ascending: false);

    return (response as List).map((e) => e['value'] as String).toList();
  }

  /// ➕ ADD NEW SUGGESTION (WITH DUPLICATE CHECK)
  Future<void> addSuggestion({
    required String type,
    required String value,
  }) async {
    final userId = _client.auth.currentUser!.id;

    final trimmedValue = value.trim();

    if (trimmedValue.isEmpty) return;

    /// 🔍 Check duplicate
    final existing = await _client
        .from('user_suggestions')
        .select('id')
        .eq('user_id', userId)
        .eq('type', type)
        .ilike('value', trimmedValue)
        .maybeSingle();

    if (existing != null) {
      return; // already exists
    }

    /// ➕ Insert
    await _client.from('user_suggestions').insert({
      'user_id': userId,
      'type': type,
      'value': trimmedValue,
    });
  }

  /// ❌ DELETE (optional for future)
  Future<void> deleteSuggestion(String id) async {
    await _client.from('user_suggestions').delete().eq('id', id);
  }
}
