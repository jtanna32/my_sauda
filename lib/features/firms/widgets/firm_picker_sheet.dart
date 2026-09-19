import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_sauda/core/theme/app_theme.dart';
import 'package:my_sauda/features/firms/model/firm.dart';
import 'package:my_sauda/features/firms/view_model/firms_view_model.dart';

Future<Firm?> showFirmPicker({
  required BuildContext context,
  String title = 'Select Firm',
}) {
  return showModalBottomSheet<Firm>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppTheme.surfaceColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _FirmPickerContent(title: title),
  );
}

class _FirmPickerContent extends ConsumerStatefulWidget {
  final String title;

  const _FirmPickerContent({required this.title});

  @override
  ConsumerState<_FirmPickerContent> createState() => _FirmPickerContentState();
}

class _FirmPickerContentState extends ConsumerState<_FirmPickerContent> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(firmsViewModelProvider.notifier).loadFirms();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(firmsViewModelProvider);
    final firms = state.allFirms;

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.5,
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
          const SizedBox(height: 4),
          Text(
            'The bill is printed under this firm',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Expanded(
            child: state.isLoading && firms.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : firms.isEmpty
                    ? const Center(child: Text('No firms found'))
                    : ListView.builder(
                        itemCount: firms.length,
                        itemBuilder: (context, index) {
                          final firm = firms[index];
                          final details = [
                            firm.proprietorName,
                            firm.phoneNumber,
                          ].where((v) => v != null && v.trim().isNotEmpty);
                          return ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              child: Icon(Icons.account_balance),
                            ),
                            title: Text(firm.firmName),
                            subtitle: details.isEmpty
                                ? null
                                : Text(details.join(' · ')),
                            onTap: () => Navigator.pop(context, firm),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
