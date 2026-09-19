import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_sauda/core/theme/app_theme.dart';
import 'package:my_sauda/features/parties/model/party.dart';
import 'package:my_sauda/features/sauda/view_model/saudas_view_model.dart';
import 'package:my_sauda/features/sauda/widgets/party_picker_dialog.dart';

String formatFilterDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

String formatFilterRange(DateTimeRange r) =>
    '${formatFilterDate(r.start)} - ${formatFilterDate(r.end)}';

Future<void> showSaudaFilterSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppTheme.surfaceColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => const _SaudaFilterContent(),
  );
}

enum _PartyRole { any, buyer, seller }

class _SaudaFilterContent extends ConsumerStatefulWidget {
  const _SaudaFilterContent();

  @override
  ConsumerState<_SaudaFilterContent> createState() =>
      _SaudaFilterContentState();
}

class _SaudaFilterContentState extends ConsumerState<_SaudaFilterContent> {
  DateTimeRange? _dateRange;
  Party? _party;
  Party? _buyer;
  Party? _seller;

  @override
  void initState() {
    super.initState();
    final s = ref.read(saudasViewModelProvider);
    _dateRange = s.dateRangeFilter;
    _party = s.partyFilter;
    _buyer = s.buyerFilter;
    _seller = s.sellerFilter;
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 1, 12, 31),
      initialDateRange: _dateRange,
    );
    if (picked != null) setState(() => _dateRange = picked);
  }

  Future<void> _pickParty(_PartyRole role) async {
    final party = await showPartyPicker(
      context: context,
      ref: ref,
      title: switch (role) {
        _PartyRole.any => 'Filter by Party',
        _PartyRole.buyer => 'Filter by Buyer',
        _PartyRole.seller => 'Filter by Seller',
      },
    );
    if (party == null) return;
    setState(() {
      switch (role) {
        case _PartyRole.any:
          _party = party;
        case _PartyRole.buyer:
          _buyer = party;
        case _PartyRole.seller:
          _seller = party;
      }
    });
  }

  Widget _filterField({
    required String label,
    required IconData icon,
    required String? value,
    required VoidCallback onTap,
    required VoidCallback onClear,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          suffixIcon: value == null
              ? const Icon(Icons.arrow_drop_down)
              : IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onClear,
                ),
        ),
        child: Text(
          value ?? 'Any',
          style: TextStyle(
            color: value == null ? Colors.grey : AppTheme.textColor,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Filter Saudas',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            _filterField(
              label: 'Date',
              icon: Icons.calendar_today,
              value: _dateRange == null ? null : formatFilterRange(_dateRange!),
              onTap: _pickDateRange,
              onClear: () => setState(() => _dateRange = null),
            ),
            const SizedBox(height: 14),
            _filterField(
              label: 'Party (as Buyer or Seller)',
              icon: Icons.groups,
              value: _party?.partyName,
              onTap: () => _pickParty(_PartyRole.any),
              onClear: () => setState(() => _party = null),
            ),
            const SizedBox(height: 14),
            _filterField(
              label: 'Buyer Party',
              icon: Icons.person,
              value: _buyer?.partyName,
              onTap: () => _pickParty(_PartyRole.buyer),
              onClear: () => setState(() => _buyer = null),
            ),
            const SizedBox(height: 14),
            _filterField(
              label: 'Seller Party',
              icon: Icons.storefront,
              value: _seller?.partyName,
              onTap: () => _pickParty(_PartyRole.seller),
              onClear: () => setState(() => _seller = null),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      ref.read(saudasViewModelProvider.notifier).clearFilters();
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Clear All'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ref.read(saudasViewModelProvider.notifier).applyFilters(
                            dateRange: _dateRange,
                            party: _party,
                            buyer: _buyer,
                            seller: _seller,
                          );
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Apply'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
