import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/widgets/statusbutton.dart';

void main() {
  testWidgets('選択状態で色とラベルが切り替わり、タップでコールバックが発火する', (tester) async {
    var tapCount = 0;

    Future<void> pumpStatusButton({required bool isSelected}) {
      return tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatusButton(
              type: StatusButtonType.awake,
              isSelected: isSelected,
              onTap: () => tapCount++,
            ),
          ),
        ),
      );
    }

    await pumpStatusButton(isSelected: false);

    expect(find.text('1: AWAKE'), findsOneWidget);
    var buttonContainer = tester.widget<Container>(
      find
          .descendant(
            of: find.byType(StatusButton),
            matching: find.byType(Container),
          )
          .first,
    );
    expect((buttonContainer.decoration! as BoxDecoration).color, Colors.white);
    expect(
      tester.widget<Text>(find.text('1: AWAKE')).style!.color,
      const Color(0xFF1A1C1C),
    );

    await tester.tap(find.byType(StatusButton));
    expect(tapCount, 1);

    await pumpStatusButton(isSelected: true);

    buttonContainer = tester.widget<Container>(
      find
          .descendant(
            of: find.byType(StatusButton),
            matching: find.byType(Container),
          )
          .first,
    );
    expect(
      (buttonContainer.decoration! as BoxDecoration).color,
      StatusButtonType.awake.color,
    );
    expect(find.text('1: AWAKE'), findsOneWidget);
    expect(
      tester.widget<Text>(find.text('1: AWAKE')).style!.color,
      Colors.black,
    );
  });
}
