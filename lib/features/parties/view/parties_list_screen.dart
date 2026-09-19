import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_sauda/core/theme/app_theme.dart';
import '../view_model/parties_view_model.dart';

class PartiesListScreen extends ConsumerStatefulWidget {
  const PartiesListScreen({super.key});

  @override
  ConsumerState<PartiesListScreen> createState() =>
      _PartiesListScreenState();
}

class _PartiesListScreenState
    extends ConsumerState<PartiesListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(partiesViewModelProvider.notifier).loadParties();
    });
  }

  Future<void> _confirmDelete(
      BuildContext context, String id, String name) async {
    final vm = ref.read(partiesViewModelProvider.notifier);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Party'),
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

    /// ✅ Capture messenger BEFORE async call
    final messenger = ScaffoldMessenger.of(context);

    final success = await vm.deleteParty(id);

    if (!mounted) return;

    final failure = ref.read(partiesViewModelProvider).errorMessage ??
        'Failed to delete party';
    if (!success) vm.clearMessages();

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Party deleted successfully' : failure,
        ),
        backgroundColor:
        success ? AppTheme.primaryColor : AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(partiesViewModelProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Parties'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: state.isLoading ? null : () => context.push('/add-party'),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Search parties...',
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
                    .read(partiesViewModelProvider.notifier)
                    .searchParties(value);
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

                  if (state.parties.isEmpty) {
                    return const Center(child: Text('No parties yet\n'
                        'Tap + to add your first party', textAlign: TextAlign.center,));
                  }

                  return RefreshIndicator(
                    onRefresh: () => ref.read(partiesViewModelProvider.notifier).loadParties(),
                    child: ListView.builder(
                      itemCount: state.parties.length,
                      itemBuilder: (context, index) {
                        final party = state.parties[index];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceColor,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              context.push(
                                '/add-party',
                                extra: party,
                              );
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
                                        party.partyName,
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
                                        context,
                                        party.id,
                                        party.partyName,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${party.city}, ${party.state}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                if (party.phoneNumber != null &&
                                    party.phoneNumber!.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    party.phoneNumber!,
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color:
                                    AppTheme.primaryColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Code: ${party.partyCode}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                ),
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