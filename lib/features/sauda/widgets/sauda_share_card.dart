import 'package:flutter/material.dart';
import 'package:my_sauda/core/theme/app_theme.dart';

class ShareRow {
  final String label;
  final String value;
  // Smaller second line under the value, e.g. a party's GSTIN.
  final String? detail;

  const ShareRow({required this.label, required this.value, this.detail});
}

class SaudaShareCard extends StatelessWidget {
  final String title;
  final String date;
  final List<ShareRow> rows;
  final String? firmName;
  final String? terms;

  const SaudaShareCard({
    super.key,
    required this.title,
    required this.date,
    required this.rows,
    this.firmName,
    this.terms,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 380,
      child: SafeArea(
        child: Material(
          color: AppTheme.surfaceColor,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                color: AppTheme.primaryColor,
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "ॐ श्री गणेशाय नमः",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(height: 1, color: Colors.white24),
                    const SizedBox(height: 10),
                    if (firmName != null && firmName!.isNotEmpty) ...[
                      Text(
                        firmName!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(height: 1, color: Colors.white24),
                      const SizedBox(height: 10),
                    ],
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize:
                            firmName != null && firmName!.isNotEmpty ? 16 : 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      date,
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Column(
                  children: [
                    for (final row in rows)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.grey.shade200),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 118,
                              child: Text(
                                row.label,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    row.value,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textColor,
                                    ),
                                  ),
                                  if (row.detail != null &&
                                      row.detail!.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Text(
                                        row.detail!,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              if (terms != null && terms!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Terms & Conditions',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        terms!,
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.35,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
