import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart' show DateTimeRange;
import 'package:my_sauda/features/auth/view_model/current_user_provider.dart';
import 'package:my_sauda/features/bills/model/bill_calculator.dart';
import 'package:my_sauda/features/parties/model/party.dart';
import 'package:my_sauda/core/utils/error_message.dart';
import '../model/sauda.dart';
import '../service/saudas_service.dart';

final saudasViewModelProvider =
    StateNotifierProvider<SaudasViewModel, SaudasState>(
  (ref) {
    ref.watch(currentUserIdProvider);
    return SaudasViewModel(SaudasService());
  },
);

class SaudasState {
  final bool isLoading;
  final List<Sauda> saudas;
  final List<Sauda> allSaudas;
  final String? errorMessage;
  final String? successMessage;
  final String searchQuery;
  final DateTimeRange? dateRangeFilter;
  final Party? partyFilter;
  final Party? buyerFilter;
  final Party? sellerFilter;

  bool get hasActiveFilters =>
      dateRangeFilter != null ||
      partyFilter != null ||
      buyerFilter != null ||
      sellerFilter != null;

  double get totalTons => saudas.fold<double>(
        0,
        (sum, s) =>
            sum +
            BillCalculator.toTons(
              BillCalculator.toQuintals(s.quantity, s.unitName),
            ),
      );

  double get totalBrokerage => BillCalculator.round2(
      saudas.fold<double>(0, (sum, s) => sum + _brokerageOf(s)));

  // With a party filter only that party's side counts; with only a buyer or seller filter, that side; otherwise both sides.
  double _brokerageOf(Sauda s) {
    final party = partyFilter;
    if (party != null) {
      if (s.buyerPartyId == party.id) return s.buyerSideBrokerage;
      if (s.sellerPartyId == party.id) return s.sellerSideBrokerage;
      return 0;
    }
    if (buyerFilter != null && sellerFilter == null) {
      return s.buyerSideBrokerage;
    }
    if (sellerFilter != null && buyerFilter == null) {
      return s.sellerSideBrokerage;
    }
    return s.buyerSideBrokerage + s.sellerSideBrokerage;
  }

  int get activeFilterCount =>
      (dateRangeFilter != null ? 1 : 0) +
      (partyFilter != null ? 1 : 0) +
      (buyerFilter != null ? 1 : 0) +
      (sellerFilter != null ? 1 : 0);

  const SaudasState({
    this.isLoading = false,
    this.saudas = const [],
    this.allSaudas = const [],
    this.errorMessage,
    this.successMessage,
    this.searchQuery = '',
    this.dateRangeFilter,
    this.partyFilter,
    this.buyerFilter,
    this.sellerFilter,
  });

  SaudasState copyWith({
    bool? isLoading,
    List<Sauda>? saudas,
    List<Sauda>? allSaudas,
    String? errorMessage,
    String? successMessage,
    String? searchQuery,
    DateTimeRange? dateRangeFilter,
    Party? partyFilter,
    Party? buyerFilter,
    Party? sellerFilter,
    bool replaceFilters = false,
  }) {
    return SaudasState(
      isLoading: isLoading ?? this.isLoading,
      saudas: saudas ?? this.saudas,
      allSaudas: allSaudas ?? this.allSaudas,
      errorMessage: errorMessage,
      successMessage: successMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      dateRangeFilter: replaceFilters
          ? dateRangeFilter
          : (dateRangeFilter ?? this.dateRangeFilter),
      partyFilter:
          replaceFilters ? partyFilter : (partyFilter ?? this.partyFilter),
      buyerFilter:
          replaceFilters ? buyerFilter : (buyerFilter ?? this.buyerFilter),
      sellerFilter:
          replaceFilters ? sellerFilter : (sellerFilter ?? this.sellerFilter),
    );
  }
}

class SaudasViewModel extends StateNotifier<SaudasState> {
  final SaudasService _service;

  SaudasViewModel(this._service) : super(const SaudasState());

