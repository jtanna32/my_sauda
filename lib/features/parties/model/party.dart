class Party {
  final String id;
  final String userId;
  final String partyCode;
  final String partyName;

  final double? brokerageRate;

  final String city;
  final String state;

  final String? panGstin;
  final String? deliveryAddress;
  final String? phoneNumber;
  final String? alternatePhoneNumber;

  final DateTime createdAt;
  final DateTime updatedAt;

  Party({
    required this.id,
    required this.userId,
    required this.partyCode,
    required this.partyName,
    this.brokerageRate,
    required this.city,
    required this.state,
    this.panGstin,
    this.deliveryAddress,
    this.phoneNumber,
    this.alternatePhoneNumber,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Party.fromJson(Map<String, dynamic> json) {
    return Party(
      id: json['id'],
      userId: json['user_id'],
      partyCode: json['party_code'],
      partyName: json['party_name'],
      brokerageRate: json['brokerage_rate'] != null
          ? (json['brokerage_rate'] as num).toDouble()
          : null,
      city: json['city'],
      state: json['state'],
      panGstin: json['pan_gstin'],
      deliveryAddress: json['delivery_address'],
      phoneNumber: json['phone_number'],
      alternatePhoneNumber: json['alternate_phone_number'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Party copyWith({
    String? id,
    String? userId,
    String? partyCode,
    String? partyName,
    double? brokerageRate,
    String? city,
    String? state,
    String? panGstin,
    String? deliveryAddress,
    String? phoneNumber,
    String? alternatePhoneNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Party(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      partyCode: partyCode ?? this.partyCode,
      partyName: partyName ?? this.partyName,
      brokerageRate: brokerageRate ?? this.brokerageRate,
      city: city ?? this.city,
      state: state ?? this.state,
      panGstin: panGstin ?? this.panGstin,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      alternatePhoneNumber: alternatePhoneNumber ?? this.alternatePhoneNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}