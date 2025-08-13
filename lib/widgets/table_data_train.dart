import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:safe_train_cco/modales/mostrar_rechazo_obs_trenes.dart';
import 'package:safe_train_cco/modelos/change_notifier_provider.dart';
import 'package:safe_train_cco/modelos/estaciones_provider.dart';
import 'package:safe_train_cco/modelos/tablas_tren_provider.dart';
import 'package:safe_train_cco/modelos/user_provider.dart';

class DataTrainTable extends StatefulWidget {
  final List<Map<String, dynamic>> data;
  final bool isLoading;
  final String selectedTrain;
  final VoidCallback toggleTableData;

  const DataTrainTable({
    super.key,
    required this.selectedTrain,
    required this.toggleTableData,
    required this.data,
    required this.isLoading,
  });

  @override
  State<DataTrainTable> createState() => _DataTrainTableState();
}

class _DataTrainTableState extends State<DataTrainTable> {
  int? _selectedRowIndex = -1;
  String? _selectedTrainId;

  @override
  void initState() {
    super.initState();
    _selectedRowIndex = -1;
    _selectedTrainId = null;
  }

  @override
  Widget build(BuildContext context) {
    final selectionNotifier = Provider.of<SelectionNotifier>(context);
    final provider = Provider.of<TablesTrainsProvider>(context);

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      height: MediaQuery.of(context).size.height * 0.7,
      child: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Center(
                    child: Text(
                      'Datos del Tren',
                      style: TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
                ),
                DataTable(
                  columnSpacing: 10.0,
                  dataRowHeight: 50.0,
                  decoration: _cabeceraTabla(),
                  columns: _buildColumns(),
                  rows: provider.trainData != null
                      ? [
                          DataRow(
                            selected: _selectedRowIndex == 0,
                            onSelectChanged: (isSelected) {
                              setState(() {
                                if (isSelected != null && isSelected) {
                                  _selectedRowIndex = 0;

                                  print(
                                      'Fila seleccionada: $_selectedRowIndex');

                                  if (provider.trainData != null) {
                                    final estatusCCOProvider =
                                        Provider.of<EstatusCCOProvider>(context,
                                            listen: false);

                                    // 🔥 Restablece el estatus antes de asignar uno nuevo
                                    estatusCCOProvider.limpiarEstatus();

                                    // Verifica que trainData.autorizado tenga un valor antes de actualizar
                                    String nuevoEstatus =
                                        provider.trainData!.autorizado ?? '';

                                    // Si el estatus es "Rechazado", actualiza en el provider
                                    if (nuevoEstatus.isNotEmpty) {
                                      estatusCCOProvider
                                          .updateEstatusCCO(nuevoEstatus);
                                      setState(() {});
                                      print(
                                          'Estatus CCO actualizado a: $nuevoEstatus');
                                    } else {
                                      print(
                                          'Estatus CCO vacío, no se actualiza.');
                                    }

                                    final trainProvider =
                                        Provider.of<TrenYFechaModel>(context,
                                            listen: false);
                                    final idTrenProvider = Provider.of<IdTren>(
                                        context,
                                        listen: false);
                                    final train = provider.trainData!.idTren;
                                    final idTrain = provider.trainData!.id;

                                    _selectedTrainId = train;
                                    String? idTren = idTrain.toString();

                                    if (train != null && train.isNotEmpty) {
                                      trainProvider.setTrenYFecha(train);
                                      idTrenProvider.setId(idTrain);
                                      print('TREN: $train');
                                      print(
                                          'ID almacenado en Provider: ${idTrenProvider.idTren}');
                                    } else {
                                      print(
                                          'Error: El tren no tiene un ID válido');
                                    }

                                    final estacionProvider =
                                        Provider.of<EstacionesProvider>(context,
                                            listen: false);
                                    final estacionActual =
                                        provider.trainData!.estacionActual;

                                    if (estacionActual != null &&
                                        estacionActual.isNotEmpty) {
                                      estacionProvider.updateSelectedEstacion(
                                          estacionActual);
                                      print(
                                          'Estación seleccionada: $estacionActual');
                                    } else {
                                      print(
                                          'Error: La estación no tiene un valor válido');
                                    }

                                    selectionNotifier.updateSelectedRow(0);
                                  } else {
                                    print('Error: provider.trainData es null');
                                  }
                                } else {
                                  _selectedRowIndex = -1;
                                  selectionNotifier.updateSelectedRow(null);
                                }
                              });
                            },
                            color: MaterialStateColor.resolveWith(
                              (Set<MaterialState> states) {
                                return _selectedRowIndex == 0
                                    ? Colors.lightBlue.shade50
                                    : Colors.white;
                              },
                            ),
                            cells: _buildCells(context),
                          ),
                        ]
                      : [],
                  border: TableBorder(
                    horizontalInside:
                        BorderSide(color: Colors.grey.shade400, width: 1),
                    verticalInside:
                        BorderSide(color: Colors.grey.shade400, width: 1),
                  ),
                )
              ],
            ),
    );
  }

  List<DataColumn> _buildColumns() {
    return [
      DataColumn(label: _buildHeaderCell('Tren')),
      DataColumn(label: _buildHeaderCell('Estación\nOrigen')),
      DataColumn(label: _buildHeaderCell('Estación\nDestino')),
      DataColumn(label: _buildHeaderCell('Estación\nActual')),
      DataColumn(label: _buildHeaderCell('Total\nCarros')),
      DataColumn(label: _buildHeaderCell('Cargados')),
      DataColumn(label: _buildHeaderCell('Vacíos')),
      DataColumn(label: _buildHeaderCell('Validado')),
      DataColumn(label: _buildHeaderCell('Fecha\nValidado')),
      DataColumn(label: _buildHeaderCell('Ofrecido\npor')),
      DataColumn(label: _buildHeaderCell('Fecha\nOfrecido')),
      DataColumn(label: _buildHeaderCell('Estatus\nCCO')),
      DataColumn(label: _buildHeaderCell('Fecha\nAutorizado / Rechazado')),
      DataColumn(label: _buildHeaderCell('Autorizado')),
      DataColumn(label: _buildHeaderCell('Fecha Envío\n de Llamado')),
      DataColumn(label: _buildHeaderCell('Fecha\nLlamado')),
      DataColumn(label: _buildHeaderCell('Llamada\nCompletada'))
    ];
  }

  List<DataCell> _buildCells(BuildContext context) {
    final provider = Provider.of<TablesTrainsProvider>(context);
    final train = provider.trainData;

    if (train == null) {
      return [const DataCell(Text("No hay datos disponibles"))];
    }

    // FORMATEO DE LA FECHA
    Widget formattedDateCell({
      required String date,
      String format = 'dd/MM/yyyy \n HH:mm',
      Color textColor = Colors.black,
    }) {
      if (date.isEmpty) {
        return const Text('');
      }

      try {
        // Parsear la fecha y formatearla
        DateTime dateTime = DateTime.parse(date);
        String formattedDate = DateFormat(format).format(dateTime);

        return Center(
          child: Text(
            formattedDate,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        );
      } catch (e) {
        return Center(
          child: Text(
            date,
            style: const TextStyle(color: Colors.red),
          ),
        );
      }
    }

    return [
      _buildCell(train.idTren, Colors.black),
      _buildCell(train.origen, Colors.black),
      _buildCell(train.destino, Colors.black),
      _buildCell(train.estacionActual, Colors.black),
      _buildCell(train.carros.toString(), Colors.black),
      _buildCell(train.cargados.toString(), Colors.black),
      _buildCell(train.vacios.toString(), Colors.black),

      // Validado
      _buildCell(train.validado ?? '',
          train.validado == 'Sin Errores' ? Colors.green : Colors.red),

      // Fecha Validado
      DataCell(
        Center(
          child: formattedDateCell(
            date: train.fechaValidado,
            format: 'dd/MM/yyyy \n HH:mm',
          ),
        ),
      ),

      // Ofrecido Por
      _buildCell(train.ofrecidoPor, Colors.black),

      //Fecha Ofrecido
      DataCell(
        formattedDateCell(
          date: train.fechaOfrecido,
          format: 'dd/MM/yyyy \n HH:mm',
        ),
      ),

      // Estatus CCO - Autorizado / Rechazado
      _buildStatusCell(
        train.autorizado ?? 'Autorizado',
        train.autorizado == 'Autorizado' ? Colors.green : Colors.red,
        context,
      ),

      // Fecha Autorizado / Rechazado
      DataCell(
        formattedDateCell(
          date: train.fechaAutorizadoRechazado,
          format: 'dd/MM/yyyy \n HH:mm',
          textColor:
              train.autorizado == 'Autorizado' ? Colors.green : Colors.red,
        ),
      ),

      // Autorzado
      _buildCell(train.autorizado == 'Rechazado' ? '' : train.llamadoPor ?? '',
          Colors.black),

      // Fecha Envio de Llamado
      DataCell(
        formattedDateCell(
          date: train.autorizado == 'Rechazado'
              ? ''
              : train.fechaEnvioLlamado ?? '',
          format: 'dd/MM/yyyy \n HH:mm',
        ),
      ),

      // Fecha Llamado
      DataCell(
        formattedDateCell(
          date: train.autorizado == 'Rechazado' ? '' : train.fechaLlamado ?? '',
          format: 'dd/MM/yyyy \n HH:mm',
        ),
      ),

      // Fecha llamada completada
      DataCell(
        formattedDateCell(
          date: '',
          format: 'dd/MM/yyyy \n HH:mm:ss',
        ),
      ),

      /*
      DataCell(
        formattedDateCell(
          date: train.fechaLlamado,
          format: 'dd/MM/yyyy \n HH:mm:ss',
        ),
      ),
      */
    ];
  }

  DataCell _buildStatusCell(
      String text, Color textColor, BuildContext context) {
    final trenProvider = Provider.of<TrenYFechaModel>(context, listen: false);
    final tablesProvider =
        Provider.of<TablesTrainsProvider>(context, listen: false);
    final String tren = trenProvider.trenYFecha ?? '';

    final estacionProvider =
        Provider.of<EstacionesProvider>(context, listen: false);
    final String estacion = estacionProvider.selectedEstacion ?? '';

    return DataCell(
      MouseRegion(
        cursor: text == 'Rechazado'
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        child: GestureDetector(
          onTap: () async {
            if (text == 'Rechazado') {
              if (tren.isEmpty || estacion.isEmpty) {
                print('⚠️ Favor de seleccionar la fila del tren.');
                _showFlushbar(context, 'Favor de seleccionar la fila del tren.',
                    Colors.red);
                return; // Detiene la ejecución
              }
              await tablesProvider.refreshTableDataTrain(
                  context, tren, estacion);
              if (context.mounted) {
                showDialog(
                  context: context,
                  builder: (context) => const MostrarRechazoObsTrenes(),
                );
              }
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

  DataCell _buildCell(String text, Color textColor) {
    return DataCell(
      Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 15.0,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String text) {
    return Expanded(
      child: Center(
        child: Text(
          text,
          style: _styleText(),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  BoxDecoration _cabeceraTabla() {
    return BoxDecoration(
      border: Border(
        left: BorderSide(color: Colors.grey.shade400),
        right: BorderSide(color: Colors.grey.shade400),
        top: BorderSide(color: Colors.grey.shade400),
        bottom: BorderSide(color: Colors.grey.shade400),
      ),
      color: Colors.black,
    );
  }

  TextStyle _styleText() {
    return const TextStyle(
      color: Colors.white,
      fontSize: 15.0,
      fontWeight: FontWeight.bold,
    );
  }

  void _showFlushbar(BuildContext context, String message, Color color) {
    Flushbar(
      duration: const Duration(seconds: 6),
      backgroundColor: color,
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
