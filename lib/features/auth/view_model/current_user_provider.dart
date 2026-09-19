import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Emits only when the signed-in user actually changes, so token refreshes rebuild nothing.
class CurrentUserIdNotifier extends StateNotifier<String?> {
  late final StreamSubscription<String?> _subscription;

  CurrentUserIdNotifier(String? initialId, Stream<String?> userIds)
      : super(initialId) {
    _subscription = userIds.listen((id) {
      if (id != state) state = id;
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

// User-scoped providers watch this so their cached data is dropped on logout or user switch.
final currentUserIdProvider =
    StateNotifierProvider<CurrentUserIdNotifier, String?>((ref) {
  final auth = Supabase.instance.client.auth;
  return CurrentUserIdNotifier(
    auth.currentUser?.id,
    auth.onAuthStateChange.map((event) => event.session?.user.id),
  );
});
