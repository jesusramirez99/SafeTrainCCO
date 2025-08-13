import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:safe_train_cco/modelos/historico_validacion_trenes_provider.dart';
import 'package:safe_train_cco/modelos/rechazos_observaciones_data_provider.dart';
import 'package:safe_train_cco/modelos/user_provider.dart';

import 'package:safe_train_cco/modales/motivos_rechazos_obs_id.dart';

class HistorialValidacionesModal extends StatelessWidget {
  final Future<void>? historialFuture;

  const HistorialValidacionesModal({super.key, this.historialFuture});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HistorialValidacionesProvider>(context);
    final trenProvider = Provider.of<TrenYFechaModel>(context, listen: false);
    final tren = trenProvider.trenYFecha;

    final TextEditingController controllertren = TextEditingController();
    final TextEditingController controllerfecha = TextEditingController();

    return FutureBuilder(
      future: historialFuture ?? Future.value(), // Manejar Future null
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.errorMessage != null) {
          return Center(
            child: Text(
              'Error: ${provider.errorMessage}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        final validationHistory = provider.validationHistory;
        bool isScrollable = validationHistory.isNotEmpty;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.9,
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: IntrinsicWidth(
              stepWidth: 100.0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitle(tren ?? 'Sin Tren'),
                    const SizedBox(height: 16.0),
                    _buildSearchBar(context, controllertren, controllerfecha),
                    const SizedBox(height: 22.0),
                    validationHistory.isNotEmpty
                        ? Flexible(
                            child: _buildDataTable(
                                validationHistory, isScrollable, context),
                          )
                        : const Center(
                            child: Text(
                              'No hay datos disponibles',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          ),
                    const SizedBox(height: 20.0),
                    _buildCloseButton(context),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchBar(
      BuildContext context,
      TextEditingController controllerTren,
      TextEditingController controllerFecha) {
    // Función para realizar la búsqueda concatenando los dos campos
    Future<void> performSearch(
        BuildContext context, String trenId, String fecha) async {
      if (trenId.isNotEmpty && fecha.isNotEmpty) {
        final provider = Provider.of<HistorialValidacionesProvider>(
          context,
          listen: false,
        );

        // Concatenar los espacios y la fecha
        String formattedTrenId = trenId;
        int trenIdLength = trenId.length;

        if (trenIdLength == 5) {
          formattedTrenId = '$trenId   '; // 3 espacios
        } else if (trenIdLength == 6) {
          formattedTrenId = '$trenId  '; // 2 espacios
        } else if (trenIdLength == 7) {
          formattedTrenId = '$trenId '; // 1 espacio
        } else if (trenIdLength == 8) {
          formattedTrenId = trenId; // Sin espacios
        }

        final searchQuery = '$formattedTrenId$fecha';

        // Realiza la búsqueda de los datos del tren
        await provider.historialValidaciones(searchQuery);

        // Verifica si la lista de historial de validaciones está vacía o no
        if (provider.validationHistory.isEmpty) {
          _showFlushbar(
              context,
              'El tren $searchQuery no existe, favor de validar',
              Colors.red.shade400);
        }
        return;
      } else {
        _showFlushbar(context, 'Favor de ingresar un tren válido y una fecha',
            Colors.red.shade400);
      }
    }

    return Row(
      children: [
        SizedBox(
          width: 100,
          child: TextFormField(
            controller: controllerTren,
            onChanged: (text) {
              final upperText = text.toUpperCase();
              controllerTren.value = TextEditingValue(
                text: upperText,
                selection: TextSelection.collapsed(offset: upperText.length),
              );
            },
            inputFormatters: [
              LengthLimitingTextInputFormatter(7),
              FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
            ],
            decoration: const InputDecoration(
              labelText: 'ID Tren',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(width: 12.0), // Espacio entre los dos campos

        // TextFormField para Fecha, permite solo 2 caracteres numéricos
        SizedBox(
          width: 70,
          child: TextFormField(
            controller: controllerFecha,
            inputFormatters: [
              LengthLimitingTextInputFormatter(2),
              FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: const InputDecoration(
              labelText: 'Fecha',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            onFieldSubmitted: (value) async {
              final trenId = controllerTren.text.trim();
              final fecha = controllerFecha.text.trim();
              await performSearch(context, trenId, fecha);
            },
          ),
        ),
        const SizedBox(width: 15.0),
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () async {
            final trenId = controllerTren.text.trim();
            final fecha = controllerFecha.text.trim();
            await performSearch(context, trenId, fecha);
          },
        ),
        const SizedBox(width: 12.0),
        IconButton(
          icon: const Icon(Icons.clear, color: Colors.red),
          onPressed: () {
            controllerTren.clear();
            controllerFecha.clear();
          },
        ),
      ],
    );
  }

  Widget _buildTitle(String tren) {
    return const Center(
      child: Text(
        'Historial Validación de Trenes',
        style: TextStyle(
          fontSize: 21.0,
          color: Color.fromARGB(255, 103, 102, 102),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDataTable(List<Map<String, dynamic>> validationHistory,
      bool isScrollable, BuildContext context) {
    return SizedBox(
      height: 400,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            border: TableBorder.all(color: Colors.grey.shade300, width: 1.0),
            columnSpacing: 10.0,
            headingRowColor: MaterialStateProperty.all(Colors.black),
            columns: _buildTableHeaders(context),
            rows: validationHistory
                .map((record) => _buildDataRow(record, context))
                .toList(),
          ),
        ),
      ),
    );
  }

  List<DataColumn> _buildTableHeaders(context) {
    return [
      _buildHeaderColumn('Tren', context),
      _buildHeaderColumn('Estación\nOrigen', context),
      _buildHeaderColumn('Estación\nDestino', context),
      _buildHeaderColumn('Estación\nActual', context),
      _buildHeaderColumn('Total\nCarros', context),
      _buildHeaderColumn('Cargados', context),
      _buildHeaderColumn('Vacíos', context),
      _buildHeaderColumn('Validado', context),
      _buildHeaderColumn('Fecha\nValidado', context),
      _buildHeaderColumn('Ofrecido\nPor', context),
      _buildHeaderColumn('Fecha\nOfrecido', context),
      _buildHeaderColumn('Estatus\nCCO', context),
      _buildHeaderColumn('Fecha\nAutorizado', context),
      _buildHeaderColumn('Llamado\nPor', context),
      _buildHeaderColumn('Fecha\nLlamado', context),
    ];
  }

  DataColumn _buildHeaderColumn(String label, BuildContext context) {
    return DataColumn(
      label: Expanded(
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15.0,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  DataRow _buildDataRow(Map<String, dynamic> record, BuildContext context) {
    final int id = record['ID'];
    final String? validado = record['validado'];
    final String? autorizado = record['autorizado'];

    return DataRow(
      cells: [
        _buildDataCell(record['IdTren'] ?? '', Colors.black, context),
        _buildDataCell(record['origen'] ?? '', Colors.black, context),
        _buildDataCell(record['destino'] ?? '', Colors.black, context),
        _buildDataCell(record['estacion_actual'] ?? '', Colors.black, context),
        _buildDataCell(
            record['carros']?.toString() ?? '', Colors.black, context),
        _buildDataCell(
            record['cargados']?.toString() ?? '', Colors.black, context),
        _buildDataCell(
            record['vacios']?.toString() ?? '', Colors.black, context),

        // 🔥 "Validado" en rojo si es "Rechazado" o "Error de formación"
        _buildDataCell(
            validado ?? '',
            (validado == 'Rechazado' || validado == 'Error de formación')
                ? Colors.red
                : Colors.black,
            context),

        // 🔥 "Fecha Validado" en rojo si "Validado" es "Error de formación"
        _buildDataCell(
            record['fecha_validado'] ?? '',
            validado == 'Error de formación' ? Colors.red : Colors.black,
            context),

        _buildDataCell(record['ofrecido_por'] ?? '', Colors.black, context),
        _buildDataCell(record['fecha_ofrecido'] ?? '', Colors.black, context),

        // 🔥 "Estatus CCO" en rojo solo si es "Rechazado"
        _buildStatusCell(
          autorizado ?? 'Autorizado',
          autorizado == 'Rechazado' ? Colors.red : Colors.black,
          context,
          id,
        ),

        // 🔥 "Fecha Autorizado" en rojo si "Estatus CCO" es "Rechazado"
        _buildDataCell(record['fecha_autorizado'] ?? '',
            autorizado == 'Rechazado' ? Colors.red : Colors.black, context),

        _buildDataCell(record['llamado_por'] ?? '', Colors.black, context),
        _buildDataCell(record['fecha_llamado'] ?? '', Colors.black, context),
      ],
    );
  }

  DataCell _buildStatusCell(
      String text, Color textColor, BuildContext context, int trenId) {
    final idProvider = Provider.of<IdTren>(context, listen: false);
    final rechazosProvider =
        Provider.of<RechazosObservacionesData>(context, listen: false);

    return DataCell(
      MouseRegion(
        cursor: text == 'Rechazado'
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        child: GestureDetector(
          onTap: () async {
            if (text == 'Rechazado') {
              // Guarda el ID correctamente
              idProvider.setSelectedID(trenId.toString());
              print("🔍 ID almacenado en Provider: ${idProvider.idTren}");

              final int? iD = idProvider.idTren;

              if (iD != null) {
                await rechazosProvider.fetchHistorico(iD);

                if (context.mounted) {
                  showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (context) => const RechazoObsTren(),
                  );
                }
              }
              return;
            }
          },
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
                color: textColor,
                decoration:
                    text == 'Rechazado' ? TextDecoration.underline : null,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  DataCell _buildDataCell(String value, Color textColor, BuildContext context) {
    return DataCell(
      Container(
        width: 85.0, // Asignar el ancho específico
        alignment: Alignment.center, // Centrar el contenido
        color: Colors.transparent, // No color de fondo
        child: Text(
          value.contains('T') ? _formatDateTime(value) : value.toString(),
          textAlign: TextAlign.center,
          style: TextStyle(
              color: textColor, fontSize: 15.0, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  String _formatDateTime(String dateTimeString) {
    try {
      // Parseamos la fecha al formato ISO 8601
      final parsedDate = DateTime.parse(dateTimeString);
      // Formateamos la fecha y hora como dd/MM/yyyy HH:mm
      return DateFormat('dd/MM/yyyy \n HH:mm').format(parsedDate);
    } catch (e) {
      // En caso de que falle el formato, devolvemos la cadena original
      return dateTimeString;
    }
  }

  Widget _buildCloseButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        onPressed: () => Navigator.of(context).pop(),
        child: Text(
          'Cerrar',
          style: TextStyle(
              fontSize: 16,
              color: Colors.red.shade400,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _showFlushbar(
      BuildContext context, String message, Color backgroundColor) {
    Flushbar(
      duration: const Duration(seconds: 4),
      backgroundColor: backgroundColor,
      flushbarPosition: FlushbarPosition.TOP,
      margin: const EdgeInsets.all(1.0),
      borderRadius: BorderRadius.circular(5.0),
      messageText: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white),
      ),
    ).show(context); // Agrega esta línea para mostrar el Flushbar
  }

  static Future<void> showHistorialValidacionesModal(
      BuildContext context, Future<void> historialFuture) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return HistorialValidacionesModal(historialFuture: historialFuture);
      },
    );
  }
}
