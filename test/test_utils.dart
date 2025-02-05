import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_verification_code_field/flutter_verification_code_field.dart';

import 'app_wrapper.dart';

const length = 6;
final finder = find.byType(TextField);

extension Repeat on int {
  FutureOr<void> repeat(FutureOr<void> Function() fn) async {
    assert(this > 0);
    for (int i = 0; i < this; i++) {
      await fn();
    }
  }
}

extension TesterX on WidgetTester {
  Future<void> prepare({RegExp? regex, bool autofocus = true}) async {
    await pumpWidget(AppWrapper(
        child: VerificationCodeField(
      length: length,
      matchingPattern: regex,
    )));
  }

  List<TextField> getTextFields() {
    return [for (final field in widgetList(finder)) (field as TextField)];
  }

  List<FocusNode> getFocusNodes() {
    final nodes = [
      for (final field in getTextFields())
        if (field.focusNode case final node?) node
    ];
    return nodes;
  }
}

class RepeatTextPaste {
  FutureOr<void> repeatWithParameters({
    bool isLogicalKeyboard = false,
    required WidgetTester tester,
    required String text,
    required FocusNode node,
    int startingPoint = 0,
    List<TextField> textFields = const [],
  }) async {
    assert(startingPoint >= 0);

    if (!node.hasFocus) {
      node.requestFocus();
      await tester.pump(const Duration(milliseconds: 100));
    }

    if (isLogicalKeyboard) {
      await tester.sendKeyEvent(LogicalKeyboardKey.paste);
    } else {
      await tester.longPress(find.byWidget(textFields[0]));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.text('Paste'));
      await tester.pump(const Duration(milliseconds: 100));
    }
    for (int i = 0; i < textFields.length; i++) {
      expect(textFields[i].controller!.text, text[i]);
    }
  }
}
