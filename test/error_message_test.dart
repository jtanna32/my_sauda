import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_sauda/core/utils/error_message.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('friendlyError', () {
    test('no internet', () {
      for (final e in [
        "SocketException: Failed host lookup: 'x.supabase.co'",
        'ClientException with SocketException: Network is unreachable',
      ]) {
        expect(friendlyError(e), contains('No internet connection'));
      }
    });

    test('timeouts', () {
      expect(friendlyError(TimeoutException('slow')), contains('too long'));
    });

    test('login and sign-up problems', () {
      expect(
        friendlyError(const AuthException('Invalid login credentials')),
        'Incorrect email or password.',
      );
      expect(
        friendlyError(const AuthException('Email not confirmed')),
        'Please verify your email before logging in.',
      );
      expect(
        friendlyError(const AuthException('User already registered')),
        contains('already exists'),
      );
      expect(
        friendlyError(const AuthException('Email rate limit exceeded')),
        contains('Too many attempts'),
      );
    });

    test('database errors become plain sentences', () {
      expect(
        friendlyError(const PostgrestException(
          message: 'duplicate key value violates unique constraint "x"',
          code: '23505',
        )),
        'This already exists. Please use a different name.',
      );
      expect(
        friendlyError(const PostgrestException(
          message:
              'update or delete on table "parties" violates foreign key constraint ... is still referenced from table "saudas"',
          code: '23503',
        )),
        contains("can't be deleted"),
      );
      expect(
        friendlyError(const PostgrestException(
          message: 'permission denied for table bills',
          code: '42501',
        )),
        contains('permission'),
      );
      expect(
        friendlyError(const PostgrestException(
          message: 'Could not find the function public.delete_bill',
          code: 'PGRST202',
        )),
        contains('not available'),
      );
    });

    test('expired sessions ask to log in again', () {
      expect(
        friendlyError(const PostgrestException(
          message: 'not authenticated',
          code: 'P0001',
        )),
        contains('log in again'),
      );
      expect(
        friendlyError(const PostgrestException(message: 'JWT expired')),
        contains('log in again'),
      );
    });

    test('messages raised on purpose by our functions are kept', () {
      expect(
        friendlyError(const PostgrestException(
          message: 'Party name already exists',
          code: 'P0001',
        )),
        'Party name already exists',
      );
    });

    test('unknown errors never leak technical text', () {
      final message = friendlyError(const PostgrestException(
        message: 'relation "x" something odd',
        code: '99999',
      ));
      expect(message, 'Something went wrong. Please try again.');
      expect(friendlyError(Exception('boom')), message);
      expect(friendlyError('anything', fallback: 'Custom'), 'Custom');
    });
  });
}
