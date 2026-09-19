import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/sauda_defaults.dart';

// Remembers the optional Firm Name and Terms & Conditions on this phone, separately for each logged-in user.
class SaudaDefaultsService {
  static const _firmNameKey = 'firm_name';
  static const _termsKey = 'terms';

  final String? Function() _currentUserId;

  SaudaDefaultsService({String? Function()? currentUserId})
      : _currentUserId = currentUserId ??
            (() => Supabase.instance.client.auth.currentUser?.id);

  String? get _userId => _currentUserId();

  String _key(String userId, String name) => 'sauda_defaults.$userId.$name';

  Future<SaudaDefaults> fetchDefaults() async {
    debugPrint('[SaudaDefaultsService] fetchDefaults called');
    final userId = _userId;
    if (userId == null) return const SaudaDefaults();
    final prefs = await SharedPreferences.getInstance();
    return SaudaDefaults(
      firmName: prefs.getString(_key(userId, _firmNameKey)) ?? '',
      terms: prefs.getString(_key(userId, _termsKey)) ?? '',
    );
  }

  Future<void> saveDefaults(SaudaDefaults defaults) async {
    debugPrint('[SaudaDefaultsService] saveDefaults called');
    final userId = _userId;
    if (userId == null) return;
    final prefs = await SharedPreferences.getInstance();
    await _put(prefs, _key(userId, _firmNameKey), defaults.firmName);
    await _put(prefs, _key(userId, _termsKey), defaults.terms);
  }

  Future<void> _put(SharedPreferences prefs, String key, String value) {
    return value.isEmpty ? prefs.remove(key) : prefs.setString(key, value);
  }
}
