import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import 'package:my_sauda/core/theme/app_theme.dart';
import '../model/bill.dart';
import '../view_model/bills_view_model.dart';

class BillViewScreen extends ConsumerStatefulWidget {
  final Bill bill;

  const BillViewScreen({super.key, required this.bill});

  @override
  ConsumerState<BillViewScreen> createState() => _BillViewScreenState();
}

class _BillViewScreenState extends ConsumerState<BillViewScreen> {
  late final Future<Uint8List> _pdf;

  @override
  void initState() {
    super.initState();
    _pdf = ref.read(billsViewModelProvider.notifier).buildPdf(widget.bill);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(widget.bill.billNumber),
        centerTitle: true,
      ),
      body: FutureBuilder<Uint8List>(
        future: _pdf,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(
                child: Text('The PDF for this bill is missing'));
          }
          return PdfPreview(
            build: (_) => snapshot.data!,
            pdfFileName: widget.bill.sharePdfFileName,
            canChangeOrientation: false,
            canChangePageFormat: false,
            canDebug: false,
          );
        },
      ),
    );
  }
}
