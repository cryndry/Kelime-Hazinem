import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kelime_hazinem/components/icon.dart';
import 'package:kelime_hazinem/utils/const_objects.dart';
import 'package:kelime_hazinem/utils/my_svgs.dart';

class MyTextInput extends StatefulWidget {
  const MyTextInput({
    super.key,
    required this.label,
    required this.hintText,
    required this.textInputController,
    this.keyboardAction = TextInputAction.next,
    this.validator,
    this.errormessage,
    this.formatArabic = false,
    this.autoFocus = false,
    this.focusNode,
    this.loseFocusOnTapOutside = true,
    this.customInputFormatter,
    this.onChange,
  });

  final String label;
  final String hintText;
  final TextEditingController textInputController;
  final TextInputAction keyboardAction;
  final String? Function(String?)? validator;
  final String? errormessage;
  final bool formatArabic;
  final bool autoFocus;
  final FocusNode? focusNode;
  final bool loseFocusOnTapOutside;
  final List<TextInputFormatter>? customInputFormatter;
  final void Function(String)? onChange;

  @override
  State<MyTextInput> createState() => MyTextInputState();
}

class MyTextInputState extends State<MyTextInput> {
  late final FocusNode textInputFocus = widget.focusNode ?? FocusNode();
  late TextDirection textDirection = widget.formatArabic ? TextDirection.rtl : TextDirection.ltr;
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
  void didUpdateWidget(covariant MyTextInput oldWidget) {
    if (oldWidget.errormessage == widget.errormessage) {
      setState(() {});
    }

    if (oldWidget.formatArabic == widget.formatArabic) {
      setState(() {
        textDirection = widget.formatArabic ? TextDirection.rtl : TextDirection.ltr;
      });
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      maxLines: null,
      autofocus: widget.autoFocus,
      textDirection: textDirection,
      inputFormatters: widget.formatArabic
          ? [FilteringTextInputFormatter.allow(MyRegExpPatterns.allArabic)]
          : widget.customInputFormatter,
      focusNode: textInputFocus,
      controller: widget.textInputController,
      keyboardType: TextInputType.text,
      textInputAction: widget.keyboardAction,
      validator: widget.validator,
      onTapOutside: widget.loseFocusOnTapOutside
          ? (event) {
              if (textInputFocus.hasFocus) {
                textInputFocus.unfocus();
              }
            }
          : null,
      onChanged: (value) {
        widget.onChange?.call(value);
        setState(() {});
      },
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintTextDirection: textDirection,
        errorMaxLines: 3,
        errorText: widget.errormessage,
        contentPadding: const EdgeInsets.all(16),
        suffixIcon: widget.textInputController.text.isNotEmpty && !widget.formatArabic ? clearIcon : null,
        prefixIcon: widget.textInputController.text.isNotEmpty && widget.formatArabic ? clearIcon : null,
        label: Text(
          widget.label,
          textDirection: textDirection,
          style: MyTextStyles.font_16_20_500,
        ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          borderSide: BorderSide(
            width: 1,
            color: Color.fromRGBO(0, 0, 0, 0.6),
          ),
        ),
      ),
    );
  }
}
