import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/item.dart';

class ItemsService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Item>> fetchItems() async {
    debugPrint('[ItemsService] fetchItems called');
    try {
      final response = await _client
          .from('items')
          .select()
          .order('item_name', ascending: true);
      debugPrint(
          '[ItemsService] fetchItems returned ${(response as List).length} records');
      return response.map((e) => Item.fromJson(e)).toList();
    } on PostgrestException catch (e) {
      debugPrint(
          '[ItemsService] fetchItems error — message: ${e.message}, code: ${e.code}, details: ${e.details}, hint: ${e.hint}');
      rethrow;
    }
  }

  Future<Item> createItem({required String name}) async {
    debugPrint('[ItemsService] createItem called — name: $name');
    try {
      final response = await _client.rpc('create_item', params: {
        'p_item_name': name,
      });
      debugPrint('[ItemsService] createItem response: $response');
      return Item.fromJson(response);
    } on PostgrestException catch (e) {
      debugPrint(
          '[ItemsService] createItem error — message: ${e.message}, code: ${e.code}, details: ${e.details}, hint: ${e.hint}');
      rethrow;
    }
  }

  Future<void> deleteItem(String id) async {
    debugPrint('[ItemsService] deleteItem called — id: $id');
    try {
      await _client.rpc('delete_item', params: {
        'p_item_id': id,
      });
      debugPrint('[ItemsService] deleteItem success');
    } on PostgrestException catch (e) {
      debugPrint(
          '[ItemsService] deleteItem error — message: ${e.message}, code: ${e.code}, details: ${e.details}, hint: ${e.hint}');
      rethrow;
    }
  }
}
