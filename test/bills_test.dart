import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_sauda/features/bills/model/bill.dart';
import 'package:my_sauda/features/bills/model/bill_calculator.dart';
import 'package:my_sauda/features/bills/model/bill_firm.dart';
import 'package:my_sauda/features/bills/model/bill_format.dart';
import 'package:my_sauda/features/bills/model/sauda_matcher.dart';
import 'package:my_sauda/features/bills/service/bill_pdf_service.dart';
import 'package:my_sauda/features/bills/service/local_bills_repository.dart';
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
    ratePerQuintal: 2500,
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
    side: side,
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

    test('a party appears only on the chosen side', () {
      expect(
        matchSaudas(all, partyId: 'A', side: BillSide.buyer).map((s) => s.id),
        ['1'],
      );
      expect(
        matchSaudas(all, partyId: 'A', side: BillSide.seller).map((s) => s.id),
        ['2'],
      );
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
        side: BillSide.buyer,
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

  group('local repository', () {
    late Directory root;
    String? user;
    late LocalBillsRepository repo;
    final pdf = Uint8List.fromList([1, 2, 3]);

    setUp(() async {
      root = await Directory.systemTemp.createTemp('bills_test');
      user = 'u1';
      repo = LocalBillsRepository(
        rootDir: () async => root,
        currentUserId: () => user,
      );
    });

    tearDown(() => root.delete(recursive: true));

    test('numbers are sequential and never reused after delete', () async {
      expect(await repo.nextBillNumber(), 'BILL-0001');
      await repo.saveBill(makeBill('BILL-0001', BillSide.buyer), pdf);
      expect(await repo.nextBillNumber(), 'BILL-0002');
      final second = makeBill('BILL-0002', BillSide.seller);
      await repo.saveBill(second, pdf);
      await repo.deleteBill(second);
      expect(await repo.nextBillNumber(), 'BILL-0003');
    });

    test('bills are filed by side and listed newest first', () async {
      await repo.saveBill(makeBill('BILL-0001', BillSide.buyer), pdf);
      await Future<void>.delayed(const Duration(milliseconds: 5));
      await repo.saveBill(makeBill('BILL-0002', BillSide.seller), pdf);

      expect(
        File('${root.path}/bills/u1/buyers_bill/BILL-0001.json').existsSync(),
        isTrue,
      );
      expect(
        File('${root.path}/bills/u1/sellers_bill/BILL-0002.pdf').existsSync(),
        isTrue,
      );
      final list = await repo.listBills();
      expect(list.map((b) => b.billNumber), ['BILL-0002', 'BILL-0001']);
    });

    test('one user never sees another user\'s bills', () async {
      await repo.saveBill(makeBill('BILL-0001', BillSide.buyer), pdf);
      user = 'u2';
      expect(await repo.listBills(), isEmpty);
      expect(await repo.nextBillNumber(), 'BILL-0001');
      user = 'u1';
      expect(await repo.listBills(), hasLength(1));
    });

    test('logged out throws', () async {
      user = null;
      expect(repo.listBills(), throwsStateError);
    });

    test('pdf can be read back and delete removes both files', () async {
      final bill = makeBill('BILL-0001', BillSide.buyer);
      await repo.saveBill(bill, pdf);
      expect(await repo.readPdf(bill), pdf);
      await repo.deleteBill(bill);
      expect(await repo.listBills(), isEmpty);
    });
  });
}
