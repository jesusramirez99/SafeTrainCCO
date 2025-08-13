import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AutorizarTrenProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> autorizarTren({
    required int id,
    required String pendingTrainId,
    required String autorizadoPor,
    required String fecha,
    required String estacionActual,
    required String fechaLlamado,
  }) async {
    final url =
        Uri.parse("http://10.10.76.150/TrenSeguroDev/api/autorizarTren");

    final Map<String, dynamic> requestBody = {
      "ID": id,
      "Pending_Train_ID": pendingTrainId,
      "autorizado": "Autorizado",
      "autorizado_por": autorizadoPor,
      "fecha_autorizado": DateTime.now().toIso8601String(),
      "estacion_actual": estacionActual,
      "fecha_llamado": fechaLlamado,
    };

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        _isLoading = false;
        notifyListeners();
        return true; // Éxito
      } else {
        _errorMessage = "Error: ${response.statusCode}";
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = "Error de conexión: $e";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
