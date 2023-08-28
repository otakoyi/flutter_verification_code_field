import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// A function that is used to generate an list of TextField Controllers.
List<TextEditingController> useTextControllerList({
  required int length,
  String? debugLabel,
}) {
  return use(
    _TextControllerListHook(length: length),
  );
}

class _TextControllerListHook extends Hook<List<TextEditingController>> {
  const _TextControllerListHook({
    required this.length,
  });

  final int length;

  @override
  _TextControllerListHookState createState() {
    return _TextControllerListHookState();
  }
}

class _TextControllerListHookState
    extends HookState<List<TextEditingController>, _TextControllerListHook> {
  late final List<TextEditingController> _textControllers = [];

  @override
  void initHook() {
    for (var i = 0; i < hook.length; i++) {
      _textControllers.add(TextEditingController());
    }
  }

  @override
  List<TextEditingController> build(BuildContext context) => _textControllers;

  @override
  void dispose() {
    for (final t in _textControllers) {
      t.dispose();
    }
  }

  @override
  String get debugLabel => 'useTextControllerList';
}
