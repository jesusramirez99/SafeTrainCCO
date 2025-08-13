import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RechazoTrenProvider with ChangeNotifier {
  final String _baseUrl = "http://10.10.76.150/TrenSeguroDev/api/rechazarTren";

  Future<void> rechazarTren({
    required int id,
    required String autorizadoPor,
    required String observaciones,
    required List<Map<String, String>> motivosRechazo,
  }) async {
    try {
      final DateTime now = DateTime.now();

      final Map<String, dynamic> data = {
        "ID": id,
        "autorizado": "Rechazado",
        "autorizado_por": autorizadoPor,
        "fecha_autorizado": DateTime.now().toIso8601String(),
        "observaciones": observaciones,
        "llamada_completada": DateTime.now().toIso8601String(),
        "motivos_rechazo": motivosRechazo,
      };

      print("JSON enviado: ${jsonEncode(data)}");

      final response = await http.put(
        Uri.parse("$_baseUrl"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        print("Tren rechazado exitosamente");
      } else {
        print("Error al rechazar tren: ${response.body}");
      }
    } catch (e) {
      print("Error en la solicitud: $e");
    }
  }
}
