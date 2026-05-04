import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view_model/suggestion_view_model.dart';
import '../theme/app_theme.dart';

Future<String?> showSuggestionPicker({
  required BuildContext context,
  required WidgetRef ref,
  required String type, // e.g. 'city', 'remark', 'state'
  String title = 'Select',
  List<String>? staticOptions, // 👈 pass for states
  bool allowAdd = true,        // 👈 false for states
}) {
  final controller = TextEditingController();

  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppTheme.surfaceColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) {
      return _Content(
        type: type,
        title: title,
        controller: controller,
        staticOptions: staticOptions,
        allowAdd: allowAdd,
      );
    },
  );
}

class _Content extends ConsumerStatefulWidget {
  final String type;
  final String title;
  final TextEditingController controller;
  final List<String>? staticOptions;
  final bool allowAdd;

  const _Content({
    required this.type,
    required this.title,
    required this.controller,
    this.staticOptions,
    this.allowAdd = true,
  });

  @override
  ConsumerState<_Content> createState() => _ContentState();
}

class _ContentState extends ConsumerState<_Content> {
  List<String> localFiltered = [];

  @override
  void initState() {
    super.initState();

    if (widget.staticOptions != null) {
      // Static mode (States)
      localFiltered = widget.staticOptions!;
    } else {
      // Dynamic mode (City/Remark)
      Future.microtask(() {
        ref
            .read(suggestionViewModelProvider(widget.type).notifier)
            .loadSuggestions();
      });
    }
  }

  void _searchLocal(String query) {
    final lower = query.toLowerCase();
    setState(() {
      localFiltered = widget.staticOptions!
          .where((e) => e.toLowerCase().contains(lower))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isStatic = widget.staticOptions != null;

    final vm =
    ref.read(suggestionViewModelProvider(widget.type).notifier);
    final state =
    ref.watch(suggestionViewModelProvider(widget.type));

    final list = isStatic ? localFiltered : state.filteredSuggestions;

    return SizedBox(
      height: 500,
      child: Column(
        children: [
          const SizedBox(height: 12),

          // drag handle
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

          // Search field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: widget.controller,
              decoration: const InputDecoration(
                hintText: 'Search...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                if (isStatic) {
                  _searchLocal(value);
                } else {
                  vm.search(value);
                }
                setState(() {}); // update Add button visibility
              },
            ),
          ),

          const SizedBox(height: 12),

          // List
          Expanded(
            child: (!isStatic && state.isLoading)
                ? const Center(child: CircularProgressIndicator())
                : list.isEmpty
                ? const Center(child: Text('No results'))
                : ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, index) {
                final item = list[index];

                return ListTile(
                  title: Text(item),
                  onTap: () {
                    Navigator.pop(context, item);
                  },
                );
              },
            ),
          ),

          // Add button (ONLY for dynamic)
          if (!isStatic &&
              widget.allowAdd &&
              widget.controller.text.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final value = widget.controller.text.trim();

                    await vm.addNew(value);

                    Navigator.pop(context, value);
                  },
                  icon: const Icon(Icons.add),
                  label: Text('Add "${widget.controller.text}"'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding:
                    const EdgeInsets.symmetric(vertical: 16),
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