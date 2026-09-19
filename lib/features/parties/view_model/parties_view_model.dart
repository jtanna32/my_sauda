import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_sauda/features/auth/view_model/current_user_provider.dart';
import 'package:my_sauda/core/utils/error_message.dart';
import '../model/party.dart';
import '../service/parties_service.dart';

final partiesViewModelProvider =
    StateNotifierProvider<PartiesViewModel, PartiesState>(
  (ref) {
    ref.watch(currentUserIdProvider);
    return PartiesViewModel(PartiesService());
  },
);

class PartiesState {
  final bool isLoading;
  final List<Party> parties;
  final List<Party> allParties;
  final String? errorMessage;
  final String? successMessage;
  final String searchQuery;

  const PartiesState({
    this.isLoading = false,
    this.parties = const [],
    this.allParties = const [],
    this.errorMessage,
    this.successMessage,
    this.searchQuery = '',
  });

  PartiesState copyWith({
    bool? isLoading,
    List<Party>? parties,
    List<Party>? allParties,
    String? errorMessage,
    String? successMessage,
    String? searchQuery,
  }) {
    return PartiesState(
      isLoading: isLoading ?? this.isLoading,
      parties: parties ?? this.parties,
      allParties: allParties ?? this.allParties,
      errorMessage: errorMessage,
      successMessage: successMessage,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class PartiesViewModel extends StateNotifier<PartiesState> {
  final PartiesService _service;

  PartiesViewModel(this._service) : super(const PartiesState());

  Future<void> loadParties() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final parties = await _service.fetchParties();

      state = state.copyWith(
        isLoading: false,
        parties: parties,
        allParties: parties,
      );
    } catch (e) {
      debugPrint('[PartiesViewModel] error: $e');
      state = state.copyWith(isLoading: false, errorMessage: friendlyError(e));
    }
  }

  // 🔍 SEARCH LOGIC
  void searchParties(String query) {
    final lower = query.toLowerCase();

    final filtered = state.allParties.where((p) {
      return p.partyName.toLowerCase().contains(lower) ||
          p.city.toLowerCase().contains(lower) ||
          p.state.toLowerCase().contains(lower) ||
          p.partyCode.toLowerCase().contains(lower);
    }).toList();

    state = state.copyWith(
      searchQuery: query,
      parties: filtered,
    );
  }

  Future<bool> createParty({
    required String name,
    required String city,
    required String stateName,
    double? brokerageRate,
    String? panGstin,
    String? deliveryAddress,
    String? phoneNumber,
    String? alternatePhoneNumber,
  }) async {
    state = state.copyWith(isLoading: true);

    try {
      await _service.createParty(
        partyName: name,
        city: city,
        state: stateName,
        brokerageRate: brokerageRate,
        panGstin: panGstin,
        deliveryAddress: deliveryAddress,
        phoneNumber: phoneNumber,
        alternatePhoneNumber: alternatePhoneNumber,
      );

      await loadParties();
      return true;
    } catch (e) {
      debugPrint('[PartiesViewModel] createParty error: $e');
      state = state.copyWith(isLoading: false, errorMessage: friendlyError(e));
      return false;
    }
  }

  Future<bool> updateParty({
    required String id,
    required String name,
    required String city,
    required String stateName,
    double? brokerageRate,
    String? panGstin,
    String? deliveryAddress,
    String? phoneNumber,
    String? alternatePhoneNumber,
  }) async {
    state = state.copyWith(isLoading: true);

    try {
      await _service.updateParty(
        partyId: id,
        partyName: name,
        city: city,
        state: stateName,
        brokerageRate: brokerageRate,
        panGstin: panGstin,
        deliveryAddress: deliveryAddress,
        phoneNumber: phoneNumber,
        alternatePhoneNumber: alternatePhoneNumber,
      );

      await loadParties();
      return true;
    } catch (e) {
      debugPrint('[PartiesViewModel] updateParty error: $e');
      state = state.copyWith(isLoading: false, errorMessage: friendlyError(e));
      return false;
    }
  }

  Future<bool> deleteParty(String id) async {
    try {
      await _service.deleteParty(id);
      await loadParties();
      return true;
    } catch (e) {
      debugPrint('[PartiesViewModel] deleteParty error: $e');
      state = state.copyWith(isLoading: false, errorMessage: friendlyError(e));
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
