import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_sauda/core/theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
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

            const SizedBox(height: 28),

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
                    onTap: () => context.push('/parties'),
                  ),
                  _HomeCard(
                    icon: Icons.receipt_long,
                    title: 'Sauda',
                    subtitle: 'Create contracts',
                    onTap: () {},
                  ),
                  _HomeCard(
                    icon: Icons.account_balance,
                    title: 'Firms',
                    subtitle: 'Manage firms',
                    onTap: () {},
                  ),
                  _HomeCard(
                    icon: Icons.description,
                    title: 'Bills',
                    subtitle: 'Generate bills',
                    onTap: () {},
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

/// 🔹 Reusable Home Card
class _HomeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _HomeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
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
                color: AppTheme.primaryColor.withOpacity(0.1),
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