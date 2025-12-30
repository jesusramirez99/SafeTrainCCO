import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:safe_train_cco/config/enviroments.dart';

class MotivoRechazoProvider with ChangeNotifier {
  List<Map<String, dynamic>> _motivosRechazo = [];

  List<Map<String, dynamic>> get motivosRechazo => _motivosRechazo;

  // Método para cargar los datos
  Future<void> cargarMotivosRechazo() async {
    String url = '${Enviroment.baseUrl}/getMotivoRecahzo';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _motivosRechazo =
            List<Map<String, dynamic>>.from(data['MotivosRechazo']);
        notifyListeners();
      } else {
        throw Exception('Error al cargar los motivos');
      }
    } catch (error) {
      throw Exception('Error al cargar los motivos: $error');
    }
  }
}
