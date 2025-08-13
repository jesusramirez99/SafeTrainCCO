import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'regla_incumplida_model.dart';

class ReglaIncumplidaProvider with ChangeNotifier {
  List<ReglaIncumplida> _reglasIncumplidas = [];
  bool _isLoading = false;

  List<ReglaIncumplida> get reglasIncumplidas => _reglasIncumplidas;

  bool get isLoading => _isLoading;

  Future<void> mostrarReglaIncumplida(int idRegla) async {
    _isLoading = true;
    notifyListeners();

    final url = Uri.parse(
        'http://10.10.76.150/TrenSeguroDev/api/getReglaIncumplida?idRegla=$idRegla');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        print('JSON recibido: $jsonResponse');

        final wrapper = jsonResponse['Consist']['wrapper'] as List;

        // Mapear al modelo ReglaIncumplida
        _reglasIncumplidas = wrapper
            .map((reglaJson) => ReglaIncumplida.fromJson(reglaJson))
            .toList();

        // Depuración: Verifica que las descripciones se asignen correctamente
        _reglasIncumplidas.forEach((regla) {
          print("Regla: ${regla.regla}, Descripción: ${regla.descripcion}");
        });
      } else {
        throw Exception('Error al obtener las reglas incumplidas');
      }
    } catch (e) {
      print('Error: $e');
      _reglasIncumplidas = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Nuevo método para obtener una regla por su ID
  ReglaIncumplida? obtenerReglaPorId(int id) {
    try {
      return _reglasIncumplidas.firstWhere((regla) => regla.idConsist == id);
    } catch (e) {
      return null; // Retorna null si no se encuentra la regla
    }
  }
}
