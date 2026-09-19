import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/unit.dart';

class UnitsService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Unit>> fetchUnits() async {
    debugPrint('[UnitsService] fetchUnits called');
    try {
      final response = await _client
          .from('units')
          .select()
          .order('name', ascending: true);
      debugPrint(
          '[UnitsService] fetchUnits returned ${(response as List).length} records');
      return response.map((e) => Unit.fromJson(e)).toList();
    } on PostgrestException catch (e) {
      debugPrint(
          '[UnitsService] fetchUnits error — message: ${e.message}, code: ${e.code}, details: ${e.details}, hint: ${e.hint}');
      rethrow;
    }
  }
}
