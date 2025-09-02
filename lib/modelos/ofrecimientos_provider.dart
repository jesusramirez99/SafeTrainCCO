import 'dart:convert';
import 'dart:async'; // Necesario para el Timer
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:safe_train_cco/config/enviroments.dart';

class OfrecimientosProvider with ChangeNotifier {
  List<String> _trenesOfrecidos = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<String> get trenesOfrecidos => _trenesOfrecidos;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Timer? _timer;

  // Constructor
  void startAutoRefresh(BuildContext context, String user) {
    _timer?.cancel();
    fetchOfrecimientos(context, user);

    _timer = Timer.periodic(const Duration(seconds: 60), (timer) {
      fetchOfrecimientos(context, user);
    });
  }

  Future<void> fetchOfrecimientos(BuildContext context, String user) async {
    String url =
        '${Enviroment.baseUrl}/getOfreciomientosCCOUser?userId=$user';

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic>? trenesOfrecidos = data['DataTren']?['wrapper'];

        if (trenesOfrecidos != null) {
          _trenesOfrecidos = List<String>.from(trenesOfrecidos);
        } else {
          _trenesOfrecidos = [];
          _errorMessage = "No se encontraron trenes ofrecidos.";
        }
      } else {
        _errorMessage =
            "Error ${response.statusCode}: No se pudo obtener la información.";
      }
    } catch (e) {
      _errorMessage = "Error de conexión: $e";
    }

    _isLoading = false;
    notifyListeners();
  }

  void refreshOfrecimientos(BuildContext context, String user) {
    fetchOfrecimientos(context, user);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
