// The rate is free text ("4525", "Rate multiple"); only a plain number counts as numeric.
double? parseNumericRate(String? text) {
  final t = text?.trim() ?? '';
  return RegExp(r'^\d+(\.\d+)?$').hasMatch(t) ? double.parse(t) : null;
}

// Numeric columns arrive as numbers, text columns as strings.
String _rateFromJson(dynamic value) {
  if (value == null) return '';
  if (value is num) {
    return value % 1 == 0 ? value.toInt().toString() : value.toString();
  }
  return value.toString();
}

class Sauda {
  final String id;
  final String userId;
  final String saudaNumber;
  final DateTime saudaDate;

  final String itemId;
  final String? itemName;

  final double quantity;
  final String unitId;
  final String? unitName;

  final String? bagType;
  final double? numberOfBags;

  final String ratePerQuintal;

  final String buyerPartyId;
  final String? buyerPartyName;
  final String? buyerPartyCode;
  final String? buyerPartyGstin;
  final String? buyerPartyAddress;
  final String? buyerPartyCity;
  final String? buyerPartyState;
  final double? buyerBrokerageRate;
  final double buyerSideBrokerage;

  final String sellerPartyId;
  final String? sellerPartyName;
  final String? sellerPartyCode;
  final String? sellerPartyGstin;
  final String? sellerPartyAddress;
  final String? sellerPartyCity;
  final String? sellerPartyState;
  final double? sellerBrokerageRate;
  final double sellerSideBrokerage;

  final String? quantityRemarks;
  final String? specification;
  final String? loadingCondition;
  final String? paymentCondition;
  final String? deliveryAddress;
  final String? additionalRemarks;

  final bool sendToParties;

  final DateTime createdAt;
  final DateTime? updatedAt;

  Sauda({
    required this.id,
    required this.userId,
    required this.saudaNumber,
    required this.saudaDate,
    required this.itemId,
    this.itemName,
    required this.quantity,
    required this.unitId,
    this.unitName,
    this.bagType,
    this.numberOfBags,
    required this.ratePerQuintal,
    required this.buyerPartyId,
    this.buyerPartyName,
    this.buyerPartyCode,
    this.buyerPartyGstin,
    this.buyerPartyAddress,
    this.buyerPartyCity,
    this.buyerPartyState,
    this.buyerBrokerageRate,
    required this.buyerSideBrokerage,
    required this.sellerPartyId,
    this.sellerPartyName,
    this.sellerPartyCode,
    this.sellerPartyGstin,
    this.sellerPartyAddress,
    this.sellerPartyCity,
    this.sellerPartyState,
    this.sellerBrokerageRate,
    required this.sellerSideBrokerage,
    this.quantityRemarks,
    this.specification,
    this.loadingCondition,
    this.paymentCondition,
    this.deliveryAddress,
    this.additionalRemarks,
    required this.sendToParties,
    required this.createdAt,
    this.updatedAt,
  });

  double? get numericRate => parseNumericRate(ratePerQuintal);

  String get rateDisplay => numericRate == null
      ? ratePerQuintal
      : '₹${numericRate!.toStringAsFixed(2)}/qtl';

