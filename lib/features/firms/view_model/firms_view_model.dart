import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/firm.dart';
import '../service/firms_service.dart';

final firmsViewModelProvider =
    StateNotifierProvider<FirmsViewModel, FirmsState>(
  (ref) => FirmsViewModel(FirmsService()),
);

class FirmsState {
  final bool isLoading;
  final List<Firm> firms;
  final List<Firm> allFirms;
  final String? errorMessage;
  final String? successMessage;
  final String searchQuery;

  const FirmsState({
    this.isLoading = false,
    this.firms = const [],
    this.allFirms = const [],
    this.errorMessage,
    this.successMessage,
    this.searchQuery = '',
  });

  FirmsState copyWith({
    bool? isLoading,
    List<Firm>? firms,
    List<Firm>? allFirms,
    String? errorMessage,
    String? successMessage,
    String? searchQuery,
  }) {
    return FirmsState(
      isLoading: isLoading ?? this.isLoading,
      firms: firms ?? this.firms,
      allFirms: allFirms ?? this.allFirms,
      errorMessage: errorMessage,
      successMessage: successMessage,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class FirmsViewModel extends StateNotifier<FirmsState> {
  final FirmsService _service;

  FirmsViewModel(this._service) : super(const FirmsState());

  Future<void> loadFirms() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final firms = await _service.fetchFirms();
      state = state.copyWith(
        isLoading: false,
        firms: firms,
        allFirms: firms,
      );
    } catch (e) {
      debugPrint('[FirmsViewModel] loadFirms error: $e');
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void searchFirms(String query) {
    final lower = query.toLowerCase();

    final filtered = state.allFirms.where((f) {
      return f.firmName.toLowerCase().contains(lower) ||
          (f.proprietorName?.toLowerCase().contains(lower) ?? false) ||
          (f.phoneNumber?.toLowerCase().contains(lower) ?? false);
    }).toList();

    state = state.copyWith(
      searchQuery: query,
      firms: filtered,
    );
  }

  Future<bool> createFirm({
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
    state = state.copyWith(isLoading: true);

    try {
      await _service.createFirm(
        firmName: firmName,
        proprietorName: proprietorName,
        phoneNumber: phoneNumber,
        alternatePhoneNumber: alternatePhoneNumber,
        gstin: gstin,
        pan: pan,
        address: address,
        bankName: bankName,
        bankIfsc: bankIfsc,
        bankAccountNumber: bankAccountNumber,
        bankAccountName: bankAccountName,
      );

      await loadFirms();
      return true;
    } catch (e) {
      debugPrint('[FirmsViewModel] error: $e');
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> updateFirm({
    required String id,
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
    state = state.copyWith(isLoading: true);

    try {
      await _service.updateFirm(
        firmId: id,
        firmName: firmName,
        proprietorName: proprietorName,
        phoneNumber: phoneNumber,
        alternatePhoneNumber: alternatePhoneNumber,
        gstin: gstin,
        pan: pan,
        address: address,
        bankName: bankName,
        bankIfsc: bankIfsc,
        bankAccountNumber: bankAccountNumber,
        bankAccountName: bankAccountName,
      );

      await loadFirms();
      return true;
    } catch (e) {
      debugPrint('[FirmsViewModel] error: $e');
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> deleteFirm(String id) async {
    try {
      await _service.deleteFirm(id);
      await loadFirms();
      return true;
    } catch (e) {
      debugPrint('[FirmsViewModel] deleteFirm error: $e');
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  void clearMessages() {
    state = state.copyWith(
      errorMessage: null,
      successMessage: null,
    );
  }
}
