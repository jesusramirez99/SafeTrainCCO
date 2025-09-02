import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:safe_train_cco/config/enviroments.dart';

class LoginProviderCCO with ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _userData;
  List<String> _regiones = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get userData => _userData;
  List<String> get regiones => _regiones;

  String? get regionPrincipal => _regiones.isNotEmpty ? _regiones.first : null;

  Future<bool> login(String userName, String password) async {
    _isLoading = true;
    _errorMessage = null;
    _userData = null;
    _regiones = [];
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('${Enviroment.baseUrl}/getLoginCCO'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'USER_NAME': userName, 'PASSWORD': password}),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['result']['success']) {
          _userData = responseData['result']['wrapper'];

          // Extraer las regiones únicas del arreglo regionEstacion
          final regionEstacion = _userData?['regionEstacion'] as List<dynamic>;
          _regiones =
              regionEstacion.map((e) => e['region'] as String).toSet().toList();

          print('Regiones: $_regiones');

          notifyListeners();
          return true;
        } else {
          _errorMessage = responseData['result']['message'] ?? 'Login fallido';
          return false;
        }
      } else {
        _errorMessage = 'Error en el login, código: ${response.statusCode}';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error en el login: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
