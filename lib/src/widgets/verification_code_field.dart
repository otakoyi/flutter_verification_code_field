import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_verification_code_field/src/hooks/focus_node_list_hook.dart';
import 'package:flutter_verification_code_field/src/hooks/text_controller_list_hook.dart';
import 'package:flutter_verification_code_field/src/widgets/verification_code_character_field_widget.dart';

class VerificationCodeField extends HookWidget {
  VerificationCodeField({
    required this.length,
    this.onFilled,
    this.size = const Size(40, 60),
    this.margin = 16,
    RegExp? matchingPattern,
    super.key,
  }) : assert(length > 0, 'Length must be positive') {
    pattern = matchingPattern ?? RegExp(r'^\d+$');
  }

  final int length;
  final ValueChanged<String>? onFilled;
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
      onFilled?.call(latestClipboard);
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
        for (final (index, focusNode) in focusNodes.indexed) {
          focusNode.addListener(() {
            if (focusNode.hasFocus) {
              currentIndex.value = index;
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
                        child: VerificationCodeCharacterFieldWidget(
                          pattern: pattern,
                          controller: textControllers[index],
                          focusNode: focusNodes[index],
                          size: size,
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              moveToNext();
                            }
                            code.value[index] = value;
                            final codeString = code.value.join();
                            if (onFilled != null &&
                                codeString.length == length) {
                              onFilled?.call(codeString);
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
