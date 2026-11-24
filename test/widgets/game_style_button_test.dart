import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/widgets/game_style_button.dart';

void main() {
  testWidgets('ラベルが表示される', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GameStyleButton(
            label: '送信',
            backgroundColor: Colors.orange,
            textColor: Colors.black,
            onPressed: null,
          ),
        ),
      )
    );

    expect(find.text('送信'), findsOneWidget);
  });

  testWidgets('タップでonPressedが呼ばれる', (tester) async {
    bool onPressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GameStyleButton(
            label: 'タップ',
            backgroundColor: Colors.orange,
            textColor: Colors.black,
            onPressed: () {
              onPressed = true;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('タップ'));
    await tester.pump();
    expect(onPressed, isTrue);
  });

  testWidgets('isLoading中はCircularProgressIndicatorが表示され、ラベルは表示されない', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GameStyleButton(
            label: '送信',
            backgroundColor: Colors.orange,
            textColor: Colors.black,
            onPressed: () {},
            isLoading: true,
          ),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('送信'), findsNothing);
  });

  testWidgets('無効状態でもElevatedButtonの背景色は透明のまま（下のGameStyleBoxの色を隠さない）', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GameStyleButton(
            label: '送信',
            backgroundColor: Colors.orange,
            textColor: Colors.black,
            onPressed: null, // 無効状態
          ),
        ),
      ),
    );

    final elevatedButton = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    final disabledColor = elevatedButton.style?.backgroundColor?.resolve({WidgetState.disabled});

    expect(disabledColor, Colors.transparent);
  });
}
