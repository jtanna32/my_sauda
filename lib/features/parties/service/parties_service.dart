import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/party.dart';

class PartiesService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Party>> fetchParties() async {
    debugPrint('[PartiesService] fetchParties called');
    try {
      final response = await _client
          .from('parties')
          .select()
          .order('created_at', ascending: false);
      debugPrint(
          '[PartiesService] fetchParties returned ${(response as List).length} records');
      return response.map((e) => Party.fromJson(e)).toList();
    } on PostgrestException catch (e) {
      debugPrint(
          '[PartiesService] fetchParties error — message: ${e.message}, code: ${e.code}, details: ${e.details}, hint: ${e.hint}');
      rethrow;
    }
  }

  Future<Party> createParty({
    required String partyName,
    required String city,
    required String state,
    double? brokerageRate,
    String? panGstin,
    String? deliveryAddress,
    String? phoneNumber,
    String? alternatePhoneNumber,
  }) async {
    final userId = _client.auth.currentUser!.id;
    debugPrint(
        '[PartiesService] createParty called — name: $partyName, city: $city, state: $state');

    try {
      final response = await _client.rpc(
        'create_party',
        params: {
          'p_party_name': partyName,
          'p_brokerage_rate': brokerageRate,
          'p_city': city,
          'p_state': state,
          'p_pan_gstin': panGstin,
          'p_delivery_address': deliveryAddress,
          'p_phone_number': phoneNumber?.isEmpty == true ? null : phoneNumber,
          'p_alternate_phone_number': alternatePhoneNumber?.isEmpty == true
              ? null
              : alternatePhoneNumber,
        },
      );

      debugPrint('[PartiesService] createParty response: $response');
      return Party.fromJson(response);
    } on PostgrestException catch (e) {
      debugPrint(
          '[PartiesService] createParty error — message: ${e.message}, code: ${e.code}, details: ${e.details}, hint: ${e.hint}');
      rethrow;
    }
  }

  Future<Party> updateParty({
    required String partyId,
    required String partyName,
    required String city,
    required String state,
    double? brokerageRate,
    String? panGstin,
    String? deliveryAddress,
    String? phoneNumber,
    String? alternatePhoneNumber,
  }) async {
    final userId = _client.auth.currentUser!.id;
    debugPrint(
        '[PartiesService] updateParty called — id: $partyId, name: $partyName');

    try {
      final response = await _client.rpc(
        'update_party',
        params: {
          'p_party_id': partyId, 
          'p_party_name': partyName,
          'p_brokerage_rate': brokerageRate,
          'p_city': city,
          'p_state': state,
          'p_pan_gstin': panGstin,
          'p_delivery_address': deliveryAddress,
          'p_phone_number': phoneNumber?.isEmpty == true ? null : phoneNumber,
          'p_alternate_phone_number': alternatePhoneNumber?.isEmpty == true
              ? null
              : alternatePhoneNumber,
        },
      );
      debugPrint('[PartiesService] updateParty response: $response');
      return Party.fromJson(response);
    } on PostgrestException catch (e) {
      debugPrint(
          '[PartiesService] updateParty error — message: ${e.message}, code: ${e.code}, details: ${e.details}, hint: ${e.hint}');
      rethrow;
    }
  }

  Future<void> deleteParty(String partyId) async {
    final userId = _client.auth.currentUser!.id;
    debugPrint('[PartiesService] deleteParty called — id: $partyId');

    try {
      await _client.rpc('delete_party', params: {
        'p_id': partyId,
        'p_user_id': userId,
      });
      debugPrint('[PartiesService] deleteParty success');
    } on PostgrestException catch (e) {
      debugPrint(
          '[PartiesService] deleteParty error — message: ${e.message}, code: ${e.code}, details: ${e.details}, hint: ${e.hint}');
      rethrow;
    }
  }
}
