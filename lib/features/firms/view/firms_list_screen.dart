import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_sauda/core/theme/app_theme.dart';
import '../view_model/firms_view_model.dart';

class FirmsListScreen extends ConsumerStatefulWidget {
  const FirmsListScreen({super.key});

  @override
  ConsumerState<FirmsListScreen> createState() => _FirmsListScreenState();
}

class _FirmsListScreenState extends ConsumerState<FirmsListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(firmsViewModelProvider.notifier).loadFirms();
    });
  }

  Future<void> _confirmDelete(String id, String name) async {
    if (!mounted) return;

    final vm = ref.read(firmsViewModelProvider.notifier);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Firm'),
        content: Text('Are you sure you want to delete "$name"?'),
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
    final success = await vm.deleteFirm(id);

    if (!mounted) return;

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Firm deleted successfully' : 'Failed to delete firm',
        ),
        backgroundColor:
            success ? AppTheme.primaryColor : AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(firmsViewModelProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Firms'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: state.isLoading ? null : () => context.push('/add-firm'),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Search firms...',
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
                    .read(firmsViewModelProvider.notifier)
                    .searchFirms(value);
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Builder(
                builder: (_) {
                  if (state.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state.errorMessage != null) {
                    return Center(child: Text(state.errorMessage!));
                  }

                  if (state.firms.isEmpty) {
                    return const Center(
                      child: Text(
                        'No firms yet\nTap + to add your first firm',
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () =>
                        ref.read(firmsViewModelProvider.notifier).loadFirms(),
                    child: ListView.builder(
                      itemCount: state.firms.length,
                      itemBuilder: (context, index) {
                        final firm = state.firms[index];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(16),
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
                            onTap: () {
                              context.push('/add-firm', extra: firm);
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        firm.firmName,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: AppTheme.errorColor),
                                      onPressed: () => _confirmDelete(
                                        firm.id,
                                        firm.firmName,
                                      ),
                                    ),
                                  ],
                                ),
                                if (firm.proprietorName != null &&
                                    firm.proprietorName!.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    firm.proprietorName!,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                                if (firm.phoneNumber != null &&
                                    firm.phoneNumber!.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryColor
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      firm.phoneNumber!,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.primaryColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
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
