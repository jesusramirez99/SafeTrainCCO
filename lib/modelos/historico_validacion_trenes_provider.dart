import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:safe_train_cco/config/enviroments.dart';

class HistorialValidacionesProvider with ChangeNotifier {
  List<Map<String, dynamic>> _validationHistory = [];
  List<Map<String, dynamic>> _validationHistoryTrain = [];
  List<Map<String, dynamic>> _infoHistoryTrain = [];
  List<String> _motivosRechazo = [];
  String _observaciones = "";
  bool _isLoading = false;
  bool _isFilter = false;
  bool _isConsulting = false;
  String? _errorMessage;

  List<Map<String, dynamic>> get validationHistory => _validationHistory;
  List<Map<String, dynamic>> get validationHistoryTrain => _validationHistoryTrain;
  List<Map<String, dynamic>> get infoHistoryTrain => _infoHistoryTrain;
  List<String> get motivosRechazo => _motivosRechazo;
  String get observaciones => _observaciones;
  bool get isLoading => _isLoading;
  bool get isFilter => _isFilter;
  bool get isConsulting => _isConsulting;
  String? get errorMessage => _errorMessage;

  Future<void> historialValidaciones(String trainId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse(
          '${Enviroment.baseUrl}/getHistoricoVal?idTren=$trainId',
        ),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        if (jsonData.containsKey('Historico') &&
            jsonData['Historico'].containsKey('wrapper')) {
          final wrapper = jsonData['Historico']['wrapper'];

          if (wrapper is List) {
            _validationHistory = List<Map<String, dynamic>>.from(wrapper);
            _isFilter = false;
            _isConsulting = false;

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

  Future<void> historialValidacionTren(
    String idTren,
    String terminal,
    String region,
    String fechaInicio,
    String fechaFinal,
  ) async{
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try{
      final response = await http.post(
        Uri.parse('${Enviroment.baseUrl}/filtroHistorico'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'ID_TREN': idTren,
          'TERMINAL': terminal,
          'REGION': region,
          'FECHA_INICIO': fechaInicio,
          'FECHA_FIN': fechaFinal,
        }),
      );

      if(response.statusCode == 200){
        final Map<String, dynamic> jsonData = json.decode(response.body);

        if (jsonData.containsKey('Message') &&
            jsonData['Message'].containsKey('wrapper')) {
              final wrapper = jsonData['Message']['wrapper'];

              if(wrapper is List){
                _validationHistoryTrain = List<Map<String, dynamic>>.from(wrapper);
                _isFilter = true;
                _isConsulting = false;
              }
        }
      }else{
        throw Exception('Error al cargar datos: ${response.statusCode}');
      }
    }catch(e){
      _validationHistoryTrain = [];
      _errorMessage = e.toString();
    }finally{
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> informationHistoryTrain(
    String tcn,
    String ffc,
    String station
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse(
          '${Enviroment.baseUrl}/getInfoHistorico?tcn=$tcn&ffcc=$ffc&estacion=$station',
        ),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        if (jsonData.containsKey('Consist') &&
            jsonData['Consist'].containsKey('wrapper')) {
          final wrapper = jsonData['Consist']['wrapper'];

          if (wrapper is List) {
            _infoHistoryTrain = List<Map<String, dynamic>>.from(wrapper);
            _isFilter = false;
            _isConsulting = true;

          }
        }
      } else {
        throw Exception('Error al cargar datos: ${response.statusCode}');
      }
    } catch (e) {
      _infoHistoryTrain = [];
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }


  }

  void setFilter(bool value) {
    _isFilter = value;
    notifyListeners();
  }

  void setQuery(bool value) {
    _isConsulting = value;
    notifyListeners();
  }
}
