import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_sauda/features/auth/view_model/current_user_provider.dart';
import 'package:my_sauda/core/utils/error_message.dart';
import '../model/bill.dart';
import '../service/bill_pdf_service.dart';
import '../service/bills_service.dart';

final billsViewModelProvider =
    StateNotifierProvider<BillsViewModel, BillsState>(
  (ref) {
    ref.watch(currentUserIdProvider);
    return BillsViewModel(BillsService(), BillPdfService());
  },
);

class BillsState {
  final bool isLoading;
  final List<Bill> bills;
  final List<Bill> allBills;
  final String? errorMessage;
  final String searchQuery;

  const BillsState({
    this.isLoading = false,
    this.bills = const [],
    this.allBills = const [],
    this.errorMessage,
    this.searchQuery = '',
  });

  BillsState copyWith({
    bool? isLoading,
    List<Bill>? bills,
    List<Bill>? allBills,
    String? errorMessage,
    String? searchQuery,
  }) {
    return BillsState(
      isLoading: isLoading ?? this.isLoading,
      bills: bills ?? this.bills,
      allBills: allBills ?? this.allBills,
      errorMessage: errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class BillsViewModel extends StateNotifier<BillsState> {
  final BillsService _service;
  final BillPdfService _pdfService;

  BillsViewModel(this._service, this._pdfService) : super(const BillsState());

  Future<void> loadBills() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final bills = await _service.fetchBills();
      state = state.copyWith(
        isLoading: false,
        bills: _applySearch(bills, state.searchQuery),
        allBills: bills,
      );
    } catch (e) {
      debugPrint('[BillsViewModel] loadBills error: $e');
      state = state.copyWith(isLoading: false, errorMessage: friendlyError(e));
    }
  }

  static List<Bill> _applySearch(List<Bill> all, String query) {
    final lower = query.trim().toLowerCase();
    if (lower.isEmpty) return all;
    return all
        .where((b) =>
            b.billNumber.toLowerCase().contains(lower) ||
            b.partyName.toLowerCase().contains(lower))
        .toList();
  }

  void searchBills(String query) {
    state = state.copyWith(
      searchQuery: query,
      bills: _applySearch(state.allBills, query),
    );
  }

  Future<Bill?> createBill(Bill draft) async {
    state = state.copyWith(isLoading: true);
    try {
      final created = await _service.createBill(draft);
      await loadBills();
      return created;
    } catch (e) {
      debugPrint('[BillsViewModel] createBill error: $e');
      state = state.copyWith(isLoading: false, errorMessage: friendlyError(e));
      return null;
    }
  }

  Future<Uint8List> buildPdf(Bill bill) => _pdfService.build(bill);

  Future<bool> deleteBill(Bill bill) async {
    try {
      await _service.deleteBill(bill.billNumber);
      await loadBills();
      return true;
    } catch (e) {
      debugPrint('[BillsViewModel] deleteBill error: $e');
      state = state.copyWith(errorMessage: friendlyError(e));
      return false;
    }
  }
}
