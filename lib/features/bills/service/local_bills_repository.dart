import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/bill.dart';
import 'bills_repository.dart';

class LocalBillsRepository implements BillsRepository {
  final Future<Directory> Function() _rootDir;
  final String? Function() _currentUserId;

  LocalBillsRepository({
    Future<Directory> Function()? rootDir,
    String? Function()? currentUserId,
  })  : _rootDir = rootDir ?? getApplicationDocumentsDirectory,
        _currentUserId = currentUserId ??
            (() => Supabase.instance.client.auth.currentUser?.id);

  // Resolved on every call so a different login on the same device never reuses a stale path.
  Future<Directory> _userDir() async {
    final userId = _currentUserId();
    if (userId == null) throw StateError('Not logged in');
    final root = await _rootDir();
    return Directory('${root.path}/bills/$userId');
  }

  Future<Directory> _sideDir(BillSide side, {bool create = false}) async {
    final user = await _userDir();
    final dir = Directory('${user.path}/${side.folder}');
    if (create && !await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  static int? _numberOf(String billNumber) {
    final match = RegExp(r'(\d+)$').firstMatch(billNumber);
    return match == null ? null : int.tryParse(match.group(1)!);
  }

  Future<int> _lastNumber() async {
    final user = await _userDir();
    var last = 0;

    final counter = File('${user.path}/counter.json');
    if (await counter.exists()) {
      try {
        final json = jsonDecode(await counter.readAsString());
        last = (json['last'] as num).toInt();
      } catch (e) {
        debugPrint('[LocalBillsRepository] counter unreadable: $e');
      }
    }

    // Guards against a lost counter file re-issuing numbers that still exist on disk.
    for (final side in BillSide.values) {
      final dir = await _sideDir(side);
      if (!await dir.exists()) continue;
      await for (final entity in dir.list()) {
        final name = entity.uri.pathSegments.last;
        if (!name.endsWith('.json')) continue;
        final n = _numberOf(name.substring(0, name.length - 5));
        if (n != null) last = math.max(last, n);
      }
    }
    return last;
  }

  @override
  Future<String> nextBillNumber() async {
    final next = (await _lastNumber()) + 1;
    return 'BILL-${next.toString().padLeft(4, '0')}';
  }

  @override
  Future<List<Bill>> listBills() async {
    final bills = <Bill>[];
    for (final side in BillSide.values) {
      final dir = await _sideDir(side);
      if (!await dir.exists()) continue;
      await for (final entity in dir.list()) {
        if (entity is! File || !entity.path.endsWith('.json')) continue;
        try {
          final json = jsonDecode(await entity.readAsString());
          bills.add(Bill.fromJson(json as Map<String, dynamic>));
        } catch (e) {
          debugPrint('[LocalBillsRepository] skipped ${entity.path}: $e');
        }
      }
    }
    bills.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return bills;
  }

  @override
  Future<void> saveBill(Bill bill, Uint8List pdf) async {
    final dir = await _sideDir(bill.side, create: true);
    final jsonFile = File('${dir.path}/${bill.billNumber}.json');
    if (await jsonFile.exists()) {
      throw StateError('${bill.billNumber} already exists');
    }

    await File('${dir.path}/${bill.pdfFileName}')
        .writeAsBytes(pdf, flush: true);
    await jsonFile.writeAsString(jsonEncode(bill.toJson()), flush: true);

    final number = _numberOf(bill.billNumber);
    if (number != null) {
      final user = await _userDir();
      await File('${user.path}/counter.json')
          .writeAsString(jsonEncode({'last': number}), flush: true);
    }
  }

  @override
  Future<Uint8List> readPdf(Bill bill) async {
    final dir = await _sideDir(bill.side);
    return File('${dir.path}/${bill.pdfFileName}').readAsBytes();
  }

  @override
  Future<void> deleteBill(Bill bill) async {
    final dir = await _sideDir(bill.side);
    for (final name in ['${bill.billNumber}.json', bill.pdfFileName]) {
      final file = File('${dir.path}/$name');
      if (await file.exists()) await file.delete();
    }
  }
}
