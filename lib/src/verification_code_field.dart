import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_verification_code_field/src/hooks/focus_node_list_hook.dart';
import 'package:flutter_verification_code_field/src/hooks/text_controller_list_hook.dart';

class VerificationCodeField extends HookWidget {
  VerificationCodeField({
    required this.length,
    this.onFilled,
    this.size = const Size(40, 60),
    this.margin = 16,
    RegExp? matchingPattern,
    super.key,
  }) {
    pattern = matchingPattern ?? RegExp(r'^\d+$');
  }

  final int length;
  final VoidCallback? onFilled;
  final Size size;
  final double margin;
  late final RegExp pattern;

  @override
  Widget build(BuildContext context) {
    final code = useRef(List.filled(length, ''));
    final textControllers = useTextControllerList(length: length);
    final focusNodes =
        useFocusNodeList(length: length, debugLabel: 'codeInput');
    final focusScope = useFocusScopeNode();
    final currentIndex = useRef(0);

    final moveToPrevious = useCallback(() {
      if (currentIndex.value > 0) {
        currentIndex.value--;
        focusScope.requestFocus(focusNodes[currentIndex.value]);
      }
    });

    final moveToNext = useCallback(() {
      if (currentIndex.value < length - 1) {
        currentIndex.value++;
        focusScope.requestFocus(focusNodes[currentIndex.value]);
      }
    });

    final onPaste = useCallback(() async {
      final latestClipboard =
          (await Clipboard.getData(Clipboard.kTextPlain))?.text;
      if (latestClipboard == null ||
          latestClipboard.length != length ||
          !pattern.hasMatch(latestClipboard)) {
        return;
      }
      for (var i = 0; i < length; i++) {
        textControllers[i].text = code.value[i] = latestClipboard[i];
      }
      focusScope.requestFocus(focusNodes.lastOrNull);
    });

    useEffect(
      () {
        focusScope.onKeyEvent = (node, event) {
          if (!node.children.elementAt(currentIndex.value).hasFocus) {
            return KeyEventResult.handled;
          }
          if (event is KeyUpEvent) {
            return KeyEventResult.handled;
          }
          final character = code.value[currentIndex.value];
          if (event.logicalKey == LogicalKeyboardKey.backspace &&
              character.isEmpty) {
            moveToPrevious();
            return KeyEventResult.handled;
          }
          if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            moveToPrevious();
            return KeyEventResult.handled;
          }
          if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            moveToNext();
            return KeyEventResult.handled;
          }
          if (character.isNotEmpty && pattern.hasMatch(event.character ?? '')) {
            textControllers[currentIndex.value].text =
                code.value[currentIndex.value] = event.character ?? '';
            moveToNext();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        };
        for (var i = 0; i < length; i++) {
          focusNodes[i].addListener(() {
            if (focusNodes[i].hasFocus) {
              currentIndex.value = i;
            }
          });
        }
        return null;
      },
      [focusNodes],
    );

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyV, control: true): onPaste,
      },
      child: FocusScope(
        node: focusScope,
        child: Column(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (int index = 0; index < length; index++)
                      Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        height: size.height,
                        width: size.width,
                        margin: EdgeInsets.only(
                          left: index == 0 ? 0 : margin,
                        ),
                        child: _VerificationCodeCharacterField(
                          pattern: pattern,
                          controller: textControllers[index],
                          focusNode: focusNodes[index],
                          size: size,
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              moveToNext();
                            }
                            code.value[index] = value;
                            if (onFilled != null &&
                                code.value.join().length == length) {
                              onFilled?.call();
                            }
                          },
                          onPaste: onPaste,
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _VerificationCodeCharacterField extends StatelessWidget {
  /// Default constructor for [_VerificationCodeCharacterField]
  const _VerificationCodeCharacterField({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onPaste,
    required this.size,
    required this.pattern,
  });

  final FocusNode focusNode;

  final TextEditingController controller;

  final ValueChanged<String> onChanged;

  final VoidCallback onPaste;

  final Size size;

  final RegExp pattern;

  @override
  Widget build(BuildContext context) {
    const decoration = InputDecoration(
      counterText: '',
      // contentPadding: EdgeInsets.all((size * 2) / 10),
      errorMaxLines: 1,
    );

    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.allow(pattern)],
      maxLength: 1,
      focusNode: focusNode,
      style: TextStyle(fontSize: size.height / 2),
      contextMenuBuilder: (context, editableTextState) {
        return AdaptiveTextSelectionToolbar.editable(
          clipboardStatus: ClipboardStatus.pasteable,
          onCopy: null,
          onCut: null,
          onPaste: () {
            onPaste();
            editableTextState.hideToolbar();
          },
          onSelectAll: null,
          anchors: editableTextState.contextMenuAnchors,
          onLiveTextInput: null,
        );
      },
      maxLengthEnforcement: MaxLengthEnforcement.enforced,
      autocorrect: false,
      textAlign: TextAlign.center,
      autofocus: true,
      decoration: decoration,
      //      textInputAction: TextInputAction.previous,
      onChanged: onChanged,
    );
  }
}
