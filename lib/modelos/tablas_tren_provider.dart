import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:safe_train_cco/modelos/train_data.dart';

class TablesTrainsProvider extends ChangeNotifier {
  TrainData? _trainData;
  List<Map<String, dynamic>> _infoTrain = [];

  List<Map<String, dynamic>> _dataTrain = [];

  List<Map<String, dynamic>> get dataTrain => _dataTrain;

  String? _selectedID;
  bool _isLoading = false;

  TrainData? get trainData => _trainData;
  bool get isLoading => _isLoading;
  String? get selectedID => _selectedID;

  int _rowsPerPage = 10;
  List<Map<String, dynamic>> get infoTrain => _infoTrain;
  int get rowsPerPage => _rowsPerPage;

  void setSelectedID(String id) {
    _selectedID = id;
    notifyListeners();
  }

  void clearData() {
    _trainData = null;
    notifyListeners();
  }

  Future<void> tableDataTrain(BuildContext context, String idTren) async {
    _isLoading = true;
    notifyListeners();

    final url =
        'http://10.10.76.150/TrenSeguroDev/api/getInfoTrenCCOOfrecido?idTren=$idTren';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data != null && data is Map<String, dynamic> && data.isNotEmpty) {
          _trainData = TrainData.fromJson(data);
        } else {
          _trainData = null;
          print('El tren no fue encontrado.');
        }
      } else {
        throw Exception('Failed to load train info');
      }
    } catch (e) {
      print('Error fetching train info: $e');
      _trainData = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // FUNCION PARA REFRESCAR LA TABLA DESPUES DE VALIDAR EL TREN

  String _observaciones = '';
  List<String> _motivosRechazo = [];

  String get observaciones => _observaciones;
  List<String> get motivosRechazo => _motivosRechazo;

  void setObservaciones(String obs) {
    _observaciones = obs;
    notifyListeners();
  }

  void setMotivosRechazo(List<String> motivos) {
    _motivosRechazo = motivos;
    notifyListeners();
  }

  Future<void> refreshTableDataTrain(
      BuildContext context, String train, String estacion) async {
    _isLoading = true;
    notifyListeners();

    try {
      final url = Uri.parse(
          'http://10.10.76.150/TrenSeguroDev/api/getDataTren?idTren=$train&estacion=$estacion');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final dataTren = jsonData['DataTren'];

        if (dataTren == null) {
          _showFlushbar(
              context, 'No se encontraron datos para el tren "$train".');
          return;
        }

        final wrapperData = dataTren['wrapper'];
        if (wrapperData == null) {
          _showFlushbar(context,
              'No se encontraron datos en "wrapper" para el tren "$train".');
          return;
        }

        final String? ID = wrapperData['ID']?.toString();
        if (ID == null || ID.isEmpty) {
          _showFlushbar(context, 'El tren "$train" no tiene un ID válido.');
          return;
        }

        setSelectedID(ID);
        setObservaciones(wrapperData['observaciones'] ?? 'Sin observaciones');
        setMotivosRechazo((wrapperData['motivos_rechazo'] as List<dynamic>?)
                ?.map((m) => m['motivo'].toString())
                .toList() ??
            []);

        notifyListeners();
      } else {
        _showFlushbar(context, 'Error en la solicitud: ${response.statusCode}');
      }
    } catch (e) {
      _showFlushbar(context, 'Ocurrió un error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // FUNCION PARA VER EL CONSIST DEL TREN
  Future<void> consistTren(
      BuildContext context, String train, String estacion) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await http.get(Uri.parse(
          'http://10.10.76.150/TrenSeguroDev/api/getConsist?idTren=$train&estacion=$estacion'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        _infoTrain =
            List<Map<String, dynamic>>.from(jsonData['Consist']['wrapper']);
        _rowsPerPage = _infoTrain.length; // Establece filas por página
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      throw Exception('Failed to load data: $e');
    } finally {
      _isLoading = false;
      notifyListeners(); // Notifica a los widgets que el estado ha cambiado
    }
  }

  void _showFlushbar(BuildContext context, String message) {
    Flushbar(
      duration: const Duration(seconds: 6),
      backgroundColor: Colors.red,
      flushbarPosition: FlushbarPosition.TOP,
      margin: const EdgeInsets.all(1.0),
      borderRadius: BorderRadius.circular(5.0),
      messageText: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white),
      ),
    ).show(context);
  }
}
