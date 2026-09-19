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
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final vm = ref.read(billsViewModelProvider.notifier);
      vm.searchBills('');
      vm.loadBills();
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
      final pdf =
          await ref.read(billsViewModelProvider.notifier).buildPdf(bill);
      await Printing.sharePdf(bytes: pdf, filename: bill.sharePdfFileName);
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

    final failure = ref.read(billsViewModelProvider).errorMessage ??
        'Failed to delete bill';

    messenger.showSnackBar(
      SnackBar(
        content: Text(success ? 'Bill deleted' : failure),
        backgroundColor: success ? AppTheme.primaryColor : AppTheme.errorColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(billsViewModelProvider);
    final bills = state.bills;

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
            TextField(
              decoration: InputDecoration(
                hintText: 'Search by bill number or party...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: AppTheme.surfaceColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) =>
                  ref.read(billsViewModelProvider.notifier).searchBills(value),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: state.isLoading && state.allBills.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : state.errorMessage != null && state.allBills.isEmpty
                      ? Center(child: Text(state.errorMessage!))
                      : bills.isEmpty
                          ? Center(
                              child: Text(
                                state.searchQuery.trim().isNotEmpty
                                    ? 'No bills match your search'
                                    : 'No bills generated yet',
                              ),
                            )
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
                  Text(
                    bill.billNumber,
                    style: textTheme.bodyLarge!
                        .copyWith(fontWeight: FontWeight.w600),
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
