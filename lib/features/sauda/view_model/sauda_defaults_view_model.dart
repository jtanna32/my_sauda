import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_sauda/features/auth/view_model/current_user_provider.dart';
import 'package:my_sauda/core/utils/error_message.dart';
import '../model/sauda_defaults.dart';
import '../service/sauda_defaults_service.dart';

final saudaDefaultsViewModelProvider =
    StateNotifierProvider<SaudaDefaultsViewModel, SaudaDefaultsState>(
  (ref) {
    ref.watch(currentUserIdProvider);
    return SaudaDefaultsViewModel(SaudaDefaultsService());
  },
);

class SaudaDefaultsState {
  final bool isLoading;
  final SaudaDefaults defaults;
  final String? errorMessage;

  const SaudaDefaultsState({
    this.isLoading = false,
    this.defaults = const SaudaDefaults(),
    this.errorMessage,
  });

  SaudaDefaultsState copyWith({
    bool? isLoading,
    SaudaDefaults? defaults,
    String? errorMessage,
  }) {
    return SaudaDefaultsState(
      isLoading: isLoading ?? this.isLoading,
      defaults: defaults ?? this.defaults,
      errorMessage: errorMessage,
    );
  }
}

class SaudaDefaultsViewModel extends StateNotifier<SaudaDefaultsState> {
  final SaudaDefaultsService _service;

  SaudaDefaultsViewModel(this._service) : super(const SaudaDefaultsState());

  Future<SaudaDefaults> loadDefaults() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final defaults = await _service.fetchDefaults();
      state = state.copyWith(isLoading: false, defaults: defaults);
      return defaults;
    } catch (e) {
      debugPrint('[SaudaDefaultsViewModel] loadDefaults error: $e');
      state = state.copyWith(isLoading: false, errorMessage: friendlyError(e));
      return state.defaults;
    }
  }

  Future<void> saveDefaults({
    required String firmName,
    required String terms,
  }) async {
    final defaults =
        SaudaDefaults(firmName: firmName.trim(), terms: terms.trim());
    try {
      await _service.saveDefaults(defaults);
      state = state.copyWith(defaults: defaults, errorMessage: null);
    } catch (e) {
      debugPrint('[SaudaDefaultsViewModel] saveDefaults error: $e');
      state = state.copyWith(errorMessage: friendlyError(e));
    }
  }
}
