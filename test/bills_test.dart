import 'package:flutter_test/flutter_test.dart';
import 'package:my_sauda/features/bills/model/bill.dart';
import 'package:my_sauda/features/bills/model/bill_calculator.dart';
import 'package:my_sauda/features/bills/model/bill_columns.dart';
import 'package:my_sauda/features/bills/model/bill_firm.dart';
import 'package:my_sauda/features/bills/model/bill_format.dart';
import 'package:my_sauda/features/bills/model/sauda_matcher.dart';
import 'package:my_sauda/features/bills/service/bill_pdf_service.dart';
import 'package:my_sauda/features/sauda/model/sauda.dart';

Sauda sauda({
  String id = 's1',
  String number = 'S-1',
  String buyer = 'A',
  String seller = 'B',
  double quantity = 25,
  String unit = 'Ton',
  double? buyerRate = 10,
  double? sellerRate = 4,
  String rate = '2500',
  DateTime? date,
}) {
  return Sauda(
    id: id,
    userId: 'u',
    saudaNumber: number,
    saudaDate: date ?? DateTime(2026, 1, 10),
    itemId: 'i',
    itemName: 'Wheat',
    quantity: quantity,
    unitId: 'un',
    unitName: unit,
    ratePerQuintal: rate,
    buyerPartyId: buyer,
    buyerPartyName: 'Buyer $buyer',
    buyerBrokerageRate: buyerRate,
    buyerSideBrokerage: 0,
    sellerPartyId: seller,
    sellerPartyName: 'Seller $seller',
    sellerBrokerageRate: sellerRate,
    sellerSideBrokerage: 0,
    sendToParties: false,
    createdAt: DateTime(2026, 1, 10),
  );
}

Bill makeBill(String number, BillSide side, {String userId = 'u1'}) {
  return Bill.create(
    billNumber: number,
    userId: userId,
    partyId: 'A',
    partyName: 'Party A',
    partyCode: 'PA',
    firm: const BillFirm(name: 'Jeet Consultancy', pan: 'ABCDE1234F'),
    billDate: DateTime(2026, 2, 1),
    lines: [BillLine.fromSauda(sauda(), side)],
  );
}

