import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_sauda/core/utils/widget_image.dart';
import 'package:my_sauda/features/sauda/widgets/sauda_share_card.dart';

void main() {
  testWidgets('renders the share card to a PNG and cleans up the overlay',
      (tester) async {
    late BuildContext context;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(builder: (c) {
          context = c;
          return const Scaffold(body: Text('app'));
        }),
      ),
    );

    final future = renderWidgetToPng(
      context,
      const SaudaShareCard(
        title: 'Sauda Confirmation - #S-1',
        date: '19/09/2026',
        rows: [ShareRow(label: 'Item', value: 'Wheat')],
      ),
    );
    await tester.pump();
    final bytes = await tester.runAsync(() => future);

    expect(bytes!.sublist(1, 4), [80, 78, 71]);
    await tester.pump();
    expect(find.byType(SaudaShareCard), findsNothing);
  });
}
