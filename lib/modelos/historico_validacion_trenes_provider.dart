import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HistorialValidacionesProvider with ChangeNotifier {
  List<Map<String, dynamic>> _validationHistory = [];
  List<String> _motivosRechazo = [];
  String _observaciones = "";
  bool _isLoading = false;
  String? _errorMessage;

  List<Map<String, dynamic>> get validationHistory => _validationHistory;
  List<String> get motivosRechazo => _motivosRechazo;
  String get observaciones => _observaciones;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> historialValidaciones(String trainId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse(
          'http://10.10.76.150/TrenSeguroDev/api/getHistoricoVal?idTren=$trainId',
        ),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        if (jsonData.containsKey('Historico') &&
            jsonData['Historico'].containsKey('wrapper')) {
          final wrapper = jsonData['Historico']['wrapper'];

          if (wrapper is List) {
            _validationHistory = List<Map<String, dynamic>>.from(wrapper);

            // Extraer motivos de rechazo y observaciones del primer registro
            if (_validationHistory.isNotEmpty) {
              _motivosRechazo = _extractMotivosRechazo(_validationHistory);
              _observaciones = _validationHistory.first["observaciones"] ?? "";
            }
          }
        }
      } else {
        throw Exception('Error al cargar datos: ${response.statusCode}');
      }
    } catch (e) {
      print('Error capturado: $e');
      _validationHistory = [];
      _motivosRechazo = [];
      _observaciones = "";
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Método para extraer los motivos de rechazo
  List<String> _extractMotivosRechazo(List<Map<String, dynamic>> data) {
    List<String> motivos = [];
    for (var entry in data) {
      if (entry.containsKey('motivos_rechazo') &&
          entry['motivos_rechazo'] is List) {
        for (var motivo in entry['motivos_rechazo']) {
          if (motivo is Map<String, dynamic> && motivo.containsKey('motivo')) {
            motivos.add(motivo['motivo']);
          }
        }
      }
    }
    return motivos;
  }
}
