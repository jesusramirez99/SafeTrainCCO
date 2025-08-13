import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SelectionNotifier extends ChangeNotifier {
  ValueNotifier<int?> selectedRowNotifier = ValueNotifier<int?>(null);

  void updateSelectedRow(int? index) {
    selectedRowNotifier.value = index;
    notifyListeners();
  }
}

class ButtonStateNotifier extends ChangeNotifier {
  Map<String, bool> buttonStates = {
    'indicador': true,
    'informacion': true,
    'autorizar': true,
    'cancelar': true,
    // Agrega otros botones aquí
  };

  bool isButtonEnabled(String buttonKey) {
    return buttonStates[buttonKey] ?? true;
  }

  void setButtonState(String buttonKey, bool isEnabled) {
    buttonStates[buttonKey] = isEnabled;
    notifyListeners();
  }
}

// CLASE PARA SELECCIONAR LOS CAMPOS ID TREN Y FECHA
class TrainSelectionProvider with ChangeNotifier {
  TextEditingController idTrainController = TextEditingController();
  TextEditingController fechaController = TextEditingController();

  void updateTrainSelection(String trainId, String trainDate) {
    idTrainController.text = trainId;
    fechaController.text = trainDate;
    notifyListeners();
  }
}

// CLASE PARA OBTENER LA FECHA Y HORA
class DateProvider with ChangeNotifier {
  String _currentDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
  String _currentTime = DateFormat('HH:mm').format(DateTime.now());

  String get currentDate => _currentDate;
  String get currentTime => _currentTime;

  DateProvider() {
    updateDateTime();
  }

  void updateDateTime() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      final now = DateTime.now();

      _currentDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
      _currentTime = DateFormat('HH:mm').format(DateTime.now());
      notifyListeners();
    });
  }
}
