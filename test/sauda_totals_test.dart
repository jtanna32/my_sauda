import 'package:flutter_test/flutter_test.dart';
import 'package:my_sauda/features/parties/model/party.dart';
import 'package:my_sauda/features/sauda/model/sauda.dart';
import 'package:my_sauda/features/sauda/view_model/saudas_view_model.dart';

Sauda sauda(String id, double qty, String unit, String buyer, String seller,
    {double buyerBrok = 100, double sellerBrok = 40}) {
  return Sauda(
    id: id,
    userId: 'u',
    saudaNumber: id,
    saudaDate: DateTime(2026, 9, 5),
    itemId: 'i',
    quantity: qty,
    unitId: 'un',
    unitName: unit,
    ratePerQuintal: '1000',
    buyerPartyId: buyer,
    buyerSideBrokerage: buyerBrok,
    sellerPartyId: seller,
    sellerSideBrokerage: sellerBrok,
    sendToParties: false,
    createdAt: DateTime(2026, 9, 5),
  );
}

Party party(String id) => Party(
      id: id,
      userId: 'u',
      partyCode: id,
      partyName: id,
      city: '',
      state: '',
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

void main() {
  final saudas = [
    sauda('1', 25, 'Ton', 'A', 'B'),
    sauda('2', 50, 'Quintal', 'C', 'A'),
    sauda('3', 2500, 'Kg', 'C', 'D'),
  ];

  test('tons are converted from ton, quintal and kg', () {
    expect(SaudasState(saudas: saudas).totalTons, closeTo(25 + 5 + 2.5, 1e-9));
  });

  test('brokerage counts both sides when no party filter is set', () {
    expect(SaudasState(saudas: saudas).totalBrokerage, 420);
  });

  test('party filter counts only that party\'s side', () {
    expect(
      SaudasState(saudas: saudas.take(2).toList(), partyFilter: party('A'))
          .totalBrokerage,
      100 + 40,
    );
  });

  test('buyer-only and seller-only filters count that side', () {
    expect(
      SaudasState(saudas: saudas, buyerFilter: party('C')).totalBrokerage,
      300,
    );
    expect(
      SaudasState(saudas: saudas, sellerFilter: party('A')).totalBrokerage,
      120,
    );
  });

  test('empty list totals are zero', () {
    expect(const SaudasState().totalTons, 0);
    expect(const SaudasState().totalBrokerage, 0);
  });
}
