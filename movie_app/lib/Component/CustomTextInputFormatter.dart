import 'package:flutter/services.dart';

class CustomTextInputFormatter extends FilteringTextInputFormatter {
  CustomTextInputFormatter() : super.allow(RegExp(r'[a-zA-Z0-9\x20-\x7E]'));

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Validate the new input value against the allowed characters
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Check if newValue contains any disallowed characters
    if (!isValidInput(newValue.text)) {
      // If invalid characters found, return the oldValue
      return oldValue;
    }

    // Otherwise, accept the newValue
    return newValue;
  }

  bool isValidInput(String input) {
    // Check if input contains any characters outside the allowed range
    for (int i = 0; i < input.length; i++) {
      int charCode = input.codeUnitAt(i);
      if (charCode < 0x20 || charCode > 0x7E) {
        // Exclude characters outside printable ASCII range
        return false;
      }
    }
    return true;
  }
}