import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_sauda/core/theme/app_theme.dart';
import 'package:my_sauda/features/bills/model/bill_format.dart';
import '../model/sauda.dart';
import '../view_model/saudas_view_model.dart';
import '../widgets/sauda_filter_sheet.dart';

class SaudasListScreen extends ConsumerStatefulWidget {
  const SaudasListScreen({super.key});

  @override
  ConsumerState<SaudasListScreen> createState() => _SaudasListScreenState();
}

class _SaudasListScreenState extends ConsumerState<SaudasListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final vm = ref.read(saudasViewModelProvider.notifier);
      vm.applyCurrentMonthFilter();
      vm.loadSaudas();
    });
  }

  Future<void> _confirmDelete(String id, String saudaNumber) async {
    if (!mounted) return;

    final vm = ref.read(saudasViewModelProvider.notifier);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Sauda'),
        content: Text('Are you sure you want to delete sauda "$saudaNumber"?'),
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
    final success = await vm.deleteSauda(id);

    if (!mounted) return;

    final failure = ref.read(saudasViewModelProvider).errorMessage ??
        'Failed to delete sauda';
    if (!success) vm.clearMessages();

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Sauda deleted successfully' : failure,
        ),
        backgroundColor: success ? AppTheme.primaryColor : AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _removeFilter({
    bool clearDate = false,
    bool clearParty = false,
    bool clearBuyer = false,
    bool clearSeller = false,
  }) {
    final s = ref.read(saudasViewModelProvider);
    ref.read(saudasViewModelProvider.notifier).applyFilters(
          dateRange: clearDate ? null : s.dateRangeFilter,
          party: clearParty ? null : s.partyFilter,
          buyer: clearBuyer ? null : s.buyerFilter,
          seller: clearSeller ? null : s.sellerFilter,
        );
  }

  Widget _filterChip(String label, VoidCallback onDeleted) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InputChip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        onDeleted: onDeleted,
        backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
        side: BorderSide.none,
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(saudasViewModelProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Sauda'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: state.isLoading ? null : () => context.push('/add-sauda'),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search sauda...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: AppTheme.surfaceColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      ref
                          .read(saudasViewModelProvider.notifier)
                          .searchSaudas(value);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Badge(
                  isLabelVisible: state.hasActiveFilters,
                  label: Text('${state.activeFilterCount}'),
                  backgroundColor: AppTheme.accentColor,
                  child: Material(
                    color: state.hasActiveFilters
                        ? AppTheme.primaryColor
                        : AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => showSaudaFilterSheet(context),
                      child: SizedBox(
                        height: 56,
                        width: 56,
                        child: Icon(
                          Icons.filter_list,
                          color: state.hasActiveFilters
                              ? Colors.white
                              : AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (state.hasActiveFilters) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      if (state.dateRangeFilter != null)
                        _filterChip(
                          formatFilterRange(state.dateRangeFilter!),
                          () => _removeFilter(clearDate: true),
                        ),
                      if (state.partyFilter != null)
                        _filterChip(
                          'Party: ${state.partyFilter!.partyName}',
                          () => _removeFilter(clearParty: true),
                        ),
                      if (state.buyerFilter != null)
                        _filterChip(
                          'Buyer: ${state.buyerFilter!.partyName}',
                          () => _removeFilter(clearBuyer: true),
                        ),
                      if (state.sellerFilter != null)
                        _filterChip(
                          'Seller: ${state.sellerFilter!.partyName}',
                          () => _removeFilter(clearSeller: true),
                        ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            if (!state.isLoading && state.errorMessage == null) ...[
              _SummaryCard(
                saudaCount: state.saudas.length,
                totalTons: state.totalTons,
                totalBrokerage: state.totalBrokerage,
              ),
              const SizedBox(height: 12),
            ],
            Expanded(
              child: Builder(
                builder: (_) {
                  if (state.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state.errorMessage != null) {
                    return Center(child: Text(state.errorMessage!));
                  }

                  if (state.saudas.isEmpty) {
                    return Center(
                      child: Text(
                        state.hasActiveFilters || state.searchQuery.isNotEmpty
                            ? 'No saudas match your filters'
                            : 'No saudas yet\nTap + to create your first sauda',
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () =>
                        ref.read(saudasViewModelProvider.notifier).loadSaudas(),
                    child: ListView.builder(
                      itemCount: state.saudas.length,
                      itemBuilder: (context, index) {
                        final sauda = state.saudas[index];
                        return _SaudaCard(
                          sauda: sauda,
                          formatDate: _formatDate,
                          onTap: () => context.push('/add-sauda', extra: sauda),
                          onDelete: () =>
                              _confirmDelete(sauda.id, sauda.saudaNumber),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final int saudaCount;
  final double totalTons;
  final double totalBrokerage;

  const _SummaryCard({
    required this.saudaCount,
    required this.totalTons,
    required this.totalBrokerage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _stat(context, 'Saudas', '$saudaCount'),
          _stat(context, 'Total Tons', totalTons.toStringAsFixed(3)),
          _stat(
            context,
            'Total Brokerage',
            '₹${formatBillAmount(totalBrokerage)}',
            flex: 2,
          ),
        ],
      ),
    );
  }

  Widget _stat(BuildContext context, String label, String value,
      {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryColor,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SaudaCard extends StatelessWidget {
  final Sauda sauda;
  final String Function(DateTime) formatDate;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _SaudaCard({
    required this.sauda,
    required this.formatDate,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          sauda.saudaNumber,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        formatDate(sauda.saudaDate),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: AppTheme.errorColor),
                    onPressed: onDelete,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (sauda.itemName != null)
                Text(
                  sauda.itemName!,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .copyWith(fontWeight: FontWeight.w600),
                ),
              const SizedBox(height: 6),
              Text(
                '${sauda.quantity} ${sauda.unitName ?? ''} @ ${sauda.rateDisplay}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _PartyChip(
                      label: 'Buyer',
                      name: sauda.buyerPartyName ?? sauda.buyerPartyId,
                      code: sauda.buyerPartyCode,
                      brokerage: sauda.buyerSideBrokerage,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _PartyChip(
                      label: 'Seller',
                      name: sauda.sellerPartyName ?? sauda.sellerPartyId,
                      code: sauda.sellerPartyCode,
                      brokerage: sauda.sellerSideBrokerage,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PartyChip extends StatelessWidget {
  final String label;
  final String name;
  final String? code;
  final double brokerage;

  const _PartyChip({
    required this.label,
    required this.name,
    this.code,
    required this.brokerage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
          const SizedBox(height: 2),
          Text(
            name,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
          if (code != null)
            Text(
              code!,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          Text(
            '₹${brokerage.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
