import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:safe_train_cco/config/enviroments.dart';

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
    required String ObservacionesAut,
    String? file1,
    String? file2,
    String? file1Name,
    String? file2Name,

  }) async {
    final url =
        Uri.parse("${Enviroment.baseUrl}/autorizarTren");

    final Map<String, dynamic> requestBody = {
      "ID": id,
      "Pending_Train_ID": pendingTrainId,
      "autorizado": "Autorizado",
      "autorizado_por": autorizadoPor,
      "fecha_autorizado": DateTime.now().toIso8601String(),
      "estacion_actual": estacionActual,
      "llamado_por": autorizadoPor,
      "fecha_llamado": fechaLlamado,
      "observ_autorizado": ObservacionesAut,
      "nombre_archivo1": file1Name,
      "nombre_archivo2": file2Name,
      "archivo1": file1,
      "archivo2": file2,
    };

    print('informacion: ${requestBody}');

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
