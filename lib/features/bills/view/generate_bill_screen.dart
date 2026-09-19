import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_sauda/core/theme/app_theme.dart';
import 'package:my_sauda/features/sauda/widgets/party_picker_dialog.dart';
import 'package:my_sauda/features/sauda/widgets/sauda_filter_sheet.dart';
import '../model/bill.dart';
import '../view_model/bill_draft_view_model.dart';

class GenerateBillScreen extends ConsumerWidget {
  const GenerateBillScreen({super.key});

  Future<void> _pickParty(BuildContext context, WidgetRef ref) async {
    final party = await showPartyPicker(context: context, ref: ref);
    if (party != null) {
      ref.read(billDraftViewModelProvider.notifier).setParty(party);
    }
  }

  Future<void> _pickRange(BuildContext context, WidgetRef ref) async {
    final vm = ref.read(billDraftViewModelProvider.notifier);
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 1),
      initialDateRange: ref.read(billDraftViewModelProvider).dateRange,
    );
    if (picked != null) vm.setDateRange(picked);
  }

  Future<void> _generate(BuildContext context, WidgetRef ref) async {
    final vm = ref.read(billDraftViewModelProvider.notifier);
    final ok = await vm.generate();
    if (!context.mounted) return;

    if (ok) {
      context.push('/bill-preview');
      return;
    }
    final message = ref.read(billDraftViewModelProvider).errorMessage;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message ?? 'Failed to load saudas'),
        backgroundColor: AppTheme.errorColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(billDraftViewModelProvider);
    final vm = ref.read(billDraftViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Generate Bill'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label(context, 'Party'),
            _selectorTile(
              icon: Icons.business,
              text: state.party == null
                  ? 'Select party'
                  : '${state.party!.partyName} (${state.party!.partyCode})',
              isPlaceholder: state.party == null,
              onTap: () => _pickParty(context, ref),
            ),
            const SizedBox(height: 20),
            _label(context, 'Bill for the party as'),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<BillSide>(
                emptySelectionAllowed: true,
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(
                    value: BillSide.buyer,
                    label: Text('Buyer'),
                  ),
                  ButtonSegment(
                    value: BillSide.seller,
                    label: Text('Seller'),
                  ),
                ],
                selected: {if (state.side != null) state.side!},
                onSelectionChanged: (s) {
                  if (s.isNotEmpty) vm.setSide(s.first);
                },
              ),
            ),
            const SizedBox(height: 20),
            _label(context, 'Date range (optional)'),
            _selectorTile(
              icon: Icons.date_range,
              text: state.dateRange == null
                  ? 'All saudas to date'
                  : formatFilterRange(state.dateRange!),
              isPlaceholder: state.dateRange == null,
              onTap: () => _pickRange(context, ref),
              onClear:
                  state.dateRange == null ? null : () => vm.setDateRange(null),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    state.canGenerate ? () => _generate(context, ref) : null,
                child: state.isGenerating
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Generate'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppTheme.primaryColor,
            ),
      ),
    );
  }

  Widget _selectorTile({
    required IconData icon,
    required String text,
    required bool isPlaceholder,
    required VoidCallback onTap,
    VoidCallback? onClear,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primaryColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 15,
                  color: isPlaceholder ? Colors.grey : AppTheme.textColor,
                ),
              ),
            ),
            if (onClear != null)
              GestureDetector(
                onTap: onClear,
                child: const Icon(Icons.close, size: 20),
              )
            else
              const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
