class Firm {
  final String id;
  final String userId;
  final String firmName;
  final String? proprietorName;
  final String? phoneNumber;
  final String? alternatePhoneNumber;
  final String? gstin;
  final String? pan;
  final String? address;
  final String? bankName;
  final String? bankIfsc;
  final String? bankAccountNumber;
  final String? bankAccountName;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Firm({
    required this.id,
    required this.userId,
    required this.firmName,
    this.proprietorName,
    this.phoneNumber,
    this.alternatePhoneNumber,
    this.gstin,
    this.pan,
    this.address,
    this.bankName,
    this.bankIfsc,
    this.bankAccountNumber,
    this.bankAccountName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Firm.fromJson(Map<String, dynamic> json) {
    return Firm(
      id: json['id'],
      userId: json['user_id'],
      firmName: json['firm_name'],
      proprietorName: json['proprietor_name'],
      phoneNumber: json['phone_number'],
      alternatePhoneNumber: json['alternate_phone_number'],
      gstin: json['gstin'],
      pan: json['pan'],
      address: json['address'],
      bankName: json['bank_name'],
      bankIfsc: json['bank_ifsc'],
      bankAccountNumber: json['bank_account_number'],
      bankAccountName: json['bank_account_name'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Firm copyWith({
    String? id,
    String? userId,
    String? firmName,
    String? proprietorName,
    String? phoneNumber,
    String? alternatePhoneNumber,
    String? gstin,
    String? pan,
    String? address,
    String? bankName,
    String? bankIfsc,
    String? bankAccountNumber,
    String? bankAccountName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Firm(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      firmName: firmName ?? this.firmName,
      proprietorName: proprietorName ?? this.proprietorName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      alternatePhoneNumber: alternatePhoneNumber ?? this.alternatePhoneNumber,
      gstin: gstin ?? this.gstin,
      pan: pan ?? this.pan,
      address: address ?? this.address,
      bankName: bankName ?? this.bankName,
      bankIfsc: bankIfsc ?? this.bankIfsc,
      bankAccountNumber: bankAccountNumber ?? this.bankAccountNumber,
      bankAccountName: bankAccountName ?? this.bankAccountName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
