import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/widgets/game_style_button.dart';

void main() {
  // ① ここを埋める
  // ヒント: https://docs.flutter.dev/cookbook/testing/widget/introduction
  //   テストの名前と、`async` な `(tester) => {}` のコールバックを渡す関数は何か？
  //   （test() ではなく、ウィジェットテスト専用の関数を使う）
  /* testWidgets を呼ぶ行をここに書く */ 
  testWidgets('ラベルが表示される', (tester) async {
    await tester.pumpWidget(
      // ② ここを埋める
      // ヒント: https://api.flutter.dev/flutter/flutter_test/WidgetTester/pumpWidget.html
      //   GameStyleButton は内部で ElevatedButton を使っているため、
      //   MaterialApp(home: Scaffold(body: ...)) で包んでから渡す必要がある。
      /* GameStyleButton を包んだ MaterialApp をここに書く */
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

    // ③ ここを埋める
    // ヒント: https://docs.flutter.dev/cookbook/testing/widget/finders
    //   「'送信' というテキストがちょうど1つ見つかる」ことを確認する。
    //   find.text(...) と findsOneWidget を使う。
    expect(find.text('送信'), findsOneWidget);
  });

  testWidgets('タップでonPressedが呼ばれる', (tester) async {
    // ④ ここを埋める
    // ヒント: タップされたかどうかを記録するための bool 変数を用意する（最初は false）。
    bool onPressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GameStyleButton(
            label: 'タップ',
            backgroundColor: Colors.orange,
            textColor: Colors.black,
            onPressed: () {
              // ⑤ ここを埋める
              // ヒント: ④で用意した変数を true にする。
              onPressed = true;
            },
          ),
        ),
      ),
    );

    // ⑥ ここを埋める
    // ヒント: https://docs.flutter.dev/cookbook/testing/widget/tap-drag
    //   tester.tap(find.text('タップ')) を呼んだあと、
    //   再描画を反映させるために await tester.pump() を呼ぶ必要がある（2行になる）。
    /* tester.tap(...) の行をここに書く */
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
            // ⑦ ここを埋める
            // ヒント: lib/widgets/game_style_button.dart のコンストラクタ引数を見て、
            //   ローディング中であることを表すプロパティ名を確認し、true を渡す。
          ),
        ),
      ),
    );

    // ⑧ ここを埋める
    // ヒント: https://docs.flutter.dev/cookbook/testing/widget/finders
    //   find.byType(CircularProgressIndicator) がちょうど1つ見つかることを確認する。
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // ⑨ ここを埋める
    // ヒント: 「'送信' という文字列が1つも見つからない」ことを確認するには
    //   findsOneWidget の代わりに何を使えばよいか？
    expect(find.text('送信'), findsNothing);
  });
}
