import 'package:flutter/material.dart';
import '../controllers/language_controller.dart';

class LocalizedText extends StatelessWidget {
  final String textKey;
  final TextStyle? style;
  final TextAlign? textAlign;

  const LocalizedText(
    this.textKey, {
    super.key,
    this.style,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      LanguageController().getText(textKey),
      style: style,
      textAlign: textAlign,
    );
  }
}

class LocalizedButton extends StatelessWidget {
  final String textKey;
  final VoidCallback onPressed;
  final Color? color;
  final bool isOutlined;

  const LocalizedButton({
    super.key,
    required this.textKey,
    required this.onPressed,
    this.color,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final text = LanguageController().getText(textKey);
    
    if (isOutlined) {
      return OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color ?? Theme.of(context).primaryColor),
        ),
        child: Text(text),
      );
    }

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
      ),
      child: Text(text),
    );
  }
}

class LocalizedTextField extends StatelessWidget {
  final String labelKey;
  final String hintKey;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onSubmitted;

  const LocalizedTextField({
    super.key,
    required this.labelKey,
    required this.hintKey,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        labelText: LanguageController().getText(labelKey),
        hintText: LanguageController().getText(hintKey),
        border: const OutlineInputBorder(),
      ),
    );
  }
}
