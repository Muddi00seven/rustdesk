import 'package:flutter/material.dart';
import 'package:flutter_hbb/macpilot/remote_keyboard.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('iPad input opens and reopens keyboard with focus unchanged',
      (tester) async {
    final key = GlobalKey<EditableTextState>();
    final focus = FocusNode();
    final controller = TextEditingController();
    addTearDown(focus.dispose);
    addTearDown(controller.dispose);
    String? typed;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
          body: Stack(children: [
        MacPilotRemoteKeyboard(
            inputKey: key,
            focusNode: focus,
            controller: controller,
            onChanged: (value) => typed = value),
      ])),
    ));
    key.currentState!.requestKeyboard();
    await tester.pump();
    expect(tester.testTextInput.isVisible, isTrue);
    tester.testTextInput.hide();
    key.currentState!.requestKeyboard();
    await tester.pump();
    expect(tester.testTextInput.isVisible, isTrue);
    tester.testTextInput.enterText('Hello Mac');
    expect(typed, 'Hello Mac');
  });
}
