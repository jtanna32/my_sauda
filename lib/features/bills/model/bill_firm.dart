import 'package:my_sauda/features/firms/model/firm.dart';

// Frozen copy of the firm at print time, so editing or deleting the firm later never changes a printed bill.
class BillFirm {
  final String id;
  final String name;
  final String proprietorName;
  final String phoneNumber;
  final String alternatePhoneNumber;
  final String pan;
  final String address;
  final String bankName;
  final String bankIfsc;
  final String bankAccountNumber;
  final String bankAccountName;

  const BillFirm({
    this.id = '',
    this.name = '',
    this.proprietorName = '',
    this.phoneNumber = '',
    this.alternatePhoneNumber = '',
    this.pan = '',
    this.address = '',
    this.bankName = '',
    this.bankIfsc = '',
    this.bankAccountNumber = '',
    this.bankAccountName = '',
  });

  factory BillFirm.fromFirm(Firm f) => BillFirm(
        id: f.id,
        name: f.firmName,
        proprietorName: f.proprietorName ?? '',
        phoneNumber: f.phoneNumber ?? '',
        alternatePhoneNumber: f.alternatePhoneNumber ?? '',
        pan: f.pan ?? '',
        address: f.address ?? '',
        bankName: f.bankName ?? '',
        bankIfsc: f.bankIfsc ?? '',
        bankAccountNumber: f.bankAccountNumber ?? '',
        bankAccountName: f.bankAccountName ?? '',
      );

  factory BillFirm.fromJson(Map<String, dynamic> json) => BillFirm(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        proprietorName: json['proprietor_name'] as String? ?? '',
        phoneNumber: json['phone_number'] as String? ?? '',
        alternatePhoneNumber: json['alternate_phone_number'] as String? ?? '',
        pan: json['pan'] as String? ?? '',
        address: json['address'] as String? ?? '',
        bankName: json['bank_name'] as String? ?? '',
        bankIfsc: json['bank_ifsc'] as String? ?? '',
        bankAccountNumber: json['bank_account_number'] as String? ?? '',
        bankAccountName: json['bank_account_name'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'proprietor_name': proprietorName,
        'phone_number': phoneNumber,
        'alternate_phone_number': alternatePhoneNumber,
        'pan': pan,
        'address': address,
        'bank_name': bankName,
        'bank_ifsc': bankIfsc,
        'bank_account_number': bankAccountNumber,
        'bank_account_name': bankAccountName,
      };
}
