import 'dart:html' as html;
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class ExcelDownloadProvider extends ChangeNotifier {
  bool _isDownloading = false;
  String _errorMessage = '';

  bool get isDownloading => _isDownloading;
  String get errorMessage => _errorMessage;

  Future<void> descargarExcel(String idTren, String estacion) async {
    _isDownloading = true;
    _errorMessage = '';
    notifyListeners();

    final url =
        'http://10.10.76.150/TrenSeguroDev/api/DescargarExcel?idTren=$idTren&estacion=$estacion';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        Uint8List bytes = response.bodyBytes;
        final blob = html.Blob([bytes]);
        final urlObject = html.Url.createObjectUrlFromBlob(blob);

        final anchor = html.AnchorElement(href: urlObject)
          ..setAttribute("download", "consist: $idTren.xlsx")
          ..click(); // Simular clic para descargar

        html.Url.revokeObjectUrl(urlObject);
      } else {
        _errorMessage = 'Error al descargar el archivo: ${response.statusCode}';
        print(_errorMessage);
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      print(_errorMessage);
    } finally {
      _isDownloading = false;
      notifyListeners();
    }
  }
}
