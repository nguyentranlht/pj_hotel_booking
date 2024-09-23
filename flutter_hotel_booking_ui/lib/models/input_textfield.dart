import 'package:flutter/material.dart';

class InputTextField extends StatelessWidget {
  final TextEditingController myController;
  final FocusNode focusNode;
  final FormFieldSetter onFiledSubmittedValue;
  final FormFieldValidator onValidator;
  final TextInputType keyBoardType;
  final String hint;
  final bool obscureText;
  final bool enable, autoFocus;
  const InputTextField(
      {Key? key,
      required this.myController,
      required this.focusNode,
      required this.onFiledSubmittedValue,
      required this.keyBoardType,
      required this.obscureText,
      required this.hint,
      this.enable = true,
      required this.onValidator,
      this.autoFocus = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return TextFormField(
        controller: myController,
        focusNode: focusNode,
        obscureText: obscureText,
        onFieldSubmitted: onFiledSubmittedValue,
        validator: onValidator,
        keyboardType: keyBoardType,
        decoration: const InputDecoration());
  }
}
