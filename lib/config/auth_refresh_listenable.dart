import 'dart:async';
import 'package:flutter/foundation.dart';

// Lets GoRouter re-run its redirect whenever the auth session changes.
class AuthRefreshListenable extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  AuthRefreshListenable(Stream<dynamic> events) {
    _subscription = events.listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
