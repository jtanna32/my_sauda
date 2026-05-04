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
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}