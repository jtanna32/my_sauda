import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:my_sauda/features/firms/model/firm.dart';
import 'package:my_sauda/features/parties/model/party.dart';
import 'package:my_sauda/features/sauda/model/sauda.dart';
import 'package:my_sauda/features/sauda/view_model/saudas_view_model.dart';
import 'package:my_sauda/core/utils/error_message.dart';
import '../model/bill.dart';
import '../model/bill_firm.dart';
import '../model/sauda_matcher.dart';
import 'bills_view_model.dart';

final billDraftViewModelProvider =
    StateNotifierProvider.autoDispose<BillDraftViewModel, BillDraftState>(
  (ref) => BillDraftViewModel(ref),
);

class BillDraftState {
  final Party? party;
  final Set<BillSide> sides;
  final DateTimeRange? dateRange;
  final bool isGenerating;
  final bool isPrinting;
  final List<BillLine> lines;
  final List<Sauda> partySaudas;
  final String? errorMessage;

  const BillDraftState({
    this.party,
    this.sides = const {BillSide.buyer, BillSide.seller},
    this.dateRange,
    this.isGenerating = false,
    this.isPrinting = false,
    this.lines = const [],
    this.partySaudas = const [],
    this.errorMessage,
  });

  bool get canGenerate => party != null && sides.isNotEmpty && !isGenerating;

  bool get canPrint => lines.isNotEmpty && !isPrinting;

  BillTotals get totals => BillTotals.of(lines);

  List<Sauda> get availableSaudas {
    final used = lines.map((l) => l.saudaId).toSet();
    return partySaudas.where((s) => !used.contains(s.id)).toList();
  }

  BillDraftState copyWith({
    Party? party,
    Set<BillSide>? sides,
    DateTimeRange? dateRange,
    bool clearDateRange = false,
    bool? isGenerating,
    bool? isPrinting,
    List<BillLine>? lines,
    List<Sauda>? partySaudas,
    String? errorMessage,
  }) {
    return BillDraftState(
      party: party ?? this.party,
      sides: sides ?? this.sides,
      dateRange: clearDateRange ? null : (dateRange ?? this.dateRange),
      isGenerating: isGenerating ?? this.isGenerating,
      isPrinting: isPrinting ?? this.isPrinting,
      lines: lines ?? this.lines,
      partySaudas: partySaudas ?? this.partySaudas,
      errorMessage: errorMessage,
    );
  }
}

class BillPrintResult {
  final Bill bill;
  final Uint8List pdf;

  const BillPrintResult(this.bill, this.pdf);
}

class BillDraftViewModel extends StateNotifier<BillDraftState> {
  final Ref _ref;
  BillDraftViewModel(this._ref) : super(const BillDraftState());

  void setParty(Party party) => state = state.copyWith(party: party);

  void setSides(Set<BillSide> sides) {
    if (sides.isNotEmpty) state = state.copyWith(sides: sides);
  }

  BillLine lineFor(Sauda sauda) {
    final side = sideOfParty(sauda, state.party!.id, state.sides)!;
    return BillLine.fromSauda(sauda, side);
  }

  void setDateRange(DateTimeRange? range) => state = range == null
      ? state.copyWith(clearDateRange: true)
      : state.copyWith(dateRange: range);

  Future<bool> generate() async {
    final party = state.party;
    if (party == null || state.sides.isEmpty) return false;

    state = state.copyWith(isGenerating: true, errorMessage: null);

    final saudasVm = _ref.read(saudasViewModelProvider.notifier);
    await saudasVm.loadSaudas();
    final saudasState = _ref.read(saudasViewModelProvider);

    if (saudasState.errorMessage != null) {
      state = state.copyWith(
        isGenerating: false,
        errorMessage: saudasState.errorMessage,
      );
      return false;
    }

    final all = saudasState.allSaudas;
    final partySaudas = matchSaudas(all, partyId: party.id, sides: state.sides);
    final inRange = matchSaudas(
      all,
      partyId: party.id,
      sides: state.sides,
      range: state.dateRange,
    );

    state = state.copyWith(
      isGenerating: false,
      partySaudas: partySaudas,
      lines: inRange.map(lineFor).toList(),
    );
    return true;
  }

  void removeLine(String lineId) {
    state = state.copyWith(
      lines: state.lines.where((l) => l.id != lineId).toList(),
    );
  }

  // Edits the bill line only; the underlying sauda is never touched.
  void updateRate(String lineId, double rate) {
    state = state.copyWith(
      lines: [
        for (final l in state.lines) l.id == lineId ? l.withRate(rate) : l,
      ],
    );
  }

  void addSaudas(List<Sauda> saudas) {
    if (saudas.isEmpty) return;
    final lines = [
      ...state.lines,
      ...saudas.map(lineFor),
    ]..sort((a, b) => a.date.compareTo(b.date));
    state = state.copyWith(lines: lines);
  }

  void addNewSauda(Sauda sauda) {
    state = state.copyWith(
      partySaudas: [...state.partySaudas, sauda],
      lines: [...state.lines, lineFor(sauda)]
        ..sort((a, b) => a.date.compareTo(b.date)),
    );
  }

  Future<BillPrintResult?> printBill(Firm firm) async {
    final party = state.party;
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (party == null || userId == null || !state.canPrint) {
      return null;
    }

    state = state.copyWith(isPrinting: true, errorMessage: null);
    try {
      final draft = Bill.create(
        userId: userId,
        partyId: party.id,
        partyName: party.partyName,
        partyCode: party.partyCode,
        partyAddress: [party.city, party.state]
            .where((v) => v.trim().isNotEmpty)
            .join(', '),
        partyPanGstin: party.panGstin ?? '',
        firm: BillFirm.fromFirm(firm),
        billDate: DateTime.now(),
        rangeStart: state.dateRange?.start,
        rangeEnd: state.dateRange?.end,
        lines: state.lines,
      );
      final billsVm = _ref.read(billsViewModelProvider.notifier);
      final saved = await billsVm.createBill(draft);
      if (saved == null) {
        state = state.copyWith(
          isPrinting: false,
          errorMessage: _ref.read(billsViewModelProvider).errorMessage,
        );
        return null;
      }
      final pdf = await billsVm.buildPdf(saved);
      state = state.copyWith(isPrinting: false);
      return BillPrintResult(saved, pdf);
    } catch (e) {
      debugPrint('[BillDraftViewModel] printBill error: $e');
      state = state.copyWith(isPrinting: false, errorMessage: friendlyError(e));
      return null;
    }
  }

  void clearError() => state = state.copyWith(errorMessage: null);
}
