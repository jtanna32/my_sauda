import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_sauda/features/auth/view_model/current_user_provider.dart';
import 'package:my_sauda/core/utils/error_message.dart';
import '../service/suggestion_service.dart';

final suggestionViewModelProvider = StateNotifierProvider.family<
    SuggestionViewModel, SuggestionState, String>(
      (ref, type) {
    ref.watch(currentUserIdProvider);
    return SuggestionViewModel(type);
  },
);

class SuggestionState {
  final bool isLoading;
  final List<String> suggestions;
  final List<String> filteredSuggestions;
  final String searchQuery;
  final String? error;

  const SuggestionState({
    this.isLoading = false,
    this.suggestions = const [],
    this.filteredSuggestions = const [],
    this.searchQuery = '',
    this.error,
  });

  SuggestionState copyWith({
    bool? isLoading,
    List<String>? suggestions,
    List<String>? filteredSuggestions,
    String? searchQuery,
    String? error,
  }) {
    return SuggestionState(
      isLoading: isLoading ?? this.isLoading,
      suggestions: suggestions ?? this.suggestions,
      filteredSuggestions:
      filteredSuggestions ?? this.filteredSuggestions,
      searchQuery: searchQuery ?? this.searchQuery,
      error: error,
    );
  }
}

class SuggestionViewModel extends StateNotifier<SuggestionState> {
  final String type;

  SuggestionViewModel(this.type) : super(const SuggestionState());

  /// 🔄 LOAD
  Future<void> loadSuggestions() async {
    state = state.copyWith(isLoading: true);

    try {
      final data =
      await SuggestionService.instance.fetchSuggestions(type);

      state = state.copyWith(
        isLoading: false,
        suggestions: data,
        filteredSuggestions: data,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: friendlyError(e),
      );
    }
  }

  /// 🔍 SEARCH
  void search(String query) {
    final lower = query.toLowerCase();

    final filtered = state.suggestions.where((item) {
      return item.toLowerCase().contains(lower);
    }).toList();

    state = state.copyWith(
      searchQuery: query,
      filteredSuggestions: filtered,
    );
  }

  /// ➕ ADD NEW
  Future<void> addNew(String value) async {
    await SuggestionService.instance.addSuggestion(
      type: type,
      value: value,
    );

    await loadSuggestions();
  }
}