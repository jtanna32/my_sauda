import 'bill.dart';
import 'bill_format.dart';

class BillColumn {
  final String key;
  final String Function(BillSide side) header;
  final String Function(BillLine line) value;
  final int flex;
  final bool alignRight;

  const BillColumn({
    required this.key,
    required this.header,
    required this.value,
    this.flex = 1,
    this.alignRight = false,
  });
}

String _dash(String v) => v.isEmpty ? '-' : v;

// Columns shown on the preview cards. The printed PDF has its own fixed layout in bill_pdf_service.dart.
final List<BillColumn> billColumns = [
  BillColumn(
    key: 'date',
    header: (_) => 'Date',
    value: (l) => formatBillDate(l.date),
    flex: 2,
  ),
  BillColumn(
    key: 'saudaNo',
    header: (_) => 'Sauda No',
    value: (l) => _dash(l.saudaNumber),
    flex: 2,
  ),
  BillColumn(
    key: 'item',
    header: (_) => 'Item',
    value: (l) => _dash(l.itemName),
    flex: 3,
  ),
  BillColumn(
    key: 'counterParty',
    header: (side) => side.counterPartyLabel,
    value: (l) => _dash(l.counterParty),
    flex: 3,
  ),
  BillColumn(
    key: 'tons',
    header: (_) => 'Qty (Tons)',
    value: (l) => formatBillNumber(l.quantityTons),
    alignRight: true,
  ),
  BillColumn(
    key: 'quintals',
    header: (_) => 'Qty (Qtl)',
    value: (l) => formatBillNumber(l.quantityQuintals),
    alignRight: true,
  ),
  BillColumn(
    key: 'saleRate',
    header: (_) => 'Sale Rate/Qtl',
    value: (l) => l.numericSaleRate != null
        ? formatBillAmount(l.numericSaleRate!)
        : _dash(l.saleRate ?? ''),
    alignRight: true,
  ),
  BillColumn(
    key: 'brokerageRate',
    header: (_) => 'Brok. Rate/Qtl',
    value: (l) => formatBillAmount(l.brokerageRatePerQuintal),
    alignRight: true,
  ),
  BillColumn(
    key: 'brokeragePerTon',
    header: (_) => 'Brok./Ton',
    value: (l) => formatBillAmount(l.brokeragePerTon),
    alignRight: true,
  ),
  BillColumn(
    key: 'amount',
    header: (_) => 'Brokerage',
    value: (l) => formatBillAmount(l.brokerageAmount),
    alignRight: true,
  ),
];