  Future<void> loadSaudas() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final saudas = await _service.fetchSaudas();
      state = state.copyWith(
        isLoading: false,
        saudas: _applyFilters(
          saudas,
          state.searchQuery,
          state.dateRangeFilter,
          state.partyFilter,
          state.buyerFilter,
          state.sellerFilter,
        ),
        allSaudas: saudas,
      );
    } catch (e) {
      debugPrint('[SaudasViewModel] loadSaudas error: $e');
      state = state.copyWith(isLoading: false, errorMessage: friendlyError(e));
    }
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static List<Sauda> _applyFilters(
    List<Sauda> all,
    String query,
    DateTimeRange? range,
    Party? party,
    Party? buyer,
    Party? seller,
  ) {
    final lower = query.toLowerCase();
    return all.where((s) {
      if (range != null) {
        final d = _dateOnly(s.saudaDate);
        if (d.isBefore(_dateOnly(range.start)) ||
            d.isAfter(_dateOnly(range.end))) {
          return false;
        }
      }
      if (party != null &&
          s.buyerPartyId != party.id &&
          s.sellerPartyId != party.id) {
        return false;
      }
      if (buyer != null && s.buyerPartyId != buyer.id) return false;
      if (seller != null && s.sellerPartyId != seller.id) return false;
      if (lower.isEmpty) return true;
      return s.saudaNumber.toLowerCase().contains(lower) ||
          (s.itemName?.toLowerCase().contains(lower) ?? false) ||
          (s.buyerPartyName?.toLowerCase().contains(lower) ?? false) ||
          (s.sellerPartyName?.toLowerCase().contains(lower) ?? false) ||
          (s.buyerPartyCode?.toLowerCase().contains(lower) ?? false) ||
          (s.sellerPartyCode?.toLowerCase().contains(lower) ?? false);
    }).toList();
  }

  void searchSaudas(String query) {
    state = state.copyWith(
      searchQuery: query,
      saudas: _applyFilters(
        state.allSaudas,
        query,
        state.dateRangeFilter,
        state.partyFilter,
        state.buyerFilter,
        state.sellerFilter,
      ),
    );
  }

  void applyFilters({
    DateTimeRange? dateRange,
    Party? party,
    Party? buyer,
    Party? seller,
  }) {
    state = state.copyWith(
      replaceFilters: true,
      dateRangeFilter: dateRange,
      partyFilter: party,
      buyerFilter: buyer,
      sellerFilter: seller,
      saudas: _applyFilters(
        state.allSaudas,
        state.searchQuery,
        dateRange,
        party,
        buyer,
        seller,
      ),
    );
  }

  void clearFilters() => applyFilters();

  void applyCurrentMonthFilter() {
    final now = DateTime.now();
    applyFilters(
      dateRange: DateTimeRange(
        start: DateTime(now.year, now.month, 1),
        end: DateTime(now.year, now.month + 1, 0),
      ),
    );
  }

  Future<Sauda?> createSauda({
    required DateTime saudaDate,
    required String itemId,
    required double quantity,
    required double totalKg,
    required String unitId,
    String? bagType,
    double? numberOfBags,
    required String ratePerQuintal,
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
    state = state.copyWith(isLoading: true);
    try {
      final created = await _service.createSauda(
        saudaDate: saudaDate,
        itemId: itemId,
        quantity: quantity,
        totalKg: totalKg,
        unitId: unitId,
        bagType: bagType,
        numberOfBags: numberOfBags,
        ratePerQuintal: ratePerQuintal,
        buyerPartyId: buyerPartyId,
        buyerSideBrokerage: buyerSideBrokerage,
        sellerPartyId: sellerPartyId,
        sellerSideBrokerage: sellerSideBrokerage,
        quantityRemarks: quantityRemarks,
        specification: specification,
        loadingCondition: loadingCondition,
        paymentCondition: paymentCondition,
        deliveryAddress: deliveryAddress,
        additionalRemarks: additionalRemarks,
        sendToParties: sendToParties,
      );
      await loadSaudas();
      return created;
    } catch (e) {
      debugPrint('[SaudasViewModel] createSauda error: $e');
      state = state.copyWith(isLoading: false, errorMessage: friendlyError(e));
      return null;
    }
  }

  Future<Sauda?> updateSauda({
    required String saudaId,
    required DateTime saudaDate,
    required String itemId,
    required double quantity,
    required double totalKg,
    required String unitId,
    String? bagType,
    double? numberOfBags,
    required String ratePerQuintal,
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
    state = state.copyWith(isLoading: true);
    try {
      final updated = await _service.updateSauda(
        saudaId: saudaId,
        saudaDate: saudaDate,
        itemId: itemId,
        quantity: quantity,
        totalKg: totalKg,
        unitId: unitId,
        bagType: bagType,
        numberOfBags: numberOfBags,
        ratePerQuintal: ratePerQuintal,
        buyerPartyId: buyerPartyId,
        buyerSideBrokerage: buyerSideBrokerage,
        sellerPartyId: sellerPartyId,
        sellerSideBrokerage: sellerSideBrokerage,
        quantityRemarks: quantityRemarks,
        specification: specification,
        loadingCondition: loadingCondition,
        paymentCondition: paymentCondition,
        deliveryAddress: deliveryAddress,
        additionalRemarks: additionalRemarks,
        sendToParties: sendToParties,
      );
      await loadSaudas();
      return updated;
    } catch (e) {
      debugPrint('[SaudasViewModel] updateSauda error: $e');
      state = state.copyWith(isLoading: false, errorMessage: friendlyError(e));
      return null;
    }
  }

  Future<bool> deleteSauda(String id) async {
    try {
      await _service.deleteSauda(id);
      await loadSaudas();
      return true;
    } catch (e) {
      debugPrint('[SaudasViewModel] deleteSauda error: $e');
      state = state.copyWith(isLoading: false, errorMessage: friendlyError(e));
      return false;
    }
  }

  void clearMessages() {
    state = state.copyWith(errorMessage: null, successMessage: null);
  }
}
