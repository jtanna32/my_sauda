import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

const _genericMessage = 'Something went wrong. Please try again.';
const _offlineMessage =
    'No internet connection. Please check your connection and try again.';
const _sessionMessage = 'Your session has expired. Please log in again.';

// Turns any error (Supabase, network, plain text) into a short sentence a user can act on.
// The technical detail stays in the debug logs written by the services.
String friendlyError(Object error, {String fallback = _genericMessage}) {
  final text = (error is PostgrestException ? error.message : error.toString())
      .toLowerCase();

  if (error is TimeoutException || text.contains('timeout')) {
    return 'The request took too long. Please try again.';
  }
  if (_isOffline(text)) return _offlineMessage;

  if (error is AuthException) return _authMessage(error, text, fallback);
  if (error is PostgrestException) {
    return _databaseMessage(error, text, fallback);
  }

  return _authTextMessage(text) ?? fallback;
}

bool _isOffline(String text) => const [
      'socketexception',
      'failed host lookup',
      'network is unreachable',
      'connection refused',
      'connection reset',
      'connection closed',
      'connection timed out',
      'no address associated',
      'clientexception',
    ].any(text.contains);

String _authMessage(AuthException error, String text, String fallback) {
  return _authTextMessage('$text ${error.code ?? ''}'.toLowerCase()) ??
      (error.statusCode == '401' ? _sessionMessage : fallback);
}

String? _authTextMessage(String text) {
  if (text.contains('invalid login credentials') ||
      text.contains('invalid_credentials')) {
    return 'Incorrect email or password.';
  }
  if (text.contains('email not confirmed') ||
      text.contains('email_not_confirmed')) {
    return 'Please verify your email before logging in.';
  }
  if (text.contains('already registered') ||
      text.contains('user_already_exists') ||
      text.contains('already been registered')) {
    return 'An account with this email already exists. Try logging in instead.';
  }
  if (text.contains('weak_password') ||
      text.contains('password should be at least')) {
    return 'Please choose a stronger password (at least 6 characters).';
  }
  if (text.contains('rate limit') ||
      text.contains('too many requests') ||
      text.contains('over_request_rate_limit') ||
      text.contains('over_email_send_rate_limit')) {
    return 'Too many attempts. Please wait a minute and try again.';
  }
  if (text.contains('invalid email') ||
      text.contains('unable to validate email') ||
      text.contains('email_address_invalid')) {
    return 'Please enter a valid email address.';
  }
  if (text.contains('jwt expired') ||
      text.contains('refresh token') ||
      text.contains('not authenticated') ||
      text.contains('session_not_found')) {
    return _sessionMessage;
  }
  return null;
}

String _databaseMessage(
  PostgrestException error,
  String text,
  String fallback,
) {
  final authMessage = _authTextMessage(text);
  if (authMessage != null) return authMessage;

  switch (error.code) {
    case '23505':
      return 'This already exists. Please use a different name.';
    case '23503':
      return text.contains('still referenced')
          ? "This can't be deleted because it is used in other records."
          : 'Some of the selected details are no longer available. Please refresh and try again.';
    case '23502':
      return 'Some required information is missing.';
    case '22P02':
    case '22007':
    case '22008':
    case '22003':
      return 'Some of the information entered is not valid.';
    case '42501':
    case 'PGRST301':
    case 'PGRST303':
      return "You don't have permission to do this.";
    case 'PGRST202':
    case 'PGRST205':
    case '42883':
    case '42P01':
      return 'This feature is not available right now. Please try again later.';
    case 'P0001':
      // Messages raised on purpose by our own database functions are already written for users.
      return error.message.isEmpty ? fallback : error.message;
  }
  return fallback;
}
