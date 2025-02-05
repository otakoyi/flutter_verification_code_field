import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_utils.dart';

void main() {
  testWidgets('Check the number of fields and nodes', (tester) async {
    await tester.prepare();
    expect(finder, findsNWidgets(length));
    expect(tester.getFocusNodes().length, length);
  });

  testWidgets('First field is focused if autofocus is true', (tester) async {
    await tester.prepare(autofocus: true);
    expect(tester.getFocusNodes()[0], predicate<FocusNode>((n) => n.hasFocus));
  });

  testWidgets('No field is not focused if autofocus is false', (tester) async {
    await tester.prepare(autofocus: false);
    expect(tester.getFocusNodes(),
        predicate<List<FocusNode>>((n) => n.any((e) => !e.hasFocus)));
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

  group('description', () {
    setupPaste();

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
    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      );
    });
  });
  group('Group with different regexp', () {
    setupPaste(isRegExpChanged: true);

    testWidgets('New RegExp', (tester) async {
      await tester.prepare(regex: RegExp(r'[a-zA-Z0-9]'));

      List<FocusNode> nodes = tester.getFocusNodes();
      List<TextField> textFields = tester.getTextFields();

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
        }
      }
    });

    testWidgets('Default RegExp', (tester) async {
      await tester.prepare();

      final nodes = tester.getFocusNodes();
      final textFields = tester.getTextFields();

      if (!nodes.first.hasFocus) {
        nodes.first.requestFocus();
      }
      for (int i = 0; i < textFields.length; i++) {
        if (!nodes[i].hasFocus) {
          nodes[i].requestFocus();
          await tester.pump(const Duration(milliseconds: 100));
        }

        await tester.longPress(find.byWidget(textFields[0]));
        await tester.pump(const Duration(milliseconds: 100));
        await tester.tap(find.text('Paste'));
        await tester.pump(const Duration(milliseconds: 100));

        for (int i = 0; i < textFields.length; i++) {
          expect(textFields[i].controller!.text, '');
        }
      }
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      );
    });
  });
}

void setupPaste({bool isRegExpChanged = false}) {
  setUp(() async {
    final random = Random();
    String clipboardContent = '';

    if (isRegExpChanged) {
      const chars =
          'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';

      String getRandomString(int length) => String.fromCharCodes(
            Iterable.generate(
              length,
              (_) => chars.codeUnitAt(
                random.nextInt(chars.length),
              ),
            ),
          );
      clipboardContent = '${getRandomString(4)}12';
    } else {
      for (var i = 0; i < 6; i++) {
        clipboardContent = clipboardContent + random.nextInt(9).toString();
      }
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
}
