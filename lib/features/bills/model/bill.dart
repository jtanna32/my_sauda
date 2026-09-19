import 'package:my_sauda/features/sauda/model/sauda.dart';
import 'bill_calculator.dart';
import 'bill_firm.dart';
import 'bill_format.dart';

enum BillSide { buyer, seller }

BillSide? _sideFromName(String? name) => switch (name) {
      'buyer' => BillSide.buyer,
      'seller' => BillSide.seller,
      _ => null,
    };

extension BillSideX on BillSide {
  String get label => this == BillSide.buyer ? 'Buyer' : 'Seller';

  BillSide get opposite =>
      this == BillSide.buyer ? BillSide.seller : BillSide.buyer;

  String get counterPartyLabel => opposite.label;

  String partyIdOf(Sauda s) =>
      this == BillSide.buyer ? s.buyerPartyId : s.sellerPartyId;
}

// Bills saved before the rate became text stored it as a number under another key.
String? _legacyRate(dynamic value) => value is num
    ? (value % 1 == 0 ? value.toInt().toString() : value.toString())
    : null;

class BillLine {
  final String id;
  final String? saudaId;
  // The role the billed party played in this sauda; decides the rate and which PDF column holds the party.
  final BillSide side;
  final DateTime date;
  final String saudaNumber;
  final String itemName;
  final String counterParty;
  final double quantityQuintals;
  // Free text as typed on the sauda; only a plain number is ever converted.
  final String? saleRate;
  final double brokerageRatePerQuintal;
  final double? savedAmount;

  const BillLine({
    required this.id,
    this.saudaId,
    required this.side,
    required this.date,
    required this.saudaNumber,
    required this.itemName,
    required this.counterParty,
    required this.quantityQuintals,
    this.saleRate,
    required this.brokerageRatePerQuintal,
    this.savedAmount,
  });

  factory BillLine.fromSauda(Sauda s, BillSide side) {
    final isBuyer = side == BillSide.buyer;
    final rate = isBuyer ? s.buyerBrokerageRate : s.sellerBrokerageRate;
    return BillLine(
      id: s.id,
      saudaId: s.id,
      side: side,
      date: s.saudaDate,
      saudaNumber: s.saudaNumber,
      itemName: s.itemName ?? '',
      counterParty: (isBuyer ? s.sellerPartyName : s.buyerPartyName) ?? '',
      quantityQuintals: BillCalculator.toQuintals(s.quantity, s.unitName),
      saleRate: s.ratePerQuintal.isEmpty ? null : s.ratePerQuintal,
      brokerageRatePerQuintal: rate ?? 0,
    );
  }

