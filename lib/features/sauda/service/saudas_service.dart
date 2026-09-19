import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/sauda.dart';

class SaudasService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Sauda>> fetchSaudas() async {
    debugPrint('[SaudasService] fetchSaudas called');
    try {
      final response = await _client.from('saudas').select('''
        *,
        buyer_party:parties!buyer_party_id(id, party_name, party_code, brokerage_rate, delivery_address),
        seller_party:parties!seller_party_id(id, party_name, party_code, brokerage_rate),
        item:items!item_id(id, item_name),
        unit:units!unit_id(id, name)
      ''').order('created_at', ascending: false);
      debugPrint(
          '[SaudasService] fetchSaudas returned ${(response as List).length} records');
      return response.map((e) => Sauda.fromJson(e)).toList();
    } on PostgrestException catch (e) {
      debugPrint(
          '[SaudasService] fetchSaudas error — message: ${e.message}, code: ${e.code}, details: ${e.details}, hint: ${e.hint}');
      rethrow;
    }
  }

  Future<Sauda> createSauda({
    required DateTime saudaDate,
    required String itemId,
    required double quantity,
    required double totalKg,
    required String unitId,
    String? bagType,
    double? numberOfBags,
    required double ratePerQuintal,
    required String buyerPartyId,
    required double buyerSideBrokerage,
    required String sellerPartyId,
    required double sellerSideBrokerage,
    String? quantityRemarks,
    String? specification,
    String? loadingCondition,
    String? paymentCondition,
    String? deliveryAddress,
    String? additionalRemarks,
    required bool sendToParties,
  }) async {
    debugPrint('[SaudasService] createSauda called');
    try {
      final response = await _client.rpc('create_sauda', params: {
        'p_sauda_date': '${saudaDate.year}-${saudaDate.month.toString().padLeft(2, '0')}-${saudaDate.day.toString().padLeft(2, '0')}',
        'p_item_id': itemId,
        'p_quantity': quantity,
        'p_total_kg': totalKg,
        'p_unit_id': unitId,
        'p_bag_type': bagType,
        'p_number_of_bags': numberOfBags,
        'p_rate_per_quintal': ratePerQuintal,
        'p_buyer_party_id': buyerPartyId,
        'p_buyer_side_brokerage': buyerSideBrokerage,
        'p_seller_party_id': sellerPartyId,
        'p_seller_side_brokerage': sellerSideBrokerage,
        'p_quantity_remarks': quantityRemarks,
        'p_specification': specification,
        'p_loading_condition': loadingCondition,
        'p_payment_condition': paymentCondition,
        'p_delivery_address': deliveryAddress,
        'p_additional_remarks': additionalRemarks,
        'p_send_to_parties': sendToParties,
      });
      debugPrint('[SaudasService] createSauda response: $response');
      return Sauda.fromJson(response);
    } on PostgrestException catch (e) {
      debugPrint(
          '[SaudasService] createSauda error — message: ${e.message}, code: ${e.code}, details: ${e.details}, hint: ${e.hint}');
      rethrow;
    }
  }

  Future<Sauda> updateSauda({
    required String saudaId,
    required DateTime saudaDate,
    required String itemId,
    required double quantity,
    required double totalKg,
    required String unitId,
    String? bagType,
    double? numberOfBags,
    required double ratePerQuintal,
    required String buyerPartyId,
    required double buyerSideBrokerage,
    required String sellerPartyId,
    required double sellerSideBrokerage,
    String? quantityRemarks,
    String? specification,
    String? loadingCondition,
    String? paymentCondition,
    String? deliveryAddress,
    String? additionalRemarks,
    required bool sendToParties,
  }) async {
    debugPrint('[SaudasService] updateSauda called — id: $saudaId');
    try {
      final response = await _client.rpc('update_sauda', params: {
        'p_sauda_id': saudaId,
        'p_sauda_date': '${saudaDate.year}-${saudaDate.month.toString().padLeft(2, '0')}-${saudaDate.day.toString().padLeft(2, '0')}',
        'p_item_id': itemId,
        'p_quantity': quantity,
        'p_total_kg': totalKg,
        'p_unit_id': unitId,
        'p_bag_type': bagType,
        'p_number_of_bags': numberOfBags,
        'p_rate_per_quintal': ratePerQuintal,
        'p_buyer_party_id': buyerPartyId,
        'p_buyer_side_brokerage': buyerSideBrokerage,
        'p_seller_party_id': sellerPartyId,
        'p_seller_side_brokerage': sellerSideBrokerage,
        'p_quantity_remarks': quantityRemarks,
        'p_specification': specification,
        'p_loading_condition': loadingCondition,
        'p_payment_condition': paymentCondition,
        'p_delivery_address': deliveryAddress,
        'p_additional_remarks': additionalRemarks,
        'p_send_to_parties': sendToParties,
      });
      debugPrint('[SaudasService] updateSauda response: $response');
      return Sauda.fromJson(response);
    } on PostgrestException catch (e) {
      debugPrint(
          '[SaudasService] updateSauda error — message: ${e.message}, code: ${e.code}, details: ${e.details}, hint: ${e.hint}');
      rethrow;
    }
  }

  Future<void> deleteSauda(String saudaId) async {
    debugPrint('[SaudasService] deleteSauda called — id: $saudaId');
    try {
      await _client.rpc('delete_sauda', params: {
        'p_sauda_id': saudaId,
      });
      debugPrint('[SaudasService] deleteSauda success');
    } on PostgrestException catch (e) {
      debugPrint(
          '[SaudasService] deleteSauda error — message: ${e.message}, code: ${e.code}, details: ${e.details}, hint: ${e.hint}');
      rethrow;
    }
  }
}
