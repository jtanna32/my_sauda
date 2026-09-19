import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_sauda/core/theme/app_theme.dart';
import 'package:my_sauda/features/sauda/model/item.dart';
import 'package:my_sauda/features/sauda/view_model/items_view_model.dart';

Future<Item?> showItemPicker({
  required BuildContext context,
  required WidgetRef ref,
}) {
  return showModalBottomSheet<Item>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppTheme.surfaceColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => const _ItemPickerContent(),
  );
}

class _ItemPickerContent extends ConsumerStatefulWidget {
  const _ItemPickerContent();

  @override
  ConsumerState<_ItemPickerContent> createState() => _ItemPickerContentState();
}

class _ItemPickerContentState extends ConsumerState<_ItemPickerContent> {
  final _searchController = TextEditingController();
  List<Item> _filtered = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(itemsViewModelProvider.notifier).loadItems();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query, List<Item> all) {
    final lower = query.toLowerCase();
    setState(() {
      _filtered = all
          .where((i) => i.name.toLowerCase().contains(lower))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(itemsViewModelProvider);
    final list = _searchController.text.isEmpty ? state.items : _filtered;
    final query = _searchController.text.trim();

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
            'Select Item',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search items...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) {
                _onSearch(v, state.items);
                setState(() {});
              },
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : list.isEmpty
                    ? const Center(child: Text('No items found'))
                    : ListView.builder(
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          final item = list[index];
                          return ListTile(
                            title: Text(item.name),
                            onTap: () => Navigator.pop(context, item),
                          );
                        },
                      ),
          ),
          if (query.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final vm = ref.read(itemsViewModelProvider.notifier);
                    final newItem = await vm.createItem(name: query);
                    if (context.mounted && newItem != null) {
                      Navigator.pop(context, newItem);
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: Text('Add "$query"'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