  factory BillLine.fromJson(
    Map<String, dynamic> json, {
    BillSide fallbackSide = BillSide.buyer,
  }) {
    return BillLine(
      id: json['id'] as String,
      saudaId: json['sauda_id'] as String?,
      side: _sideFromName(json['side'] as String?) ?? fallbackSide,
      date: DateTime.parse(json['date'] as String),
      saudaNumber: json['sauda_number'] as String? ?? '',
      itemName: json['item_name'] as String? ?? '',
      counterParty: json['counter_party'] as String? ?? '',
      quantityQuintals: (json['quantity_quintals'] as num).toDouble(),
      saleRate: json['sale_rate'] as String? ??
          _legacyRate(json['sale_rate_per_quintal']),
      brokerageRatePerQuintal:
          (json['brokerage_rate_per_quintal'] as num?)?.toDouble() ?? 0,
      savedAmount: (json['brokerage_amount'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'sauda_id': saudaId,
        'side': side.name,
        'date': date.toIso8601String(),
        'sauda_number': saudaNumber,
        'item_name': itemName,
        'counter_party': counterParty,
        'quantity_quintals': quantityQuintals,
        'sale_rate': saleRate,
        'brokerage_rate_per_quintal': brokerageRatePerQuintal,
        'brokerage_amount': brokerageAmount,
      };

  double? get numericSaleRate => parseNumericRate(saleRate);

  double get quantityTons => BillCalculator.toTons(quantityQuintals);

  double get brokeragePerTon =>
      BillCalculator.ratePerTon(brokerageRatePerQuintal);

  // A printed bill keeps the amount it was printed with, whatever the formula does later.
  double get brokerageAmount =>
      savedAmount ??
      BillCalculator.amount(quantityQuintals, brokerageRatePerQuintal);

  bool get hasRateWarning => brokerageRatePerQuintal <= 0;

  bool matchesQuery(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return saudaNumber.toLowerCase().contains(q) ||
        itemName.toLowerCase().contains(q) ||
        counterParty.toLowerCase().contains(q) ||
        formatBillDate(date).contains(q);
  }

  BillLine withRate(double rate) => BillLine(
        id: id,
        saudaId: saudaId,
        side: side,
        date: date,
        saudaNumber: saudaNumber,
        itemName: itemName,
        counterParty: counterParty,
        quantityQuintals: quantityQuintals,
        saleRate: saleRate,
        brokerageRatePerQuintal: rate,
      );

  BillLine frozen() => BillLine(
        id: id,
        saudaId: saudaId,
        side: side,
        date: date,
        saudaNumber: saudaNumber,
        itemName: itemName,
        counterParty: counterParty,
        quantityQuintals: quantityQuintals,
        saleRate: saleRate,
        brokerageRatePerQuintal: brokerageRatePerQuintal,
        savedAmount: brokerageAmount,
      );
}

class BillTotals {
  final double totalQuintals;
  final double totalTons;
  final double totalBrokerage;

  const BillTotals({
    required this.totalQuintals,
    required this.totalTons,
    required this.totalBrokerage,
  });

  factory BillTotals.of(List<BillLine> lines) {
    final quintals = lines.fold<double>(0, (a, l) => a + l.quantityQuintals);
    final brokerage = lines.fold<double>(0, (a, l) => a + l.brokerageAmount);
    return BillTotals(
      totalQuintals: quintals,
      totalTons: BillCalculator.toTons(quintals),
      totalBrokerage: BillCalculator.round2(brokerage),
    );
  }

  factory BillTotals.fromJson(Map<String, dynamic> json) => BillTotals(
        totalQuintals: (json['total_quintals'] as num).toDouble(),
        totalTons: (json['total_tons'] as num).toDouble(),
        totalBrokerage: (json['total_brokerage'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'total_quintals': totalQuintals,
        'total_tons': totalTons,
        'total_brokerage': totalBrokerage,
      };
}

class Bill {
  static const int schemaVersion = 1;

  final String billNumber;
  final String userId;
  final String partyId;
  final String partyName;
  final String partyCode;
  final String partyAddress;
  final String partyPanGstin;
  final BillFirm firm;
  final DateTime billDate;
  final DateTime? rangeStart;
  final DateTime? rangeEnd;
  final List<BillLine> lines;
  final BillTotals totals;
  final DateTime createdAt;

  const Bill({
    required this.billNumber,
    required this.userId,
    required this.partyId,
    required this.partyName,
    required this.partyCode,
    this.partyAddress = '',
    this.partyPanGstin = '',
    required this.firm,
    required this.billDate,
    this.rangeStart,
    this.rangeEnd,
    required this.lines,
    required this.totals,
    required this.createdAt,
  });

  factory Bill.create({
    String billNumber = '',
    required String userId,
    required String partyId,
    required String partyName,
    required String partyCode,
    String partyAddress = '',
    String partyPanGstin = '',
    required BillFirm firm,
    required DateTime billDate,
    DateTime? rangeStart,
    DateTime? rangeEnd,
    required List<BillLine> lines,
  }) {
    final frozen = lines.map((l) => l.frozen()).toList();
    return Bill(
      billNumber: billNumber,
      userId: userId,
      partyId: partyId,
      partyName: partyName,
      partyCode: partyCode,
      partyAddress: partyAddress,
      partyPanGstin: partyPanGstin,
      firm: firm,
      billDate: billDate,
      rangeStart: rangeStart,
      rangeEnd: rangeEnd,
      lines: frozen,
      totals: BillTotals.of(frozen),
      createdAt: DateTime.now(),
    );
  }

  factory Bill.fromJson(Map<String, dynamic> json) {
    // Bills saved before mixed buyer/seller bills carried one side for the whole bill.
    final legacySide = _sideFromName(json['side'] as String?);
    final lines = (json['lines'] as List)
        .map((e) => BillLine.fromJson(
              e as Map<String, dynamic>,
              fallbackSide: legacySide ?? BillSide.buyer,
            ))
        .toList();
    final totals = json['totals'] != null
        ? BillTotals.fromJson(json['totals'] as Map<String, dynamic>)
        : BillTotals.of(lines);
    return Bill(
      billNumber: json['bill_number'] as String,
      userId: json['user_id'] as String,
      partyId: json['party_id'] as String,
      partyName: json['party_name'] as String? ?? '',
      partyCode: json['party_code'] as String? ?? '',
      partyAddress: json['party_address'] as String? ?? '',
      partyPanGstin: json['party_pan_gstin'] as String? ?? '',
      firm: json['firm'] != null
          ? BillFirm.fromJson(json['firm'] as Map<String, dynamic>)
          : const BillFirm(),
      billDate: DateTime.parse(json['bill_date'] as String),
      rangeStart: json['range_start'] != null
          ? DateTime.parse(json['range_start'] as String)
          : null,
      rangeEnd: json['range_end'] != null
          ? DateTime.parse(json['range_end'] as String)
          : null,
      lines: lines,
      totals: totals,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'schema_version': schemaVersion,
        'bill_number': billNumber,
        'user_id': userId,
        'party_id': partyId,
        'party_name': partyName,
        'party_code': partyCode,
        'party_address': partyAddress,
        'party_pan_gstin': partyPanGstin,
        'firm': firm.toJson(),
        'bill_date': billDate.toIso8601String(),
        'range_start': rangeStart?.toIso8601String(),
        'range_end': rangeEnd?.toIso8601String(),
        'lines': lines.map((l) => l.toJson()).toList(),
        'totals': totals.toJson(),
        'created_at': createdAt.toIso8601String(),
      };

  // Name shown to the user when printing or sharing, e.g. AGT_Foods_India_Pvt_Ltd_BILL-0001.
  String get shareName {
    final party = partyName
        .replaceAll(RegExp(r'[^\p{L}\p{N}]+', unicode: true), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    return party.isEmpty ? billNumber : '${party}_$billNumber';
  }

  String get sharePdfFileName => '$shareName.pdf';
}
