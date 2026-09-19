import 'package:flutter/material.dart';
import 'package:my_sauda/core/theme/app_theme.dart';
import 'package:my_sauda/features/sauda/model/sauda.dart';
import '../model/bill.dart';
import '../model/bill_format.dart';

Future<List<Sauda>?> showAddSaudasSheet({
  required BuildContext context,
  required List<Sauda> saudas,
  required BillSide side,
}) {
  return showModalBottomSheet<List<Sauda>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppTheme.surfaceColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _AddSaudasContent(saudas: saudas, side: side),
  );
}

class _AddSaudasContent extends StatefulWidget {
  final List<Sauda> saudas;
  final BillSide side;

  const _AddSaudasContent({required this.saudas, required this.side});

  @override
  State<_AddSaudasContent> createState() => _AddSaudasContentState();
}

class _AddSaudasContentState extends State<_AddSaudasContent> {
  final Set<String> _selected = {};

  @override
  Widget build(BuildContext context) {
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
            'Add Saudas',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 12),
          Expanded(
            child: widget.saudas.isEmpty
                ? const Center(child: Text('No more saudas for this party'))
                : ListView.builder(
                    itemCount: widget.saudas.length,
                    itemBuilder: (context, index) {
                      final sauda = widget.saudas[index];
                      final line = BillLine.fromSauda(sauda, widget.side);
                      return CheckboxListTile(
                        value: _selected.contains(sauda.id),
                        activeColor: AppTheme.primaryColor,
                        onChanged: (v) => setState(() {
                          if (v == true) {
                            _selected.add(sauda.id);
                          } else {
                            _selected.remove(sauda.id);
                          }
                        }),
                        title: Text(
                          '${sauda.saudaNumber} · ${formatBillDate(sauda.saudaDate)}',
                        ),
                        subtitle: Text(
                          '${line.itemName} · ${formatBillNumber(line.quantityQuintals)} Qtl · ${line.counterParty}',
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selected.isEmpty
                    ? null
                    : () => Navigator.pop(
                          context,
                          widget.saudas
                              .where((s) => _selected.contains(s.id))
                              .toList(),
                        ),
                child: Text('Add ${_selected.length} Selected'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
