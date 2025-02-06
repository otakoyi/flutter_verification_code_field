import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_verification_code_field/src/hooks/focus_node_list_hook.dart';
import 'package:flutter_verification_code_field/src/hooks/text_controller_list_hook.dart';
import 'package:flutter_verification_code_field/src/widgets/verification_code_character_field_widget.dart';

/// The VerificationCodeField entry point
///
/// To use the VerificationCodeField class, call VerificationCodeField(length: $length)
class VerificationCodeField extends HookWidget {
  /// Default constructor for [VerificationCodeField]
  VerificationCodeField({
    required this.length,
    this.onFilled,
    this.size = const Size(40, 40),
    this.spaceBetween = 16,
    this.placeholder = '',
    this.showCursor,
    this.autofocus = false,
    RegExp? matchingPattern,
    super.key,
  })  : assert(length > 0, 'Length must be positive'),
        assert(size.height != double.infinity && size.width != double.infinity,
            'The height and width of the Size must be finite.') {
    pattern = matchingPattern ?? RegExp(r'^\d+$');
  }

  /// Number of the OTP Fields [int].
  final int length;

  /// Callback function that is called when the verification code is filled [ValueChanged].
  ///
  /// If the field is filled, returns data [String]
  final ValueChanged<String>? onFilled;

  /// Size of the single OTP Field
  ///
  /// default: Size(40, 40) [Size].
  final Size size;

  /// Space between the text fields
  ///
  /// default: 16 [double].
  final double spaceBetween;

  /// Pattern for validation
  ///
  /// default: RegExp(r'^\d+$') [RegExp].
  late final RegExp pattern;

  /// Placeholder symbol
  final String placeholder;

  /// Show or hide the cursor
  final bool? showCursor;

  /// Autofocus
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final code = useRef(List.filled(length, ''));
    final textControllers = useTextControllerList(length: length);
    final focusNodes =
        useFocusNodeList(length: length, debugLabel: 'codeInput');
    final focusScope = useFocusScopeNode();
    final currentIndex = useRef(0);

    /// Used to move the focus to the previous OTP field
    final moveToPrevious = useCallback(() {
      if (currentIndex.value > 0) {
        for (var i = currentIndex.value - 1; i > 0; i--) {
          if (textControllers[i].text.isEmpty) continue;
          currentIndex.value = i;
          focusScope.requestFocus(focusNodes[i]);
          return;
        }

        focusScope.requestFocus(focusNodes[0]);
      }
    });

    /// Used to move the focus to the previous OTP field
    final moveToPreviousSingle = useCallback(() {
      if (currentIndex.value > 0) {
        currentIndex.value--;
        focusScope.requestFocus(focusNodes[currentIndex.value]);
      }
    });

    /// Used to move the focus to the next OTP field
    final moveToNext = useCallback(() {
      if (currentIndex.value < length - 1) {
        currentIndex.value++;
        focusScope.requestFocus(focusNodes[currentIndex.value]);
      }
    });

    /// Called when information is pasted into an input field
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
            moveToPreviousSingle();
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
              if (textControllers[index].text.isNotEmpty) {
                textControllers[index].selection =
                    TextSelection.collapsed(offset: 1);
              }
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
        const SingleActivator(LogicalKeyboardKey.keyV, meta: true): onPaste,
      },
      child: FocusScope(
        node: focusScope,
        child: Row(
          spacing: spaceBetween,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int index = 0; index < length; index++)
              SizedBox(
                height: size.height,
                width: size.width,
                child: Align(
                  child: VerificationCodeCharacterFieldWidget(
                    pattern: pattern,
                    autofocus: autofocus,
                    controller: textControllers[index],
                    focusNode: focusNodes[index],
                    size: size,
                    placeholder: placeholder,
                    showCursor: showCursor,
                    autofillHints: [AutofillHints.oneTimeCode],
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        moveToNext();
                      }
                      if (value.isEmpty) {
                        moveToPrevious();
                      }
                      code.value[index] = value;
                      final codeString = code.value.join();
                      if (onFilled != null && codeString.length == length) {
                        focusScope.unfocus();
                        onFilled?.call(codeString);
                      }
                    },
                    onPaste: onPaste,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