void main() {
  group('calculation', () {
    test('25 tons at Rs10/qtl is 250 qtl and Rs2,500; Rs100 per ton', () {
      final line = BillLine.fromSauda(sauda(), BillSide.buyer);
      expect(line.quantityQuintals, 250);
      expect(line.quantityTons, 25);
      expect(line.brokerageAmount, 2500);
      expect(line.brokeragePerTon, 100);
    });

    test('quintal and kg units convert', () {
      expect(BillCalculator.toQuintals(40, 'Quintal'), 40);
      expect(BillCalculator.toQuintals(500, 'Kg'), 5);
    });

    test('uses the chosen side rate', () {
      final s = sauda();
      expect(BillLine.fromSauda(s, BillSide.buyer).brokerageRatePerQuintal, 10);
      expect(BillLine.fromSauda(s, BillSide.seller).brokerageRatePerQuintal, 4);
      expect(BillLine.fromSauda(s, BillSide.buyer).counterParty, 'Seller B');
      expect(BillLine.fromSauda(s, BillSide.seller).counterParty, 'Buyer A');
    });

    test('null or zero rate gives 0 and a warning', () {
      final nullRate =
          BillLine.fromSauda(sauda(buyerRate: null), BillSide.buyer);
      final zeroRate = BillLine.fromSauda(sauda(buyerRate: 0), BillSide.buyer);
      expect(nullRate.brokerageAmount, 0);
      expect(nullRate.hasRateWarning, isTrue);
      expect(zeroRate.hasRateWarning, isTrue);
    });

    test('totals are the sum of rounded rows', () {
      final a = BillLine.fromSauda(
          sauda(quantity: 3.333, buyerRate: 10.005), BillSide.buyer);
      final b = BillLine.fromSauda(
          sauda(id: 's2', quantity: 3.333, buyerRate: 10.005), BillSide.buyer);
      final totals = BillTotals.of([a, b]);
      expect(totals.totalBrokerage,
          BillCalculator.round2(a.brokerageAmount + b.brokerageAmount));
      expect(totals.totalQuintals, closeTo(66.66, 1e-9));
    });

    test('editing a rate changes only the line', () {
      final s = sauda();
      final line = BillLine.fromSauda(s, BillSide.buyer).withRate(12);
      expect(line.brokerageAmount, 3000);
      expect(s.buyerBrokerageRate, 10);
    });

    test('search matches sauda no, item, counter-party and date', () {
      final line = BillLine.fromSauda(sauda(number: 'S-77'), BillSide.buyer);
      expect(line.matchesQuery('s-77'), isTrue);
      expect(line.matchesQuery('WHEA'), isTrue);
      expect(line.matchesQuery('seller b'), isTrue);
      expect(line.matchesQuery('10/01/2026'), isTrue);
      expect(line.matchesQuery('rice'), isFalse);
      expect(line.matchesQuery('  '), isTrue);
    });

    test('a text rate is kept as typed and never used in brokerage', () {
      final line =
          BillLine.fromSauda(sauda(rate: 'Rate multiple'), BillSide.buyer);
      expect(line.saleRate, 'Rate multiple');
      expect(line.numericSaleRate, isNull);
      expect(line.brokerageAmount, 2500);
      expect(billColumns.firstWhere((c) => c.key == 'saleRate').value(line),
          'Rate multiple');
    });

    test('party GSTIN comes with the sauda join', () {
      final sauda = Sauda.fromJson({
        'id': 's',
        'user_id': 'u',
        'sauda_number': 'S-1',
        'sauda_date': '2026-01-10',
        'item_id': 'i',
        'quantity': 1,
        'unit_id': 'un',
        'rate_per_quintal': 100,
        'buyer_party_id': 'A',
        'buyer_party': {
          'party_name': 'Buyer A',
          'pan_gstin': '27AAACA1234A1Z5',
          'delivery_address': 'Plot 5, GIDC',
          'city': 'Surat',
          'state': 'Gujarat',
        },
        'buyer_side_brokerage': 0,
        'seller_party_id': 'B',
        'seller_party': {'party_name': 'Seller B'},
        'seller_side_brokerage': 0,
        'created_at': '2026-01-10T00:00:00Z',
      });
      expect(sauda.buyerPartyGstin, '27AAACA1234A1Z5');
      expect(sauda.buyerPartyAddress, 'Plot 5, GIDC');
      expect(sauda.buyerPartyCity, 'Surat');
      expect(sauda.buyerPartyState, 'Gujarat');
      expect(sauda.sellerPartyGstin, isNull);
      expect(sauda.sellerPartyCity, isNull);
    });

    test('numeric rate parsing is strict', () {
      expect(parseNumericRate('4525'), 4525);
      expect(parseNumericRate(' 4525.50 '), 4525.5);
      expect(parseNumericRate('45,250'), isNull);
      expect(parseNumericRate('NaN'), isNull);
      expect(parseNumericRate('Rate multiple'), isNull);
      expect(parseNumericRate(''), isNull);
    });

    test('rate arrives as number or text from the database', () {
      Sauda parse(dynamic rate) => Sauda.fromJson({
            'id': 's',
            'user_id': 'u',
            'sauda_number': 'S-1',
            'sauda_date': '2026-01-10',
            'item_id': 'i',
            'quantity': 1,
            'unit_id': 'un',
            'rate_per_quintal': rate,
            'buyer_party_id': 'A',
            'buyer_side_brokerage': 0,
            'seller_party_id': 'B',
            'seller_side_brokerage': 0,
            'created_at': '2026-01-10T00:00:00Z',
          });
      expect(parse(4525.0).ratePerQuintal, '4525');
      expect(parse(4525.5).ratePerQuintal, '4525.5');
      expect(parse('Rate multiple').ratePerQuintal, 'Rate multiple');
      expect(parse(4525).rateDisplay, '₹4525.00/qtl');
      expect(parse('Rate multiple').rateDisplay, 'Rate multiple');
    });

    test('bills saved with the old numeric rate key still load', () {
      final json = makeBill('BILL-0001', BillSide.buyer).toJson();
      final line = (json['lines'] as List).first as Map<String, dynamic>;
      line
        ..remove('sale_rate')
        ..['sale_rate_per_quintal'] = 2500.0;
      expect(Bill.fromJson(json).lines.first.saleRate, '2500');
    });

    test('Indian amount grouping', () {
      expect(formatBillAmount(2500), '2,500.00');
      expect(formatBillAmount(125000.5), '1,25,000.50');
    });
  });

  group('matching', () {
    final all = [
      sauda(id: '1', buyer: 'A', seller: 'B', date: DateTime(2026, 1, 5)),
      sauda(id: '2', buyer: 'C', seller: 'A', date: DateTime(2026, 1, 20)),
      sauda(id: '3', buyer: 'C', seller: 'D'),
    ];

    test('one role only matches that role', () {
      expect(
        matchSaudas(all, partyId: 'A', sides: {BillSide.buyer})
            .map((s) => s.id),
        ['1'],
      );
      expect(
        matchSaudas(all, partyId: 'A', sides: {BillSide.seller})
            .map((s) => s.id),
        ['2'],
      );
    });

    test('both roles match every sauda of the party, oldest first', () {
      final both = {BillSide.buyer, BillSide.seller};
      expect(
        matchSaudas(all, partyId: 'A', sides: both).map((s) => s.id),
        ['1', '2'],
      );
    });

    test('each row gets the rate of the side the party played', () {
      final s1 =
          sauda(id: '1', buyer: 'A', seller: 'B', buyerRate: 10, sellerRate: 4);
      final s2 =
          sauda(id: '2', buyer: 'C', seller: 'A', buyerRate: 10, sellerRate: 4);
      final both = {BillSide.buyer, BillSide.seller};
      final rows = [s1, s2]
          .map((s) => BillLine.fromSauda(s, sideOfParty(s, 'A', both)!))
          .toList();
      expect(rows.map((l) => l.side), [BillSide.buyer, BillSide.seller]);
      expect(rows.map((l) => l.brokerageRatePerQuintal), [10, 4]);
      expect(rows.map((l) => l.counterParty), ['Seller B', 'Buyer C']);
    });
  });

  group('snapshot', () {
    test('JSON round trip keeps printed amounts even if the rate changes', () {
      final bill = makeBill('BILL-0001', BillSide.buyer);
      final json = bill.toJson();
      (json['lines'] as List).first['brokerage_rate_per_quintal'] = 99;
      final restored = Bill.fromJson(json);
      expect(restored.lines.first.brokerageAmount, 2500);
      expect(restored.totals.totalBrokerage, 2500);
    });

    test('firm is part of the snapshot', () {
      final restored =
          Bill.fromJson(makeBill('BILL-0001', BillSide.buyer).toJson());
      expect(restored.firm.name, 'Jeet Consultancy');
      expect(restored.firm.pan, 'ABCDE1234F');
    });

    test('bills saved without a firm still load', () {
      final json = makeBill('BILL-0001', BillSide.buyer).toJson()
        ..remove('firm');
      expect(Bill.fromJson(json).firm.name, '');
    });

    test('share name is party name plus bill number, extension added once', () {
      final bill = makeBill('BILL-0007', BillSide.buyer);
      expect(bill.shareName, 'Party_A_BILL-0007');
      expect(bill.sharePdfFileName, 'Party_A_BILL-0007.pdf');
    });

    test('PDF builds', () async {
      final pdf =
          await BillPdfService().build(makeBill('BILL-0001', BillSide.seller));
      expect(String.fromCharCodes(pdf.take(4)), '%PDF');
    });
  });

  group('pdf', () {
    test('25 rows paginate at 10 per page, one page per 10 rows', () async {
      final lines = [
        for (var i = 0; i < 25; i++)
          BillLine.fromSauda(
            sauda(id: 's$i', number: 'S-$i', quantity: 25.25 + i),
            BillSide.buyer,
          ),
      ];
      final bill = Bill.create(
        billNumber: 'BILL-0002',
        userId: 'u1',
        partyId: 'A',
        partyName: 'AGT Foods India Pvt Ltd',
        partyCode: 'AGT',
        firm: const BillFirm(name: 'Jeet Consultancy'),
        billDate: DateTime(2026, 2, 1),
        lines: lines,
      );
      final pdf = await BillPdfService().build(bill);
      final pages =
          RegExp('/Type */Page[^s]').allMatches(String.fromCharCodes(pdf));
      expect(pages.length, 3);
    });
  });

  // Keeps the model and the create_bill SQL function (which reads these keys) in step.
  group('create_bill contract', () {
    final json = makeBill('', BillSide.buyer).toJson();

    test('payload has the keys the SQL function reads', () {
      expect(json['party_id'], 'A');
      expect(json['party_name'], 'Party A');
      expect(DateTime.tryParse(json['bill_date'] as String), isNotNull);
      expect(
        (json['totals'] as Map<String, dynamic>)['total_brokerage'],
        isA<num>(),
      );
    });

    test('a saved bill comes back with the server-assigned number', () {
      final saved = Bill.fromJson({...json, 'bill_number': 'BILL-0042'});
      expect(saved.billNumber, 'BILL-0042');
      expect(saved.lines, hasLength(1));
      expect(saved.totals.totalBrokerage, 2500);
    });

    test('an unsaved draft has no bill number yet', () {
      expect(makeBill('', BillSide.buyer).billNumber, '');
    });
  });
}
