import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart';
import 'package:my_sauda/core/theme/app_theme.dart';
import 'package:my_sauda/features/firms/widgets/firm_picker_sheet.dart';
import 'package:my_sauda/features/sauda/model/new_sauda_preset.dart';
import 'package:my_sauda/features/sauda/model/sauda.dart';
import '../model/bill.dart';
import '../model/bill_format.dart';
import '../view_model/bill_draft_view_model.dart';
import '../widgets/add_saudas_sheet.dart';
import '../widgets/bill_line_card.dart';
import '../widgets/bill_totals_footer.dart';

class BillPreviewScreen extends ConsumerStatefulWidget {
  const BillPreviewScreen({super.key});

  @override
  ConsumerState<BillPreviewScreen> createState() => _BillPreviewScreenState();
}

class _BillPreviewScreenState extends ConsumerState<BillPreviewScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _editRate(String lineId, double current) async {
    final controller = TextEditingController(
      text: current > 0 ? current.toStringAsFixed(2) : '',
    );
    final rate = await showDialog<double>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Brokerage rate (₹/qtl)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: controller,
              autofocus: true,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Rate per quintal'),
            ),
            const SizedBox(height: 8),
            Text(
              'Applies to this bill only. The sauda is not changed.',
              style: Theme.of(dialogContext).textTheme.bodyMedium!.copyWith(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final v = double.tryParse(controller.text.trim());
              if (v != null && v >= 0) Navigator.pop(dialogContext, v);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (rate != null && mounted) {
      ref.read(billDraftViewModelProvider.notifier).updateRate(lineId, rate);
    }
  }

  Future<void> _addSaudas() async {
    final state = ref.read(billDraftViewModelProvider);
    final picked = await showAddSaudasSheet(
      context: context,
      saudas: state.availableSaudas,
      side: state.side!,
    );
    if (picked != null && mounted) {
      ref.read(billDraftViewModelProvider.notifier).addSaudas(picked);
    }
  }

  Future<void> _addNewSauda() async {
    final state = ref.read(billDraftViewModelProvider);
    final side = state.side!;
    final party = state.party!;

    final created = await context.push<Sauda>(
      '/add-sauda',
      extra: NewSaudaPreset(
        buyer: side == BillSide.buyer ? party : null,
        seller: side == BillSide.seller ? party : null,
      ),
    );
    if (created != null && mounted) {
      ref.read(billDraftViewModelProvider.notifier).addNewSauda(created);
    }
  }

  Future<void> _print() async {
    final firm = await showFirmPicker(context: context);
    if (firm == null || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    final result =
        await ref.read(billDraftViewModelProvider.notifier).printBill(firm);

    if (result == null) {
      final message = ref.read(billDraftViewModelProvider).errorMessage;
      messenger.showSnackBar(
        SnackBar(
          content: Text(message ?? 'Failed to save bill'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    messenger.showSnackBar(
      SnackBar(
        content: Text('${result.bill.billNumber} saved'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );

    await Printing.layoutPdf(
      onLayout: (_) async => result.pdf,
      name: result.bill.pdfFileName,
    );

    router.pop();
    router.pop();
  }

  void _onSearch(String value) => setState(() => _query = value.trim());

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(billDraftViewModelProvider);
    final vm = ref.read(billDraftViewModelProvider.notifier);
    final party = state.party!;
    final side = state.side!;
    final visible = _query.isEmpty
        ? state.lines
        : state.lines.where((l) => l.matchesQuery(_query)).toList();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('${side.title} Preview'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${party.partyName} (${party.partyCode})',
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  state.dateRange == null
                      ? 'All saudas to date · ${side.label} side'
                      : '${formatBillDate(state.dateRange!.start)} - ${formatBillDate(state.dateRange!.end)} · ${side.label} side',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: state.availableSaudas.isEmpty
                            ? null
                            : () => _addSaudas(),
                        icon: const Icon(Icons.playlist_add),
                        label: const Text('Add Sauda'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _addNewSauda(),
                        icon: const Icon(Icons.add),
                        label: const Text('New Sauda'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (state.lines.isNotEmpty || _query.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearch,
                decoration: InputDecoration(
                  hintText:
                      'Search sauda no, item, ${side.counterPartyLabel.toLowerCase()}, date...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            _searchController.clear();
                            _onSearch('');
                          },
                        ),
                ),
              ),
            ),
          if (_query.isNotEmpty && state.lines.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Showing ${visible.length} of ${state.lines.length} rows · totals and print include all rows',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                ),
              ),
            ),
          Expanded(
            child: state.lines.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        state.partySaudas.isEmpty
                            ? 'No saudas found for this party as ${side.label.toLowerCase()}.\nCreate a new sauda to bill it.'
                            : 'No rows in this bill.\nAdd saudas or create a new one to continue.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : visible.isEmpty
                    ? Center(child: Text('No rows match "$_query"'))
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        itemCount: visible.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final line = visible[index];
                          return Dismissible(
                            key: ValueKey(line.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              decoration: BoxDecoration(
                                color: AppTheme.errorColor,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child:
                                  const Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (_) => vm.removeLine(line.id),
                            child: BillLineCard(
                              line: line,
                              side: side,
                              onDelete: () => vm.removeLine(line.id),
                              onEditRate: () => _editRate(
                                  line.id, line.brokerageRatePerQuintal),
                            ),
                          );
                        },
                      ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  BillTotalsFooter(totals: state.totals),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: state.canPrint ? _print : null,
                      icon: state.isPrinting
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.print),
                      label: const Text('Print Bill'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
