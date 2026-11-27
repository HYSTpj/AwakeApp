import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/presentation/views/common/app_mode.dart';
import 'package:flutter_application_1/presentation/views/common/common_footer.dart';

void main() {
  Widget buildTestableWidget(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  testWidgets('管理者モードでは一覧アイコンのフッターが表示される', (tester) async {
    await tester.pumpWidget(
      buildTestableWidget(const CommonFooter(mode: AppMode.admin)),
    );

    final svgFinder = find.byWidgetPredicate(
      (widget) =>
          widget is SvgPicture &&
          widget.bytesLoader.toString().contains('icon_forum_admin.svg'),
    );
    expect(svgFinder, findsOneWidget);
  });

  testWidgets('メンバーモードでは時計アイコンのフッターが表示される', (tester) async {
    await tester.pumpWidget(
      buildTestableWidget(const CommonFooter(mode: AppMode.member)),
    );

    final svgFinder = find.byWidgetPredicate(
      (widget) =>
          widget is SvgPicture &&
          widget.bytesLoader.toString().contains('icon_forum_member.svg'),
    );
    expect(svgFinder, findsOneWidget);
  });

  testWidgets('追加(+)ボタンをタップするとコールバックが呼ばれる', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      buildTestableWidget(
        CommonFooter(mode: AppMode.admin, onPlusTap: () => tapped = true),
      ),
    );

    await tester.tap(find.byKey(CommonFooter.plusButtonKey));
    expect(tapped, isTrue);
  });
}
