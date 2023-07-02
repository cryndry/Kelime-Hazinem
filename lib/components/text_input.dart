import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kelime_hazinem/components/icon.dart';
import 'package:kelime_hazinem/utils/my_svgs.dart';

class MyTextInput extends StatefulWidget {
  const MyTextInput({
    super.key,
    required this.label,
    required this.hintText,
    required this.textInputController,
    this.keyboardAction = TextInputAction.next,
    this.validator,
    this.formatArabic = false,
  });

  final String label;
  final String hintText;
  final TextEditingController textInputController;
  final TextInputAction keyboardAction;
  final String? Function(String?)? validator;
  final bool formatArabic;

  @override
  State<MyTextInput> createState() => MyTextInputState();
}

class MyTextInputState extends State<MyTextInput> {
  final FocusNode textInputFocus = FocusNode();
  late final textDirection = widget.formatArabic ? TextDirection.rtl : TextDirection.ltr;
  late final clearIcon = Align(
    widthFactor: 1,
    heightFactor: 1,
    child: ActionButton(
      icon: MySvgs.clearText,
      strokeColor: Colors.black,
      size: 40,
      onTap: () {
        setState(widget.textInputController.clear);
      },
    ),
  );

  @override
  void dispose() {
    textInputFocus.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      maxLines: null,
      textDirection: textDirection,
      inputFormatters: widget.formatArabic
          ? <TextInputFormatter>[
              FilteringTextInputFormatter.allow(
                  RegExp(r"([\u0621-\u063A\u0641-\u06520-9٠-٩\p{P}\p{S}\s])", unicode: true))
            ]
          : null,
      focusNode: textInputFocus,
      controller: widget.textInputController,
      keyboardType: TextInputType.text,
      textInputAction: widget.keyboardAction,
      validator: widget.validator,
      onTapOutside: (event) {
        if (textInputFocus.hasFocus) {
          textInputFocus.unfocus();
        }
      },
      onChanged: (value) {
        setState(() {});
      },
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintTextDirection: textDirection,
        errorMaxLines: 3,
        contentPadding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
        suffixIcon: widget.textInputController.text.isNotEmpty && !widget.formatArabic ? clearIcon : null,
        prefixIcon: widget.textInputController.text.isNotEmpty && widget.formatArabic ? clearIcon : null,
        label: Text(
          widget.label,
          textDirection: textDirection,
          style: const TextStyle(
            fontSize: 16,
            height: 20 / 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(
            width: 1,
            color: Color.fromRGBO(0, 0, 0, 0.6),
          ),
        ),
      ),
    );
  }
}
