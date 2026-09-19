import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_sauda/core/theme/app_theme.dart';
import 'package:my_sauda/features/parties/model/party.dart';
import 'package:my_sauda/features/parties/view_model/parties_view_model.dart';

Future<Party?> showPartyPicker({
  required BuildContext context,
  required WidgetRef ref,
  String title = 'Select Party',
  bool allowAdd = false,
}) {
  return showModalBottomSheet<Party>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppTheme.surfaceColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _PartyPickerContent(title: title, allowAdd: allowAdd),
  );
}

class _PartyPickerContent extends ConsumerStatefulWidget {
  final String title;
  final bool allowAdd;

  const _PartyPickerContent({required this.title, required this.allowAdd});

  @override
  ConsumerState<_PartyPickerContent> createState() =>
      _PartyPickerContentState();
}

class _PartyPickerContentState extends ConsumerState<_PartyPickerContent> {
  final _searchController = TextEditingController();
  List<Party> _filtered = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(partiesViewModelProvider.notifier).loadParties();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _addParty() async {
    final created = await context.push<Party>(
      '/add-party',
      extra: _searchController.text.trim(),
    );
    if (created != null && mounted) Navigator.pop(context, created);
  }

  void _onSearch(String query, List<Party> all) {
    final lower = query.toLowerCase();
    setState(() {
      _filtered = all.where((p) {
        return p.partyName.toLowerCase().contains(lower) ||
            p.partyCode.toLowerCase().contains(lower) ||
            p.city.toLowerCase().contains(lower);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(partiesViewModelProvider);
    final list = _searchController.text.isEmpty ? state.allParties : _filtered;

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.75,
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            height: 4,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.title,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search by name or code...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) => _onSearch(v, state.allParties),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : list.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('No parties found'),
                            if (widget.allowAdd) ...[
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 14,
                                  ),
                                ),
                                onPressed: _addParty,
                                icon: const Icon(Icons.add),
                                label: const Text('Add Party'),
                              ),
                            ],
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          final party = list[index];
                          return ListTile(
                            title: Text(party.partyName),
                            subtitle: Text(
                              '${party.partyCode} · ${party.city}, ${party.state}',
                            ),
                            trailing: party.brokerageRate != null
                                ? Text(
                                    '₹${party.brokerageRate!.toStringAsFixed(2)}/qtl',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.primaryColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  )
                                : null,
                            onTap: () => Navigator.pop(context, party),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
