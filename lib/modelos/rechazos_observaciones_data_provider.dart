import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:safe_train_cco/config/enviroments.dart';

class RechazosObservacionesData with ChangeNotifier {
  List<String> _motivosRechazo = [];
  String _observaciones = "";

  List<String> get motivosRechazo => _motivosRechazo;
  String get observaciones => _observaciones;

  Future<void> fetchHistorico(int id) async {
    final url = Uri.parse(
        "${Enviroment.baseUrl}/getHistoricoDataVal?id=$id");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final historico = data["Historico"];
        final wrapper = historico != null ? historico["wrapper"] : null;

        if (wrapper == null) {
          print("⚠️ No se encontraron datos para el tren con ID: $id");
          _motivosRechazo = [];
          _observaciones = "Sin observaciones";
        } else {
          _motivosRechazo = (wrapper["motivos_rechazo"] as List?)
                  ?.map((m) => m["motivo"].toString())
                  .toList() ??
              [];
          _observaciones =
              wrapper["observaciones"]?.toString() ?? "Sin observaciones";
        }

        notifyListeners();
      } else {
        throw Exception("Error en la API: ${response.statusCode}");
      }
    } catch (e) {
      print("Error obteniendo datos: $e");
    }
  }
}
