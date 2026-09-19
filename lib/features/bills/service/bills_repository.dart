import 'dart:typed_data';
import '../model/bill.dart';

abstract class BillsRepository {
  Future<List<Bill>> listBills();

  // The next number is only committed once saveBill succeeds, so a failed print leaves no gap.
  Future<String> nextBillNumber();

  Future<void> saveBill(Bill bill, Uint8List pdf);

  Future<Uint8List> readPdf(Bill bill);

  Future<void> deleteBill(Bill bill);
}
