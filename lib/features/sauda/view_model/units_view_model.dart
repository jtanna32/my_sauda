import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/unit.dart';
import '../service/units_service.dart';

final unitsViewModelProvider =
    StateNotifierProvider<UnitsViewModel, UnitsState>(
  (ref) => UnitsViewModel(UnitsService()),
);

class UnitsState {
  final bool isLoading;
  final List<Unit> units;
  final String? errorMessage;

  const UnitsState({
    this.isLoading = false,
    this.units = const [],
    this.errorMessage,
  });

  UnitsState copyWith({
    bool? isLoading,
    List<Unit>? units,
    String? errorMessage,
  }) {
    return UnitsState(
      isLoading: isLoading ?? this.isLoading,
      units: units ?? this.units,
      errorMessage: errorMessage,
    );
  }
}

class UnitsViewModel extends StateNotifier<UnitsState> {
  final UnitsService _service;

  UnitsViewModel(this._service) : super(const UnitsState());

  Future<void> loadUnits() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final units = await _service.fetchUnits();
      state = state.copyWith(isLoading: false, units: units);
    } catch (e) {
      debugPrint('[UnitsViewModel] loadUnits error: $e');
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void clearMessages() {
    state = state.copyWith(errorMessage: null);
  }
}
