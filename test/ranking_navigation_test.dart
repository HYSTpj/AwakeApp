import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/common_layout.dart';

void main() {
  testWidgets('tapping ranking bottom nav pushes ranking page', (WidgetTester tester) async {
    // テスト用の差し替えページを設定
    CommonLayout.pageBuilderOverride = (int index, {String? groupId, int? myRole}) {
      if (index == 2) {
        return const Scaffold(body: Center(child: Text('RankingTestPage', key: Key('ranking-page'))));
      }
      return const SizedBox.shrink();
    };

    // CommonLayout をルートにして描画（groupId と myRole を与える）
    await tester.pumpWidget(MaterialApp(
      home: CommonLayout(
        body: const SizedBox.shrink(),
        groupId: 'test-group',
        myRole: 1,
      ),
    ));

    await tester.pumpAndSettle();

    // QRコードアイコン（3つ目）をタップ
    final qrIcon = find.byIcon(Icons.qr_code);
    expect(qrIcon, findsOneWidget);

    await tester.tap(qrIcon);
    await tester.pumpAndSettle();

    // 差し替えたランキングページが表示されていること
    expect(find.byKey(const Key('ranking-page')), findsOneWidget);

    // 後片付け
    CommonLayout.pageBuilderOverride = null;
  });
}
