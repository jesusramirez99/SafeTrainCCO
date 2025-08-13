import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  String? _userName;

  String? get userName => _userName;

  void setUserName(String name) {
    _userName = name;
    notifyListeners();
  }
}

// clase para obtener el tren
class TrenYFechaModel extends ChangeNotifier {
  String? _trenYFecha;
  String? get trenYFecha => _trenYFecha;

  void setTrenYFecha(String tren) {
    _trenYFecha = tren;
    notifyListeners();
    print('Nuevo tren guardado en TrenYFechaModel: $_trenYFecha');
  }

  void clearData() {
    _trenYFecha = null;
    notifyListeners();
  }
}

// PROVIDER PARA OBTENER LA REGION
class RegionProvider extends ChangeNotifier {
  String? _region;

  String? get region => _region;

  void setRegion(String newRegion) {
    _region = newRegion;
    notifyListeners();
  }
}

// PROVIDER PARA OBTENER EL FFCC
class FfccProvider extends ChangeNotifier {
  String _selectedItem = 'FFCC';

  String get selectedItem => _selectedItem;

  void setSelectedItem(String newValue) {
    _selectedItem = newValue;
    notifyListeners();
  }
}

// Clase para obtener la hora
class HoraProvider extends ChangeNotifier {
  String _hora = '';
  String get hora => _hora;

  void setHora(String time) {
    _hora = time;
    notifyListeners();
  }
}

// Clase para obtener la fecha
class FechaProvider extends ChangeNotifier {
  String _fecha = '';
  String get fecha => _fecha;

  void setFecha(String date) {
    _fecha = date;
    notifyListeners();
  }
}

// CLASE PARA OBTENER EL ID de un tren

class IdTren extends ChangeNotifier {
  int _idTren = 0;
  int get idTren => _idTren;

  void setSelectedID(String id) {
    _idTren = int.tryParse(id.trim()) ??
        0; // Asegura que el valor sea un número válido
    notifyListeners();
  }

  void setId(int newId) {
    _idTren = newId;
    notifyListeners();
  }
}

// Clase para manejar el estado de Estatus CCO
class EstatusCCOProvider with ChangeNotifier {
  String _estatusCCO = '';

  String get estatusCCO => _estatusCCO;

  void updateEstatusCCO(String nuevoEstatus) {
    _estatusCCO = nuevoEstatus;
    notifyListeners();
  }

  void limpiarEstatus() {
    _estatusCCO = '';
    notifyListeners();
  }
}

class MotRechazoObs with ChangeNotifier {
  int idTrain = 0; // Inicializa con 0 para evitar errores
  String? motivoRechazo;
  String? observaciones;

  void setSelectedTrain(int id, String motivo, String obs) {
    idTrain = id;
    motivoRechazo = motivo;
    observaciones = obs;
    notifyListeners();
  }

  void clearData() {
    idTrain = 0; // Ahora sí se limpia correctamente
    motivoRechazo = null;
    observaciones = null;
    notifyListeners();
  }
}
