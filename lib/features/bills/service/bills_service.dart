import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/bill.dart';

class BillsService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Bill>> fetchBills() async {
    debugPrint('[BillsService] fetchBills called');
    try {
      final response = await _client
          .from('bills')
          .select('payload')
          .order('created_at', ascending: false);
      debugPrint(
          '[BillsService] fetchBills returned ${(response as List).length} records');
      return response
          .map((e) => Bill.fromJson(e['payload'] as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      debugPrint(
          '[BillsService] fetchBills error — message: ${e.message}, code: ${e.code}, details: ${e.details}, hint: ${e.hint}');
      rethrow;
    }
  }

  // The database assigns the bill number, so the returned bill is the one to print.
  Future<Bill> createBill(Bill draft) async {
    debugPrint('[BillsService] createBill called — party: ${draft.partyName}');
    try {
      final response = await _client.rpc('create_bill', params: {
        'p_payload': draft.toJson(),
      });
      debugPrint('[BillsService] createBill response: $response');
      return Bill.fromJson(response['payload'] as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      debugPrint(
          '[BillsService] createBill error — message: ${e.message}, code: ${e.code}, details: ${e.details}, hint: ${e.hint}');
      rethrow;
    }
  }

  Future<void> deleteBill(String billNumber) async {
    debugPrint('[BillsService] deleteBill called — number: $billNumber');
    try {
      await _client.rpc('delete_bill', params: {
        'p_bill_number': billNumber,
      });
      debugPrint('[BillsService] deleteBill success');
    } on PostgrestException catch (e) {
      debugPrint(
          '[BillsService] deleteBill error — message: ${e.message}, code: ${e.code}, details: ${e.details}, hint: ${e.hint}');
      rethrow;
    }
  }
}
