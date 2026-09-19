import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart';
import 'package:my_sauda/core/theme/app_theme.dart';
import '../model/bill.dart';
import '../model/bill_format.dart';
import '../view_model/bills_view_model.dart';

class BillsScreen extends ConsumerStatefulWidget {
  const BillsScreen({super.key});

  @override
  ConsumerState<BillsScreen> createState() => _BillsScreenState();
}

class _BillsScreenState extends ConsumerState<BillsScreen> {
  BillSide? _sideFilter;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(billsViewModelProvider.notifier).loadBills();
    });
  }

  Future<void> _generate() async {
    await context.push('/generate-bill');
    if (!mounted) return;
    ref.read(billsViewModelProvider.notifier).loadBills();
  }

  Future<void> _share(Bill bill) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final pdf = await ref.read(billsRepositoryProvider).readPdf(bill);
      await Printing.sharePdf(bytes: pdf, filename: bill.pdfFileName);
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Could not open the PDF for this bill'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  Future<void> _confirmDelete(Bill bill) async {
    final vm = ref.read(billsViewModelProvider.notifier);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Bill'),
        content: Text('Are you sure you want to delete "${bill.billNumber}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final success = await vm.deleteBill(bill);

    if (!mounted) return;

    messenger.showSnackBar(
      SnackBar(
        content: Text(success ? 'Bill deleted' : 'Failed to delete bill'),
        backgroundColor: success ? AppTheme.primaryColor : AppTheme.errorColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(billsViewModelProvider);
    final bills = _sideFilter == null
        ? state.bills
        : state.bills.where((b) => b.side == _sideFilter).toList();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Bills'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _generate,
                icon: const Icon(Icons.add),
                label: const Text('Generate Bill'),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _filterChip('All', null),
                const SizedBox(width: 8),
                _filterChip('Buyer', BillSide.buyer),
                const SizedBox(width: 8),
                _filterChip('Seller', BillSide.seller),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: state.isLoading && state.bills.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : state.errorMessage != null && state.bills.isEmpty
                      ? Center(child: Text(state.errorMessage!))
                      : bills.isEmpty
                          ? const Center(child: Text('No bills generated yet'))
                          : ListView.separated(
                              itemCount: bills.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, index) =>
                                  _billCard(bills[index]),
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, BillSide? side) {
    return ChoiceChip(
      label: Text(label),
      selected: _sideFilter == side,
      selectedColor: AppTheme.primaryColor.withValues(alpha: 0.15),
      onSelected: (_) => setState(() => _sideFilter = side),
    );
  }

  Widget _billCard(Bill bill) {
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => context.push('/bill-view', extra: bill),
      child: Ink(
        padding: const EdgeInsets.fromLTRB(14, 12, 4, 12),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        bill.billNumber,
                        style: textTheme.bodyLarge!
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          bill.side.label,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${bill.partyName} (${bill.partyCode})',
                    style: textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${formatBillDate(bill.billDate)} · ${bill.lines.length} rows · ₹${formatBillAmount(bill.totals.totalBrokerage)}',
                    style: textTheme.bodyMedium!.copyWith(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (v) {
                if (v == 'view') context.push('/bill-view', extra: bill);
                if (v == 'share') _share(bill);
                if (v == 'delete') _confirmDelete(bill);
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'view', child: Text('View PDF')),
                PopupMenuItem(value: 'share', child: Text('Share')),
                PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
