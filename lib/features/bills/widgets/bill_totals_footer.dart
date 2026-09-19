import 'package:flutter/material.dart';
import 'package:my_sauda/core/theme/app_theme.dart';
import '../model/bill.dart';
import '../model/bill_format.dart';

class BillTotalsFooter extends StatelessWidget {
  final BillTotals totals;

  const BillTotalsFooter({super.key, required this.totals});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Total Quantity',
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                '${formatBillNumber(totals.totalTons)} Tons / ${formatBillNumber(totals.totalQuintals)} Qtl',
                textAlign: TextAlign.right,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Total Brokerage',
                style: Theme.of(context).textTheme.labelLarge),
            Text(
              '₹${formatBillAmount(totals.totalBrokerage)}',
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryColor,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}
