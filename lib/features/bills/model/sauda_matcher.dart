import 'package:flutter/material.dart' show DateTimeRange;
import 'package:my_sauda/features/sauda/model/sauda.dart';
import 'bill.dart';

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

// The role [partyId] plays in [s], limited to the roles the bill covers. Buyer wins if the party is on both sides.
BillSide? sideOfParty(Sauda s, String partyId, Set<BillSide> sides) {
  for (final side in BillSide.values) {
    if (sides.contains(side) && side.partyIdOf(s) == partyId) return side;
  }
  return null;
}

List<Sauda> matchSaudas(
  List<Sauda> all, {
  required String partyId,
  required Set<BillSide> sides,
  DateTimeRange? range,
}) {
  final matched = all.where((s) {
    if (sideOfParty(s, partyId, sides) == null) return false;
    if (range == null) return true;
    final d = _dateOnly(s.saudaDate);
    return !d.isBefore(_dateOnly(range.start)) &&
        !d.isAfter(_dateOnly(range.end));
  }).toList();
  matched.sort((a, b) {
    final byDate = a.saudaDate.compareTo(b.saudaDate);
    return byDate != 0 ? byDate : a.saudaNumber.compareTo(b.saudaNumber);
  });
  return matched;
}
