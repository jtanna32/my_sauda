import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/party.dart';

class PartiesService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Party>> fetchParties() async {
    final response = await _client
        .from('parties')
        .select()
        .order('created_at', ascending: false);

    return (response as List)
        .map((e) => Party.fromJson(e))
        .toList();
  }

  Future<Party> createParty({
    required String partyName,
    required String city,
    required String state,
    double? brokerageRate,
    String? panGstin,
    String? deliveryAddress,
  }) async {
    final userId = _client.auth.currentUser!.id;

    final response = await _client.rpc('create_party', params: {
      'p_user_id': userId,
      'p_party_name': partyName,
      'p_brokerage_rate': brokerageRate,
      'p_city': city,
      'p_state': state,
      'p_pan_gstin': panGstin,
      'p_delivery_address': deliveryAddress,
    });

    return Party.fromJson(response);
  }

  Future<Party> updateParty({
    required String partyId,
    required String partyName,
    required String city,
    required String state,
    double? brokerageRate,
    String? panGstin,
    String? deliveryAddress,
  }) async {
    final userId = _client.auth.currentUser!.id;

    final response = await _client.rpc('update_party', params: {
      'p_id': partyId,
      'p_user_id': userId,
      'p_party_name': partyName,
      'p_brokerage_rate': brokerageRate,
      'p_city': city,
      'p_state': state,
      'p_pan_gstin': panGstin,
      'p_delivery_address': deliveryAddress,
    });

    return Party.fromJson(response);
  }

  Future<void> deleteParty(String partyId) async {
    final userId = _client.auth.currentUser!.id;

    await _client.rpc('delete_party', params: {
      'p_id': partyId,
      'p_user_id': userId,
    });
  }
}