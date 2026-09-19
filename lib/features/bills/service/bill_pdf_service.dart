import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../model/bill.dart';
import '../model/bill_calculator.dart';
import '../model/bill_format.dart';

const _orange = PdfColor.fromInt(0xFFED7D31);
const _rowsPerPage = 10;
const _greeting = 'Shree Ganeshay Namah';

class _Col {
  final String header;
  final double width;
  final pw.Alignment align;
  final String Function(BillLine line, Bill bill, int number) value;

  const _Col(this.header, this.width, this.align, this.value);
}

String _buyerOf(BillLine l, Bill b) =>
    b.side == BillSide.buyer ? b.partyName : l.counterParty;

String _sellerOf(BillLine l, Bill b) =>
    b.side == BillSide.seller ? b.partyName : l.counterParty;

// Column order and widths follow the broker's printed bill; widths add up to the A4 content width.
final List<_Col> _cols = [
  _Col('No.', 26, pw.Alignment.topCenter, (l, b, n) => '$n'),
  _Col('Date', 48, pw.Alignment.topCenter,
      (l, b, n) => formatBillDateDashed(l.date)),
  _Col('Item', 58, pw.Alignment.topCenter,
      (l, b, n) => l.itemName.toUpperCase()),
  _Col('Weight\n(ton)', 46, pw.Alignment.topLeft,
      (l, b, n) => l.quantityTons.toStringAsFixed(3)),
  _Col('Rate', 52, pw.Alignment.topLeft, (l, b, n) {
    final rate = l.saleRatePerQuintal;
    return rate == null
        ? '-'
        : formatBillAmount(BillCalculator.ratePerTon(rate));
  }),
  _Col('Buyer', 96, pw.Alignment.topLeft, (l, b, n) => _buyerOf(l, b)),
  _Col('Seller', 86, pw.Alignment.topCenter, (l, b, n) => _sellerOf(l, b)),
  _Col('Brokerage', 62, pw.Alignment.topCenter,
      (l, b, n) => formatBillAmount(l.brokerageAmount)),
  _Col('Broker\nName', 71, pw.Alignment.topCenter, (l, b, n) => b.firm.name),
];

