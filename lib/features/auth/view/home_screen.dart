import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_sauda/core/theme/app_theme.dart';
import 'package:my_sauda/features/firms/view_model/firms_view_model.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(firmsViewModelProvider.notifier).loadFirms();
    });
  }

  void _showLocked() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Add your firm first to use this feature'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final firms = ref.watch(firmsViewModelProvider);
    // Stay locked while (re)loading so a previous user's cached firms never unlock a new login.
    final unlocked = !firms.isLoading && firms.allFirms.isNotEmpty;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('My Sauda'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 👋 Greeting
            Text(
              'Welcome 👋',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 6),
            Text(
              'Manage your brokerage work efficiently',
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            const SizedBox(height: 20),

            if (!unlocked && !firms.isLoading) ...[
              _SetupBanner(
                failed: firms.errorMessage != null,
                onAction: () => firms.errorMessage != null
                    ? ref.read(firmsViewModelProvider.notifier).loadFirms()
                    : context.push('/add-firm'),
              ),
              const SizedBox(height: 20),
            ],

            /// 🔥 Quick Actions Title
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.labelLarge,
            ),

            const SizedBox(height: 16),

            /// 🟢 Cards
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _HomeCard(
                    icon: Icons.business,
                    title: 'Parties',
                    subtitle: 'Manage clients',
                    enabled: unlocked,
                    onTap: () =>
                        unlocked ? context.push('/parties') : _showLocked(),
                  ),
                  _HomeCard(
                    icon: Icons.receipt_long,
                    title: 'Sauda',
                    subtitle: 'Create contracts',
                    enabled: unlocked,
                    onTap: () =>
                        unlocked ? context.push('/saudas') : _showLocked(),
                  ),
                  _HomeCard(
                    icon: Icons.account_balance,
                    title: 'Firms',
                    subtitle: 'Manage firms',
                    onTap: () => context.push('/firms'),
                  ),
                  _HomeCard(
                    icon: Icons.description,
                    title: 'Bills',
                    subtitle: 'Generate bills',
                    enabled: unlocked,
                    onTap: () =>
                        unlocked ? context.push('/bills') : _showLocked(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SetupBanner extends StatelessWidget {
  final bool failed;
  final VoidCallback onAction;

  const _SetupBanner({required this.failed, required this.onAction});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              failed
                  ? 'Could not check your firms. Check your connection and retry.'
                  : 'Add your firm to unlock Parties, Sauda and Bills.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: onAction,
            child: Text(failed ? 'Retry' : 'Add Firm'),
          ),
        ],
      ),
    );
  }
}

/// 🔹 Reusable Home Card
class _HomeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool enabled;

  const _HomeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: _buildCard(context),
    );
  }

  Widget _buildCard(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppTheme.primaryColor),
            ),

            const Spacer(),

            /// Title
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge!
                  .copyWith(fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 4),

            /// Subtitle
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
