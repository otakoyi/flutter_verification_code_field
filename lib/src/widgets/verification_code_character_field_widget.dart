import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

@visibleForTesting

/// Single OTP Field
class VerificationCodeCharacterFieldWidget extends StatelessWidget {
  /// Default constructor for [VerificationCodeCharacterFieldWidget]
  const VerificationCodeCharacterFieldWidget({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onPaste,
    required this.size,
    required this.pattern,
    super.key,
  });

  /// FocusNode Controller [FocusNode]
  final FocusNode focusNode;

  /// TextField Controller [TextEditingController]
  final TextEditingController controller;

  /// A callback function that is called when a change is detected on the pin [ValueChanged].
  final ValueChanged<String> onChanged;

  /// A callback function that is called when a paste operation is detected on the pin [VoidCallback].
  final VoidCallback onPaste;

  /// Size of the OTP Field [Size].
  final Size size;

  /// Pattern for validation [RegExp].
  final RegExp pattern;

  @override
  Widget build(BuildContext context) {
    const decoration = InputDecoration(
      counterText: '',
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
      onChanged: onChanged,
    );
  }
}
