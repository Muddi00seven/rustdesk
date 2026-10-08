import 'package:flutter/material.dart';

class MacPilotRemoteKeyboard extends StatelessWidget {
  final GlobalKey<EditableTextState> inputKey;
  final FocusNode focusNode;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool secure;

  const MacPilotRemoteKeyboard({
    super.key,
    required this.inputKey,
    required this.focusNode,
    required this.controller,
    required this.onChanged,
    this.secure = false,
  });

  @override
  Widget build(BuildContext context) => Positioned(
        left: 0,
        top: 0,
        child: ExcludeSemantics(
          child: IgnorePointer(
            child: Opacity(
              opacity: 0,
              // Keep input geometry while taps continue to reach the remote canvas.
              child: SizedBox(
                width: 1,
                height: 1,
                child: EditableText(
                  key: inputKey,
                  controller: controller,
                  focusNode: focusNode,
                  style:
                      const TextStyle(fontSize: 16, color: Colors.transparent),
                  cursorColor: Colors.transparent,
                  backgroundCursorColor: Colors.transparent,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  obscureText: secure,
                  maxLines: secure ? 1 : null,
                  autocorrect: false,
                  enableSuggestions: false,
                  smartDashesType: SmartDashesType.disabled,
                  smartQuotesType: SmartQuotesType.disabled,
                  enableIMEPersonalizedLearning: false,
                  onChanged: onChanged,
                ),
              ),
            ),
          ),
        ),
      );
}