class BillPdfService {
  Future<Uint8List> build(Bill bill) async {
    final doc = pw.Document(title: bill.billNumber);
    final serif = pw.Font.times();
    final serifBold = pw.Font.timesBold();
    final sans = pw.Font.helvetica();
    final sansBold = pw.Font.helveticaBold();

    final serifStyle = pw.TextStyle(font: serif, fontSize: 12, color: _orange);
    final serifBoldStyle =
        pw.TextStyle(font: serifBold, fontSize: 12, color: _orange);
    final cellStyle = pw.TextStyle(font: sans, fontSize: 8);

    final pageCount = (bill.lines.length / _rowsPerPage).ceil();
    for (var page = 0; page < pageCount; page++) {
      final start = page * _rowsPerPage;
      final end = (start + _rowsPerPage).clamp(0, bill.lines.length);
      final isLast = page == pageCount - 1;

      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(24),
          build: (_) => pw.Container(
            decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.7)),
            child: pw.Column(
              mainAxisSize: pw.MainAxisSize.min,
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                _firmHeader(bill, serifStyle),
                if (bill.firm.address.isNotEmpty)
                  _block(
                    pw.Center(
                      child: pw.Text(
                        bill.firm.address,
                        textAlign: pw.TextAlign.center,
                        style: serifStyle,
                      ),
                    ),
                  ),
                _partyBlock(bill, serifStyle),
                _table(bill, start, end, serifBoldStyle, cellStyle),
                if (isLast) _totalRow(bill, serifBoldStyle, sansBold),
                _bankBlock(bill, serifBoldStyle),
              ],
            ),
          ),
        ),
      );
    }

    return doc.save();
  }

  pw.Widget _block(pw.Widget child, {bool top = true}) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: pw.BoxDecoration(
        border: top ? const pw.Border(top: pw.BorderSide(width: 0.7)) : null,
      ),
      child: child,
    );
  }

  pw.Widget _firmHeader(Bill bill, pw.TextStyle style) {
    final firm = bill.firm;
    return _block(
      top: false,
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            flex: 4,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (firm.phoneNumber.isNotEmpty)
                  pw.Text('Phone: (${firm.phoneNumber})', style: style),
                if (firm.alternatePhoneNumber.isNotEmpty)
                  pw.Text('Alt. Phone: (${firm.alternatePhoneNumber})',
                      style: style),
              ],
            ),
          ),
          pw.Expanded(
            flex: 3,
            child: pw.Center(
              child: pw.Text(_greeting, style: style.copyWith(fontSize: 8)),
            ),
          ),
          pw.Expanded(
            flex: 4,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(firm.name.toUpperCase(), style: style),
                if (firm.proprietorName.isNotEmpty)
                  pw.Text('Proprietor. ${firm.proprietorName}', style: style),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _partyBlock(Bill bill, pw.TextStyle style) {
    return pw.Container(
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(width: 0.7)),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            flex: 63,
            child: pw.Container(
              padding: const pw.EdgeInsets.all(6),
              decoration: const pw.BoxDecoration(
                border: pw.Border(right: pw.BorderSide(width: 0.7)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Party Name: ${bill.partyName}', style: style),
                  pw.Text('Address: ${bill.partyAddress}', style: style),
                  pw.Text('Pan/GST No.: ${bill.partyPanGstin}', style: style),
                  pw.Text('Broker: ${bill.firm.name.toUpperCase()}',
                      style: style),
                ],
              ),
            ),
          ),
          pw.Expanded(
            flex: 37,
            child: pw.Padding(
              padding: const pw.EdgeInsets.all(6),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Bill Number: ${bill.billNumber}', style: style),
                  pw.Text('Date: ${formatBillDate(bill.billDate)}',
                      style: style),
                  pw.Text('Chalan Number:', style: style),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _table(
    Bill bill,
    int start,
    int end,
    pw.TextStyle headerStyle,
    pw.TextStyle cellStyle,
  ) {
    return pw.Container(
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(width: 0.7)),
      ),
      child: pw.Table(
        border: const pw.TableBorder(
          horizontalInside: pw.BorderSide(width: 0.5),
          verticalInside: pw.BorderSide(width: 0.5),
        ),
        columnWidths: {
          for (var i = 0; i < _cols.length; i++)
            i: pw.FixedColumnWidth(_cols[i].width),
        },
        children: [
          pw.TableRow(
            decoration: const pw.BoxDecoration(color: _orange),
            children: [
              for (final c in _cols)
                pw.Container(
                  alignment: pw.Alignment.center,
                  padding: const pw.EdgeInsets.symmetric(vertical: 4),
                  child: pw.Text(
                    c.header,
                    textAlign: pw.TextAlign.center,
                    style: headerStyle.copyWith(
                      color: PdfColors.white,
                      fontSize: 10,
                    ),
                  ),
                ),
            ],
          ),
          for (var i = start; i < end; i++)
            pw.TableRow(
              children: [
                for (final c in _cols)
                  pw.Container(
                    alignment: c.align,
                    padding: const pw.EdgeInsets.all(3),
                    constraints: const pw.BoxConstraints(minHeight: 34),
                    child: pw.Text(
                      c.value(bill.lines[i], bill, i + 1),
                      maxLines: 3,
                      textAlign: c.align == pw.Alignment.topCenter
                          ? pw.TextAlign.center
                          : pw.TextAlign.left,
                      style: cellStyle,
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  pw.Widget _totalRow(Bill bill, pw.TextStyle labelStyle, pw.Font amountFont) {
    double width(int from, int to) =>
        _cols.sublist(from, to).fold<double>(0, (a, c) => a + c.width);

    pw.Widget cell(double w, pw.Widget child, {bool right = true}) {
      return pw.Container(
        width: w,
        height: 30,
        padding: const pw.EdgeInsets.all(4),
        decoration: pw.BoxDecoration(
          border:
              right ? const pw.Border(right: pw.BorderSide(width: 0.5)) : null,
        ),
        child: child,
      );
    }

    final pan = bill.firm.pan;
    return pw.Container(
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(width: 0.7)),
      ),
      child: pw.Row(
        children: [
          cell(
            width(0, 6),
            pw.Text(pan.isEmpty ? '' : 'Pan No.: $pan', style: labelStyle),
          ),
          cell(
            _cols[6].width,
            pw.Center(
              child: pw.Text('Total', style: labelStyle.copyWith(fontSize: 14)),
            ),
          ),
          cell(
            _cols[7].width,
            pw.Text(
              formatBillAmount(bill.totals.totalBrokerage),
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(font: amountFont, fontSize: 9),
            ),
          ),
          cell(_cols[8].width, pw.SizedBox(), right: false),
        ],
      ),
    );
  }

  pw.Widget _bankBlock(Bill bill, pw.TextStyle style) {
    final firm = bill.firm;
    return _block(
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (firm.bankAccountName.isNotEmpty)
                  pw.Text('A/c Name: ${firm.bankAccountName},', style: style),
                if (firm.bankName.isNotEmpty)
                  pw.Text(firm.bankName, style: style),
                if (firm.bankAccountNumber.isNotEmpty)
                  pw.Text('A/c. No.: ${firm.bankAccountNumber}', style: style),
                if (firm.bankIfsc.isNotEmpty)
                  pw.Text('IFSC Code: ${firm.bankIfsc}', style: style),
              ],
            ),
          ),
          pw.Text('For ${firm.name},', style: style),
        ],
      ),
    );
  }
}
