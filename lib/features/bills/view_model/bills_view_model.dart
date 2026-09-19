import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/bill.dart';
import '../service/bills_repository.dart';
import '../service/local_bills_repository.dart';

final billsRepositoryProvider =
    Provider<BillsRepository>((ref) => LocalBillsRepository());

final billsViewModelProvider =
    StateNotifierProvider.autoDispose<BillsViewModel, BillsState>(
  (ref) => BillsViewModel(ref.read(billsRepositoryProvider)),
);

class BillsState {
  final bool isLoading;
  final List<Bill> bills;
  final String? errorMessage;

  const BillsState({
    this.isLoading = false,
    this.bills = const [],
    this.errorMessage,
  });

  BillsState copyWith({
    bool? isLoading,
    List<Bill>? bills,
    String? errorMessage,
  }) {
    return BillsState(
      isLoading: isLoading ?? this.isLoading,
      bills: bills ?? this.bills,
      errorMessage: errorMessage,
    );
  }
}

class BillsViewModel extends StateNotifier<BillsState> {
  final BillsRepository _repository;

  BillsViewModel(this._repository) : super(const BillsState());

  Future<void> loadBills() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final bills = await _repository.listBills();
      state = state.copyWith(isLoading: false, bills: bills);
    } catch (e) {
      debugPrint('[BillsViewModel] loadBills error: $e');
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<bool> deleteBill(Bill bill) async {
    try {
      await _repository.deleteBill(bill);
      await loadBills();
      return true;
    } catch (e) {
      debugPrint('[BillsViewModel] deleteBill error: $e');
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }
}
