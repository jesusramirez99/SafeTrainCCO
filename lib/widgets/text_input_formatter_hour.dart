import 'package:flutter/services.dart';

// El TextInputFormatter personalizado para hora
class HoraInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Si el valor es vacío, se regresa el valor original
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Filtra solo los números y los dos puntos
    String newText = newValue.text.replaceAll(RegExp(r'[^0-9:]'), '');

    // Asegura que el formato sea correcto con dos puntos
    if (newText.length > 5) {
      newText = newText.substring(0, 5);
    }
    if (newText.length > 2 && newText[2] != ':') {
      newText = newText.substring(0, 2) + ':' + newText.substring(2);
    }

    // Limita el tamaño del texto a 5 caracteres (por ejemplo, "16:28")
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
