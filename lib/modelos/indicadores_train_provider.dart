import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class IndicatorTrainProvider with ChangeNotifier {
  List<Map<String, dynamic>> _indicatorTrain = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get indicatorTrain => _indicatorTrain;
  bool get isLoading => _isLoading;

  Future<void> fetchIndicatorTrain(String idTren, String estacionActual) async {
    _isLoading = true;

    // Usamos Future.delayed para evitar conflicto con la construcción del widget
    Future.microtask(() => notifyListeners());

    final url =
        'http://10.10.76.150/TrenSeguroDev/api/obtenerIndicadoresTren?idTren=$idTren&estacion_actual=$estacionActual';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        _indicatorTrain = [jsonData['Indicadores']];
      } else {
        throw Exception('Error al obtener los indicadores del tren');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
