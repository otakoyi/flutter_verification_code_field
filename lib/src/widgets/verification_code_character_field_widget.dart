import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class VerificationCodeCharacterFieldWidget extends StatelessWidget {
  /// Default constructor for [VerificationCodeCharacterFieldWidget]
  const VerificationCodeCharacterFieldWidget({
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
