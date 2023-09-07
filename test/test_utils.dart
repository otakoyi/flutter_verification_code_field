import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_verification_code_field/flutter_verification_code_field.dart';

import 'app_wrapper.dart';

const length = 6;

extension Repeat on int {
  FutureOr<void> repeat(FutureOr<void> Function() fn) async {
    assert(this > 0);
    for (int i = 0; i < this; i++) {
      await fn();
    }
  }
}

Future<void> prepare(WidgetTester tester) async {
  await tester.pumpWidget(AppWrapper(
      child: VerificationCodeField(
    length: length,
  )));
}

final finder = find.byType(TextField);

List<TextField> textFields(WidgetTester tester) {
  return [for (final field in tester.widgetList(finder)) (field as TextField)];
}

List<FocusNode> focusNodes(WidgetTester tester) {
  final nodes = [
    for (final field in textFields(tester))
      if (field.focusNode case final node?) node
  ];
  return nodes;
}
