import 'package:flutter/material.dart';
import 'package:my_sauda/core/theme/app_theme.dart';
import '../model/bill.dart';
import '../model/bill_columns.dart';
import '../model/bill_format.dart';

const _highlighted = {'date', 'saudaNo', 'item', 'counterParty', 'amount'};

class BillLineCard extends StatelessWidget {
  final BillLine line;
  final BillSide side;
  final VoidCallback onDelete;
  final VoidCallback onEditRate;

  const BillLineCard({
    super.key,
    required this.line,
    required this.side,
    required this.onDelete,
    required this.onEditRate,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final details = billColumns.where((c) => !_highlighted.contains(c.key));

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: line.hasRateWarning
            ? Border.all(color: Colors.orange.shade300)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${line.saudaNumber} · ${formatBillDate(line.date)}',
                  style: textTheme.bodyLarge!
                      .copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.delete_outline,
                    color: AppTheme.errorColor),
                tooltip: 'Remove',
                onPressed: onDelete,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text(
              line.counterParty.isEmpty
                  ? line.itemName
                  : '${line.itemName} · ${side.counterPartyLabel}: ${line.counterParty}',
              style: textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Wrap(
              spacing: 14,
              runSpacing: 4,
              children: [
                for (final c in details)
                  Text(
                    '${c.header(side)}: ${c.value(line)}',
                    style: textTheme.bodyMedium!.copyWith(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Row(
              children: [
                if (line.hasRateWarning)
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber_rounded,
                            size: 16, color: Colors.orange.shade800),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            'No brokerage rate',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  const Spacer(),
                TextButton.icon(
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                  onPressed: onEditRate,
                  icon: const Icon(Icons.edit, size: 14),
                  label: const Text('Rate'),
                ),
                const SizedBox(width: 8),
                Text(
                  '₹${formatBillAmount(line.brokerageAmount)}',
                  style: textTheme.bodyLarge!.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
