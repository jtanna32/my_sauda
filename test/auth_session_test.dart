import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_sauda/config/router.dart';
import 'package:my_sauda/features/auth/view_model/current_user_provider.dart';

void main() {
  group('authRedirect', () {
    test('signed out users are sent to login from any private route', () {
      for (final location in ['/home', '/saudas', '/bills', '/add-firm']) {
        expect(authRedirect(hasSession: false, location: location), '/login');
      }
    });

    test('signed out users may see the public auth screens', () {
      for (final location in ['/login', '/register', '/forgot-password']) {
        expect(authRedirect(hasSession: false, location: location), isNull);
      }
    });

    test('signed in users skip the auth screens', () {
      for (final location in ['/login', '/register', '/forgot-password']) {
        expect(authRedirect(hasSession: true, location: location), '/home');
      }
    });

    test('signed in users keep every private route', () {
      for (final location in ['/home', '/saudas', '/bills']) {
        expect(authRedirect(hasSession: true, location: location), isNull);
      }
    });
  });

  group('CurrentUserIdNotifier', () {
    test('starts with the restored user and only emits real changes', () async {
      final ids = StreamController<String?>();
      final notifier = CurrentUserIdNotifier('u1', ids.stream);
      final seen = <String?>[];
      notifier.addListener(seen.add, fireImmediately: false);

      ids
        ..add('u1')
        ..add('u1')
        ..add(null)
        ..add('u2');
      await Future<void>.delayed(Duration.zero);

      expect(notifier.state, 'u2');
      expect(seen, [null, 'u2']);
      notifier.dispose();
      await ids.close();
    });
  });
}
