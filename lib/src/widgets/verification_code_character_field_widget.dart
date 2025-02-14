import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// The VerificationCodeField entry point
///
/// To use the VerificationCodeField class, call VerificationCodeField(controller: $controller, focusNode: $focusNode, onChanged: $onChanged, onPaste: $onPaste, size: $size, pattern: $pattern)
class VerificationCodeCharacterFieldWidget extends StatelessWidget {
  /// Default constructor for [VerificationCodeCharacterFieldWidget]
  const VerificationCodeCharacterFieldWidget({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onPaste,
    required this.size,
    required this.pattern,
    required this.placeholder,
    required this.showCursor,
    required this.autofocus,
    this.readOnly = false,
    this.hasError = false,
    this.enabled,
    super.key,
  });

  /// FocusNode Controller [FocusNode].
  final FocusNode focusNode;

  /// TextField Controller [TextEditingController].
  final TextEditingController controller;

  /// A callback function that is called when a change is detected on the pin [ValueChanged].
  ///
  /// If the field data is changed, returns new data [String]
  final ValueChanged<String> onChanged;

  /// A callback function that is called when a paste operation is detected on the pin [VoidCallback].
  final VoidCallback onPaste;

  /// Size of the OTP Field [Size].
  final Size size;

  /// Pattern for validation [RegExp].
  final RegExp pattern;

  /// Placeholder symbol
  final String placeholder;

  /// Show or hide cursor
  final bool? showCursor;

  /// Autofocus
  final bool autofocus;

  /// Whether the underlying textfields have errors
  final bool hasError;

  /// Whether the underlying textfields are read only
  final bool readOnly;

  /// Whether the underlying textfields are enabled or disabled
  final bool? enabled;

  @override
  Widget build(BuildContext context) {
    final decoration = InputDecoration(
      counterText: '',
      errorMaxLines: 1,
      // Centers text which otherwise is skewered 4 px to the left
      contentPadding: EdgeInsets.only(left: 2),
      hintText: placeholder,
      errorStyle: TextStyle(height: double.minPositive),
      errorText: hasError ? '' : null,
    );

    return Theme(
      data: Theme.of(context).copyWith(
        textSelectionTheme: TextSelectionThemeData(
          selectionColor: Colors.transparent,
          selectionHandleColor: Colors.transparent,
        ),
      ),
      child: TextField(
        expands: true,
        minLines: null,
        maxLines: null,
        enabled: enabled,
        readOnly: readOnly,
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.allow(pattern)],
        maxLength: 1,
        focusNode: focusNode,
        style: TextStyle(fontSize: size.height / 2),
        cursorHeight: size.height / 2,
        showCursor: showCursor,
        onTap: () {
          if (controller.text.isNotEmpty) {
            controller.selection =
                TextSelection(baseOffset: 0, extentOffset: 1);
          }
        },
        contextMenuBuilder: (context, editableTextState) {
          return AdaptiveTextSelectionToolbar.editable(
            onShare: null,
            onSearchWeb: null,
            onLookUp: null,
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
        autofocus: autofocus,
        decoration: decoration,
        onChanged: onChanged,
      ),
    );
  }
}
