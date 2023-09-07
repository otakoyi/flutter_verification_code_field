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

  testWidgets('First field is focused', (tester) async {
    await tester.prepare();
    expect(tester.getFocusNodes()[0], predicate<FocusNode>((n) => n.hasFocus));
  });

  testWidgets('Arrow keys are moving the cursor', (tester) async {
    await tester.prepare();
    final stepsRight = Random().nextInt(length - 2) + 1;
    await stepsRight.repeat(
        () async => await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight));
    final nodes = tester.getFocusNodes();

    expect(nodes[stepsRight].hasFocus, true);
    nodes.first.requestFocus();
    await length.repeat(
        () async => await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight));
    expect(nodes.last.hasFocus, true);
    nodes.last.requestFocus();
    final stepsLeft = Random().nextInt(length - 2) + 1;
    await stepsLeft.repeat(
        () async => await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft));
    expect(nodes[length - 1 - stepsLeft].hasFocus, true);
    nodes.last.requestFocus();
    await length.repeat(
        () async => await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft));
    expect(nodes.first.hasFocus, true);
  });
}
