import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_sauda/features/sauda/model/sauda_defaults.dart';
import 'package:my_sauda/features/sauda/service/sauda_defaults_service.dart';
import 'package:my_sauda/features/sauda/widgets/sauda_share_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('SaudaDefaultsService', () {
    late String? user;
    late SaudaDefaultsService service;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      user = 'u1';
      service = SaudaDefaultsService(currentUserId: () => user);
    });

    test('starts empty', () async {
      final defaults = await service.fetchDefaults();
      expect(defaults.firmName, '');
      expect(defaults.terms, '');
    });

    test('remembers what was saved', () async {
      await service.saveDefaults(
        const SaudaDefaults(
            firmName: 'Siddhi Tradelink', terms: 'Pay in 7 days'),
      );
      final defaults = await service.fetchDefaults();
      expect(defaults.firmName, 'Siddhi Tradelink');
      expect(defaults.terms, 'Pay in 7 days');
    });

    test('saving empty values clears them', () async {
      await service.saveDefaults(
        const SaudaDefaults(firmName: 'Siddhi Tradelink', terms: 'T'),
      );
      await service.saveDefaults(const SaudaDefaults());
      final defaults = await service.fetchDefaults();
      expect(defaults.firmName, '');
      expect(defaults.terms, '');
    });

    test('each user has their own values', () async {
      await service.saveDefaults(const SaudaDefaults(firmName: 'A Firm'));
      user = 'u2';
      expect((await service.fetchDefaults()).firmName, '');
      await service.saveDefaults(const SaudaDefaults(firmName: 'B Firm'));
      user = 'u1';
      expect((await service.fetchDefaults()).firmName, 'A Firm');
    });

    test('nothing is saved or read when logged out', () async {
      user = null;
      await service.saveDefaults(const SaudaDefaults(firmName: 'X'));
      expect((await service.fetchDefaults()).firmName, '');
      user = 'u1';
      expect((await service.fetchDefaults()).firmName, '');
    });
  });

  testWidgets('share card puts the firm name first and terms last',
      (tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SaudaShareCard(
              title: 'Sauda Confirmation - #S-1',
              date: '19/09/2026',
              rows: [ShareRow(label: 'Item', value: 'Wheat')],
              firmName: 'Siddhi Tradelink',
              terms: 'Pay in 7 days',
            ),
          ),
        ),
      ),
    );

    final firm = tester.getTopLeft(find.text('Siddhi Tradelink')).dy;
    final title = tester.getTopLeft(find.text('Sauda Confirmation - #S-1')).dy;
    final item = tester.getTopLeft(find.text('Wheat')).dy;
    final terms = tester.getTopLeft(find.text('Pay in 7 days')).dy;
    expect(firm < title && title < item && item < terms, isTrue);
  });

  testWidgets('share card without the optional details shows neither',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SaudaShareCard(
            title: 'Sauda Confirmation',
            date: '19/09/2026',
            rows: [ShareRow(label: 'Item', value: 'Wheat')],
          ),
        ),
      ),
    );
    expect(find.text('Terms & Conditions'), findsNothing);
  });

  testWidgets('a row detail sits directly under its value', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SaudaShareCard(
            title: 'Sauda Confirmation',
            date: '19/09/2026',
            rows: [
              ShareRow(
                label: 'Buyer',
                value: 'AGT Foods India Pvt Ltd',
                detail: 'GSTIN: 27AAACA1234A1Z5',
              ),
              ShareRow(label: 'Seller', value: 'Movaliya Traders'),
            ],
          ),
        ),
      ),
    );

    final name = tester.getTopLeft(find.text('AGT Foods India Pvt Ltd'));
    final gstin = tester.getTopLeft(find.text('GSTIN: 27AAACA1234A1Z5'));
    final seller = tester.getTopLeft(find.text('Movaliya Traders'));
    expect(gstin.dx, name.dx);
    expect(gstin.dy > name.dy && gstin.dy < seller.dy, isTrue);
    expect(find.textContaining('GSTIN'), findsOneWidget);
  });
}
