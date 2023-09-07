import 'dart:async';

import 'package:flutter/material.dart';
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
  Future<void> prepare() async {
    await pumpWidget(AppWrapper(
        child: VerificationCodeField(
      length: length,
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
