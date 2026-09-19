import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/firm.dart';

class FirmsService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Firm>> fetchFirms() async {
    debugPrint('[FirmsService] fetchFirms called');
    try {
      final response = await _client
          .from('firms')
          .select()
          .order('created_at', ascending: false);
      debugPrint('[FirmsService] fetchFirms returned ${(response as List).length} records');
      return response.map((e) => Firm.fromJson(e)).toList();
    } on PostgrestException catch (e) {
      debugPrint('[FirmsService] fetchFirms error — message: ${e.message}, code: ${e.code}, details: ${e.details}, hint: ${e.hint}');
      rethrow;
    }
  }

  Future<Firm> createFirm({
    required String firmName,
    String? proprietorName,
    String? phoneNumber,
    String? alternatePhoneNumber,
    String? gstin,
    String? pan,
    String? address,
    String? bankName,
    String? bankIfsc,
    String? bankAccountNumber,
    String? bankAccountName,
  }) async {
    debugPrint('[FirmsService] createFirm called — name: $firmName');
    try {
      final response = await _client.rpc('create_firm', params: {
        'p_firm_name': firmName,
        'p_proprietor_name': proprietorName,
        'p_phone_number': phoneNumber,
        'p_alternate_phone_number': alternatePhoneNumber,
        'p_gstin': gstin,
        'p_pan': pan,
        'p_address': address,
        'p_bank_name': bankName,
        'p_bank_ifsc': bankIfsc,
        'p_bank_account_number': bankAccountNumber,
        'p_bank_account_name': bankAccountName,
      });
      debugPrint('[FirmsService] createFirm response: $response');
      return Firm.fromJson(response);
    } on PostgrestException catch (e) {
      debugPrint('[FirmsService] createFirm error — message: ${e.message}, code: ${e.code}, details: ${e.details}, hint: ${e.hint}');
      rethrow;
    }
  }

  Future<Firm> updateFirm({
    required String firmId,
    required String firmName,
    String? proprietorName,
    String? phoneNumber,
    String? alternatePhoneNumber,
    String? gstin,
    String? pan,
    String? address,
    String? bankName,
    String? bankIfsc,
    String? bankAccountNumber,
    String? bankAccountName,
  }) async {
    debugPrint('[FirmsService] updateFirm called — id: $firmId, name: $firmName');
    try {
      final response = await _client.rpc('update_firm', params: {
        'p_firm_id': firmId,
        'p_firm_name': firmName,
        'p_proprietor_name': proprietorName,
        'p_phone_number': phoneNumber,
        'p_alternate_phone_number': alternatePhoneNumber,
        'p_gstin': gstin,
        'p_pan': pan,
        'p_address': address,
        'p_bank_name': bankName,
        'p_bank_ifsc': bankIfsc,
        'p_bank_account_number': bankAccountNumber,
        'p_bank_account_name': bankAccountName,
      });
      debugPrint('[FirmsService] updateFirm response: $response');
      return Firm.fromJson(response);
    } on PostgrestException catch (e) {
      debugPrint('[FirmsService] updateFirm error — message: ${e.message}, code: ${e.code}, details: ${e.details}, hint: ${e.hint}');
      rethrow;
    }
  }

  Future<void> deleteFirm(String firmId) async {
    debugPrint('[FirmsService] deleteFirm called — id: $firmId');
    try {
      await _client.rpc('delete_firm', params: {
        'p_firm_id': firmId,
      });
      debugPrint('[FirmsService] deleteFirm success');
    } on PostgrestException catch (e) {
      debugPrint('[FirmsService] deleteFirm error — message: ${e.message}, code: ${e.code}, details: ${e.details}, hint: ${e.hint}');
      rethrow;
    }
  }
}
