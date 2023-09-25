import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_utils.dart';

void main() {
  setUp(() async {
    final random = Random();
    String clipboardContent = '';

    for (var i = 0; i < 6; i++) {
      clipboardContent = clipboardContent + random.nextInt(9).toString();
    }

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      SystemChannels.platform,
      (methodCall) async {
        if (methodCall.method == 'Clipboard.getData') {
          return <String, dynamic>{'text': clipboardContent};
        }
        return null;
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      SystemChannels.platform,
      null,
    );
  });

  testWidgets('Check the number of fields and nodes', (tester) async {
    await tester.prepare();
    expect(finder, findsNWidgets(length));
    expect(tester.getFocusNodes().length, length);
  });

  testWidgets('First field is focused', (tester) async {
    await tester.prepare();
    expect(tester.getFocusNodes()[0], predicate<FocusNode>((n) => n.hasFocus));
  });

  testWidgets('Arrow keys are moving the cursor', (tester) async {
    await tester.prepare();
    final nodes = tester.getFocusNodes();

    final stepsRight = Random().nextInt(length - 1) + 1;
    await stepsRight.repeat(
        () async => await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight));
    expect(nodes[stepsRight].hasFocus, true);
    nodes.first.requestFocus();
    await length.repeat(
        () async => await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight));
    expect(nodes.last.hasFocus, true);
    nodes.last.requestFocus();
    final stepsLeft = Random().nextInt(length - 1) + 1;
    await stepsLeft.repeat(
        () async => await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft));
    expect(nodes[length - 1 - stepsLeft].hasFocus, true);
    nodes.last.requestFocus();
    await length.repeat(
        () async => await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft));
    expect(nodes.first.hasFocus, true);
  });

  testWidgets('Text is pasted', (tester) async {
    await tester.prepare();
    final nodes = tester.getFocusNodes();
    final textFields = tester.getTextFields();

    final text = await Clipboard.getData(Clipboard.kTextPlain);
    if (!nodes.first.hasFocus) {
      nodes.first.requestFocus();
    }

    final repeatTextPaste = RepeatTextPaste();

    if (text case final clipboard?) {
      if (clipboard.text case final pastedText?) {
        for (int i = 0; i < textFields.length; i++) {
          await repeatTextPaste.repeatWithParameters(
            tester: tester,
            text: pastedText,
            startingPoint: i,
            textFields: textFields,
            node: nodes[i],
          );
        }
        for (int i = 0; i < textFields.length; i++) {
          await repeatTextPaste.repeatWithParameters(
            isLogicalKeyboard: true,
            tester: tester,
            text: pastedText,
            startingPoint: i,
            textFields: textFields,
            node: nodes[i],
          );
        }
      }
    }
  });
}