  factory Sauda.fromJson(Map<String, dynamic> json) {
    final buyer = json['buyer_party'] as Map<String, dynamic>?;
    final seller = json['seller_party'] as Map<String, dynamic>?;
    final item = json['item'] as Map<String, dynamic>?;
    final unit = json['unit'] as Map<String, dynamic>?;

    return Sauda(
      id: json['id'],
      userId: json['user_id'],
      saudaNumber: json['sauda_number'] ?? '',
      saudaDate: DateTime.parse(json['sauda_date']),
      itemId: json['item_id'],
      itemName: item?['item_name'],
      quantity: (json['quantity'] as num).toDouble(),
      unitId: json['unit_id'],
      unitName: unit?['name'],
      bagType: json['bag_type'],
      numberOfBags: json['number_of_bags'] != null
          ? (json['number_of_bags'] as num).toDouble()
          : null,
      ratePerQuintal: _rateFromJson(json['rate_per_quintal']),
      buyerPartyId: json['buyer_party_id'],
      buyerPartyName: buyer?['party_name'],
      buyerPartyCode: buyer?['party_code'],
      buyerPartyGstin: buyer?['pan_gstin'],
      buyerPartyAddress: buyer?['delivery_address'],
      buyerPartyCity: buyer?['city'],
      buyerPartyState: buyer?['state'],
      buyerBrokerageRate: buyer?['brokerage_rate'] != null
          ? (buyer!['brokerage_rate'] as num).toDouble()
          : null,
      buyerSideBrokerage: (json['buyer_side_brokerage'] as num).toDouble(),
      sellerPartyId: json['seller_party_id'],
      sellerPartyName: seller?['party_name'],
      sellerPartyCode: seller?['party_code'],
      sellerPartyGstin: seller?['pan_gstin'],
      sellerPartyAddress: seller?['delivery_address'],
      sellerPartyCity: seller?['city'],
      sellerPartyState: seller?['state'],
      sellerBrokerageRate: seller?['brokerage_rate'] != null
          ? (seller!['brokerage_rate'] as num).toDouble()
          : null,
      sellerSideBrokerage: (json['seller_side_brokerage'] as num).toDouble(),
      quantityRemarks: json['quantity_remarks'],
      specification: json['specification'],
      loadingCondition: json['loading_condition'],
      paymentCondition: json['payment_condition'],
      deliveryAddress: json['delivery_address'],
      additionalRemarks: json['additional_remarks'],
      sendToParties: json['send_to_parties'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Sauda copyWith({
    String? id,
    String? userId,
    String? saudaNumber,
    DateTime? saudaDate,
    String? itemId,
    String? itemName,
    double? quantity,
    String? unitId,
    String? unitName,
    String? bagType,
    double? numberOfBags,
    String? ratePerQuintal,
    String? buyerPartyId,
    String? buyerPartyName,
    String? buyerPartyCode,
    String? buyerPartyGstin,
    String? buyerPartyAddress,
    String? buyerPartyCity,
    String? buyerPartyState,
    double? buyerBrokerageRate,
    double? buyerSideBrokerage,
    String? sellerPartyId,
    String? sellerPartyName,
    String? sellerPartyCode,
    String? sellerPartyGstin,
    String? sellerPartyAddress,
    String? sellerPartyCity,
    String? sellerPartyState,
    double? sellerBrokerageRate,
    double? sellerSideBrokerage,
    String? quantityRemarks,
    String? specification,
    String? loadingCondition,
    String? paymentCondition,
    String? deliveryAddress,
    String? additionalRemarks,
    bool? sendToParties,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Sauda(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      saudaNumber: saudaNumber ?? this.saudaNumber,
      saudaDate: saudaDate ?? this.saudaDate,
      itemId: itemId ?? this.itemId,
      itemName: itemName ?? this.itemName,
      quantity: quantity ?? this.quantity,
      unitId: unitId ?? this.unitId,
      unitName: unitName ?? this.unitName,
      bagType: bagType ?? this.bagType,
      numberOfBags: numberOfBags ?? this.numberOfBags,
      ratePerQuintal: ratePerQuintal ?? this.ratePerQuintal,
      buyerPartyId: buyerPartyId ?? this.buyerPartyId,
      buyerPartyName: buyerPartyName ?? this.buyerPartyName,
      buyerPartyCode: buyerPartyCode ?? this.buyerPartyCode,
      buyerPartyGstin: buyerPartyGstin ?? this.buyerPartyGstin,
      buyerPartyAddress: buyerPartyAddress ?? this.buyerPartyAddress,
      buyerPartyCity: buyerPartyCity ?? this.buyerPartyCity,
      buyerPartyState: buyerPartyState ?? this.buyerPartyState,
      buyerBrokerageRate: buyerBrokerageRate ?? this.buyerBrokerageRate,
      buyerSideBrokerage: buyerSideBrokerage ?? this.buyerSideBrokerage,
      sellerPartyId: sellerPartyId ?? this.sellerPartyId,
      sellerPartyName: sellerPartyName ?? this.sellerPartyName,
      sellerPartyCode: sellerPartyCode ?? this.sellerPartyCode,
      sellerPartyGstin: sellerPartyGstin ?? this.sellerPartyGstin,
      sellerPartyAddress: sellerPartyAddress ?? this.sellerPartyAddress,
      sellerPartyCity: sellerPartyCity ?? this.sellerPartyCity,
      sellerPartyState: sellerPartyState ?? this.sellerPartyState,
      sellerBrokerageRate: sellerBrokerageRate ?? this.sellerBrokerageRate,
      sellerSideBrokerage: sellerSideBrokerage ?? this.sellerSideBrokerage,
      quantityRemarks: quantityRemarks ?? this.quantityRemarks,
      specification: specification ?? this.specification,
      loadingCondition: loadingCondition ?? this.loadingCondition,
      paymentCondition: paymentCondition ?? this.paymentCondition,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      additionalRemarks: additionalRemarks ?? this.additionalRemarks,
      sendToParties: sendToParties ?? this.sendToParties,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
