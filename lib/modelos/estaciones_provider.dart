import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:safe_train_cco/config/enviroments.dart';

class EstacionesProvider with ChangeNotifier {
  List<Map<String, dynamic>> _estaciones = [];

  List<Map<String, dynamic>> get estaciones => _estaciones;
  List<String> get estacionesNombres {
    return _estaciones.map((e) => e['estacion'].toString()).toList();
  }

  // FUNCION PARA MOSTRAR LAS ESTACIONES
  Future<void> fetchEstaciones() async {
    final url =
        Uri.parse('${Enviroment.baseUrl}/getEstaciones');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _estaciones = List<Map<String, dynamic>>.from(data['show_cars']);
        notifyListeners();
      } else {
        throw Exception('Error al cargar las estaciones');
      }
    } catch (e) {
      print('Error: $e');
      throw e;
    }
  }

  // METODO PARA OBTENER LA ESTACION SELECCIONADA
  String? _selectedEstacion;
  String? get selectedEstacion => _selectedEstacion;

  void updateSelectedEstacion(String estacion) {
    _selectedEstacion = estacion;
    notifyListeners();
  }

  void clearData() {
    _selectedEstacion = null; // Limpia el valor
    notifyListeners(); // Notifica a los listeners para actualizar la UI
  }
}
