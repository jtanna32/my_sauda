import 'package:url_launcher/url_launcher.dart';

class WhatsAppHelper {
  WhatsAppHelper._();

  // Normalizes a raw phone number into WhatsApp's expected format
  // (country code + number, digits only). Assumes India (+91) when no
  // country code is present.
  static String? normalizePhoneNumber(String? rawPhoneNumber) {
    if (rawPhoneNumber == null) return null;
    final digits = rawPhoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return null;
    if (digits.length == 10) return '91$digits';
    return digits;
  }

  // Opens WhatsApp with [message] pre-filled in a chat with [phoneNumber].
  // Returns false if the number is invalid or WhatsApp could not be opened.
  static Future<bool> sendMessage({
    required String? phoneNumber,
    required String message,
  }) async {
    final normalized = normalizePhoneNumber(phoneNumber);
    if (normalized == null) return false;

    final uri = Uri.https('wa.me', '/$normalized', {'text': message});
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
