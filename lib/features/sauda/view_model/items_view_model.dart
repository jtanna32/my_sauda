import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_sauda/features/auth/view_model/current_user_provider.dart';
import 'package:my_sauda/core/utils/error_message.dart';
import '../model/item.dart';
import '../service/items_service.dart';

final itemsViewModelProvider =
    StateNotifierProvider<ItemsViewModel, ItemsState>(
  (ref) {
    ref.watch(currentUserIdProvider);
    return ItemsViewModel(ItemsService());
  },
);

class ItemsState {
  final bool isLoading;
  final List<Item> items;
  final String? errorMessage;

  const ItemsState({
    this.isLoading = false,
    this.items = const [],
    this.errorMessage,
  });

  ItemsState copyWith({
    bool? isLoading,
    List<Item>? items,
    String? errorMessage,
  }) {
    return ItemsState(
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      errorMessage: errorMessage,
    );
  }
}

class ItemsViewModel extends StateNotifier<ItemsState> {
  final ItemsService _service;

  ItemsViewModel(this._service) : super(const ItemsState());

  Future<void> loadItems() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final items = await _service.fetchItems();
      state = state.copyWith(isLoading: false, items: items);
    } catch (e) {
      debugPrint('[ItemsViewModel] loadItems error: $e');
      state = state.copyWith(isLoading: false, errorMessage: friendlyError(e));
    }
  }

  Future<Item?> createItem({required String name}) async {
    state = state.copyWith(isLoading: true);
    try {
      final item = await _service.createItem(name: name);
      await loadItems();
      return item;
    } catch (e) {
      debugPrint('[ItemsViewModel] createItem error: $e');
      state = state.copyWith(isLoading: false, errorMessage: friendlyError(e));
      return null;
    }
  }

  Future<bool> deleteItem(String id) async {
    try {
      await _service.deleteItem(id);
      await loadItems();
      return true;
    } catch (e) {
      debugPrint('[ItemsViewModel] deleteItem error: $e');
      state = state.copyWith(isLoading: false, errorMessage: friendlyError(e));
      return false;
    }
  }

  void clearMessages() {
    state = state.copyWith(errorMessage: null);
  }
}
