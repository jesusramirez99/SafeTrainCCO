import 'dart:async';

import 'package:another_flushbar/flushbar.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
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
  String _filterStation = "";
  late final ScrollController _horizontalScrollController;
  Timer? _timer;
  
  @override
  void initState() {
    super.initState();
    _horizontalScrollController = ScrollController();
    final providerDataTrain = Provider.of<TablesTrainsProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.userName ?? '';
    _selectedRowIndex = -1;
    _selectedTrainId = null;
    providerDataTrain.tableTrainsOffered(context, user);
    _timer = Timer.periodic(const Duration(minutes: 2), (_) {
      providerDataTrain.tableTrainsOffered(context, user);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 1800;
    final provider = Provider.of<TablesTrainsProvider>(context);

    return SizedBox(
      width: isLargeScreen? MediaQuery.of(context).size.width * 0.8 : MediaQuery.of(context).size.width * 0.8,
      height: isLargeScreen? MediaQuery.of(context).size.height * 0.7 : MediaQuery.of(context).size.height * 0.6,
      child: provider.isLoading? const Center(child: CircularProgressIndicator()) : provider.trainDataInfo? _buildTableDataTrain() : _buildTableStatusTrainsOffered()
    );
  }

  Widget _buildTableDataTrain(){
    final isLaptop = ResponsiveBreakpoints.of(context).equals('LAPTOP');
    final selectionNotifier = Provider.of<SelectionNotifier>(context);
    final provider = Provider.of<TablesTrainsProvider>(context);
    final trainData = provider.trainData;

    return ListView(
        children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Datos del Tren: ${trainData?.idTren ?? ''}',
                          style: TextStyle(
                            fontSize: isLaptop? 18.0 : 22.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(width: 100),
                        Text(
                          'Estación Origen: ${trainData?.origen ?? ''}',
                          style: TextStyle(
                            fontSize: isLaptop? 18.0 : 22.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(width: 100),
                        Text(
                          'Estación Destino: ${trainData?.destino ?? ''}',
                          style: TextStyle(
                            fontSize: isLaptop? 18.0 : 22.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                
              isLaptop ?

              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 1000,
                  ),
                  child: ScrollbarTheme(
                    data: ScrollbarThemeData( 
                      thumbColor: WidgetStateProperty.all<Color>(Colors.grey), // color del pulgar
                      trackColor: WidgetStateProperty.all<Color>(Colors.grey.shade300), // fondo del track
                      trackBorderColor: WidgetStateProperty.all<Color>(Colors.grey.shade400), // borde del track
                      radius: const Radius.circular(8), // borde redondeado del thumb
                      thickness: WidgetStateProperty.all<double>(8.0), // grosor del thumb
                    ), 
                      child: Scrollbar(
                        thumbVisibility: true,
                        trackVisibility: true,
                        controller: _horizontalScrollController,
                        child: SingleChildScrollView(
                          controller: _horizontalScrollController,
                          scrollDirection: Axis.horizontal,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: DataTable(
                              columnSpacing: 10.0,
                              dataRowHeight: 75.0,
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
                            ),
                          ),
                        )
                      )
                  ),
                ),
              )

               :

               DataTable(
                    columnSpacing: 10.0,
                    dataRowHeight: 73.0,
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
                  ),
                
              ]
    );
  }

  List<DataColumn> _buildColumns() {
    return [
      //DataColumn(label: _buildHeaderCell('Tren')),
      //DataColumn(label: _buildHeaderCell('Estación\nOrigen')),
      //DataColumn(label: _buildHeaderCell('Estación\nDestino')),
      DataColumn(label: _buildHeaderCell('Tren/Estación\nActual')),
      DataColumn(label: _buildHeaderCell('Carros')),
      //DataColumn(label: _buildHeaderCell('Cargados')),
      //DataColumn(label: _buildHeaderCell('Vacíos')),
      DataColumn(label: _buildHeaderCell('Validado')),
      DataColumn(label: _buildHeaderCell('Fecha\nValidado')),
      //DataColumn(label: _buildHeaderCell('Ofrecido\npor')),
      DataColumn(label: _buildHeaderCell('Fecha\nOfrecido')),
      DataColumn(label: _buildHeaderCell('Estatus\nCCO')),
      DataColumn(label: _buildHeaderCell('Fecha CCO\nAutorizado / Rechazado')),
      //DataColumn(label: _buildHeaderCell('Autorizado')),
      DataColumn(label: _buildHeaderCell('Fecha Envío\n de Llamado')),
      DataColumn(label: _buildHeaderCell('Fecha\nLlamado')),
      DataColumn(label: _buildHeaderCell('Registro de \nSalida'))
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
            textAlign: TextAlign.center,
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
      //_buildCell(train.idTren, Colors.black),
      //_buildCell(train.origen, Colors.black),
      //_buildCell(train.destino, Colors.black),
      _buildCell(train.estacionActual, Colors.black),
      _buildCell(
        '${'Cargados'.padRight(20)}${(train.cargados ?? '').toString().padLeft(5)}\n'
        '${'Vacios'.padRight(20)}${(train.vacios ?? '').toString().padLeft(8)}\n'
        '${'Total'.padRight(20)}${(train.carros ?? '').toString().padLeft(10)}\n',
        Colors.black,
      ),

      // Validado
      _buildCell(train.validado ?? '',
          train.validado == 'Sin Errores' ? Colors.green : Colors.red),

      // Fecha Validado
      _buildCellDateString(
        text: train.validado_por.toString() ?? '', 
        widget: formattedDateCell(
          date: train.fechaValidado.toString() ?? '',
          format: 'dd/MM/yyyy \n HH:mm',
        ),
      ),

      //Fecha Ofrecido
      _buildCellDateStringObservations(
        messageObservations: train.observ_ofrecimiento ?? '',
        context: context,
        text: train.ofrecidoPor.toString() ?? '', 
        widget: formattedDateCell(
          date: train.fechaOfrecido.toString() ?? '',
          format: 'dd/MM/yyyy \n HH:mm',
        ),
      ),

      // Estatus CCO - Autorizado / Rechazado
      _buildStatusCell(
        train.autorizado ?? 'Autorizado',
        train.autorizado == 'Autorizado' ? Colors.green : Colors.red,
        context,
        train.idTren,
        train.estacionActual,
        train.observ_autorizado
      ),

      //Fecha CCO - Autorizado / Rechazado
      _buildCellDateString(
        text: train.autorizadorPor.toString() ?? '', 
        widget: formattedDateCell(
          date: train.fechaAutorizadoRechazado.toString() ?? '',
          format: 'dd/MM/yyyy \n HH:mm',
        )
      ),

      // Fecha Envio de Llamado
      _buildCellDateString(
        text: train.llamadoPor.toString() ?? '',
        widget: formattedDateCell(
          date: train.autorizado == 'Rechazado'
              ? ''
              : train.fechaAutorizadoRechazado.toString() ?? '',
          format: 'dd/MM/yyyy \n HH:mm',
        ),
      ),

      // Fecha Llamado
      _buildCellDateString(
        text: train.llamadoPor.toString() ?? '',
        widget: formattedDateCell(
          date: train.autorizado == 'Rechazado' ? '' : train.fechaLlamado ?? '',
          format: 'dd/MM/yyyy \n HH:mm',
        ),
      ),

      // Fecha llamada completada
      _buildCellDateString(
        text: '', 
        widget: formattedDateCell(
          date: '',
          format: 'dd/MM/yyyy \n HH:mm',
        )
      ),
    ];
  }


  Widget _buildTableStatusTrainsOffered() {
  final isLaptop = ResponsiveBreakpoints.of(context).equals('LAPTOP');
  final providerDataTrain = Provider.of<TablesTrainsProvider>(context);
  final filteredTrains = _filterStation.isEmpty
      ? providerDataTrain.dataTrainsOffered
      : providerDataTrain.dataTrainsOffered
          .where((train) => train['estacion_actual']
              .toString()
              .toLowerCase()
              .contains(_filterStation.toLowerCase()))
          .toList();


  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // ── Título ──
      Padding(
        padding: const EdgeInsets.all(12.0),
        child: Center(
          child: Text(
            'Estatus Trenes Ofrecidos',
            style: TextStyle(
              fontSize: isLaptop? 18.0 : 22.0,
              color: Colors.black,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ),
      // ── Filtro ──
      Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        child: Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: isLaptop? 190.0 : 230.0,
             // mismo ancho que la primera columna de la tabla
            child: TextField(
              style: TextStyle(
                fontSize: isLaptop? 14.0 : 16.0,
              ),
              decoration: InputDecoration(
                labelText: "Buscar estación",
                labelStyle: TextStyle(fontSize: isLaptop? 14.0 : 16.0),
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: isLaptop? 5 : 8, vertical: isLaptop? 5 : 8),
              ),
              onChanged: (value) {
                setState(() {
                  _filterStation = value;
                });
              },
            ),
          ),
        ),
      ),

      LayoutBuilder(
        builder: (context, constraints) {
          const double rowHeight = 70;
          double screenHeight = MediaQuery.of(context).size.height;
          double reserveSpace = 341;
          double maxHeight = isLaptop ? screenHeight - reserveSpace : 800 ;
          const double headingHeight = 48;
          //double maxHeight =  isLaptop? 238 : 800;
          final tableHeight = (filteredTrains.length * rowHeight + headingHeight).clamp(0, maxHeight);
          
          return SizedBox(
            height: tableHeight.toDouble(),
            child: DataTable2(
              headingRowHeight: headingHeight,
              dataRowHeight: rowHeight,
              horizontalMargin: 8,
              columnSpacing: 12,
              minWidth: 1530,
              border: TableBorder(
                horizontalInside: BorderSide(color: Colors.grey.shade400, width: 1),
                verticalInside: BorderSide(color: Colors.grey.shade400, width: 1),
              ),
              decoration: _cabeceraTabla(),
              columns: _buildColumnsTrainStatusTrainsOffered(),
              rows: filteredTrains.map((train) => DataRow(
                color: MaterialStateColor.resolveWith((states) =>
                    states.contains(MaterialState.selected)
                        ? const Color.fromARGB(255, 226, 237, 247)
                        : (filteredTrains.indexOf(train) % 2 == 0 ? Colors.white : Colors.grey.shade100)
                ),
                cells: _buildCellsTrainStatusTrainsOffered(train),
              )).toList(),
            ),
          );
        },
      ),
    ],
  );
}

  List<DataColumn> _buildColumnsTrainStatusTrainsOffered(){
    return [
      DataColumn2(label: _buildHeaderCell('Tren'), size: ColumnSize.S),
      DataColumn2(label: _buildHeaderCell('Estacion\nActual'), size: ColumnSize.S),
      DataColumn2(label: _buildHeaderCell('Carros'), size: ColumnSize.S),
      DataColumn2(label: _buildHeaderCell('Validado'), size: ColumnSize.S),
      DataColumn2(label: _buildHeaderCell('Fecha\nValidado'), size: ColumnSize.S),
      DataColumn2(label: _buildHeaderCell('Fecha\nOfrecido'), size: ColumnSize.S),
      DataColumn2(label: _buildHeaderCell('Estatus\nCCO'), size: ColumnSize.S),
      DataColumn2(label: _buildHeaderCell('Fecha CCO\nAutorizado / Rechazado'), size: ColumnSize.S),
      DataColumn2(label: _buildHeaderCell('Fecha Envío\n de Llamado'), size: ColumnSize.S),
      DataColumn2(label: _buildHeaderCell('Fecha\nLlamado'), size: ColumnSize.S),
      DataColumn2(label: _buildHeaderCell('Registro de \nSalida'), size: ColumnSize.S)
    ];
  }

  List<DataCell> _buildCellsTrainStatusTrainsOffered(Map<String, dynamic> data){
    Provider.of<TablesTrainsProvider>(context);
    //Provider.of<TrainModel>(context, listen: false);

   // FORMATEO DE LA FECHA
    Widget formattedDateCellTrainsOffered({
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
            textAlign: TextAlign.center,
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
      _buildCell(data['IdTren']?.toString() ?? '', Colors.black),
      _buildCell(data['estacion_actual']?.toString() ?? '', Colors.black),
      _buildCell(
        '${'Cargados'.padRight(20)}${(data['cargados'] ?? '').toString().padLeft(5)}\n'
        '${'Vacios'.padRight(20)}${(data['vacios'] ?? '').toString().padLeft(8)}\n'
        '${'Total'.padRight(20)}${(data['carros'] ?? '').toString().padLeft(10)}\n',
        Colors.black,
      ),

      // Validado
      _buildValidatedCell(
          data['validado']?.toString() ?? '',
          data['autorizado']?.toString() ?? '',
          data['ofrecido_por']?.toString() ?? ''),

    
      // Fecha Vaidado
      _buildCellDateString(
        text: data['validado_por']?.toString() ?? '',
        widget: formattedDateCellTrainsOffered(
          date: data['fecha_validado']?.toString() ?? '',
          format: 'dd/MM/yyyy \nHH:mm',
        ),
      ),

      /*DataCell(
        formattedDateCell(
          date: data['fecha_validado']?.toString() ?? '',
          format: 'dd/MM/yyyy \n HH:mm',
        ),
      ),*/

      // Fecha Ofrecido
      _buildCellDateStringObservations(
        messageObservations: data['observ_ofrecimiento'] ?? '',
        context: context,
        text: data['ofrecido_por']?.toString() ?? '', 
        widget: data['ofrecido_por'] == ''
              ? const SizedBox() // Celda vacía si no hay nada en la celda
              : formattedDateCellTrainsOffered(
                  date: data['fecha_ofrecido']?.toString() ?? '',
                  format: 'dd/MM/yyyy \n HH:mm',
                ),
      ),
      // Estatus CCO - Autorizado / Rechazado
      _buildStatusCell(
        data['autorizado']?.toString() ?? 'Autorizado',
        data['autorizado'] == 'Autorizado' ? Colors.green : Colors.red,
        context,
        data['IdTren'],
        data['estacion_actual'],
        data['observ_autorizado'].toString(),
      ),

      // Fecha Autorizado / Rechazado
      _buildCellDateString(
        text: data['autorizado_por']?.toString() ?? '', 
        widget: formattedDateCellTrainsOffered(
          date: data['fecha_autorizado']?.toString() ?? '',
          format: 'dd/MM/yyyy \n HH:mm',
        ),
      ),

   
      
      // Fecha Envio de Llamado
      _buildCellDateString(
        text: data['llamado_por']?.toString() ?? '', 
        widget: data['autorizado'] == 'Rechazado'
              ? const SizedBox()
              : formattedDateCellTrainsOffered(
                  date: data['fecha_autorizado']?.toString() ?? '',
                  format: 'dd/MM/yyyy \n HH:mm',
                ),
      ),

      // Fecha Llamado
      _buildCellDateString(
        text: data['llamado_por']?.toString() ?? '', 
        widget: data['autorizado'] == 'Rechazado'
              ? const SizedBox()
              : formattedDateCellTrainsOffered(
                  date: data['fecha_llamado']?.toString() ?? '',
                  format: 'dd/MM/yyyy \n HH:mm',
                ),
      ),

      // Fecha llamada completada
      _buildCellDateString(
        text: '', 
        widget: formattedDateCellTrainsOffered(
          date: '',
          format: 'dd/MM/yyyy \n HH:mm',
        ),
      ),
    ];    
  }

  DataCell _buildValidatedCell(
      String text, String autorizado, String ofrecidoPor) {
    Color textColor;

    if (text == "Sin Errores") {
      textColor = Colors.green;
    } else if (text == "Error de formación") {
      textColor = Colors.red;
    } else {
      textColor = Colors.black;
    }

    return DataCell(
      GestureDetector(
        onTap: (text == "Sin Errores" &&
                autorizado != "Autorizado" &&
                autorizado != "Rechazado")
            ? () {
                if (ofrecidoPor.isEmpty) {
                  /*_showConfirmationDialog(
                      context); */// Muestra el modal si ofrecidoPor está vacío
                }
              }
            : null, // Si está autorizado o rechazado, no hay acción
        child: Center(
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
      ),
    );
  }

  DataCell _buildCellDateString({
    required String text,
    required Widget widget,
    Color textColor = Colors.black,
  }) {
    return DataCell(
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            widget, 
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                    color: textColor,                  
                  ),
                  textAlign: TextAlign.center,
                ),
          ],
        ),
      ),
    );
  }

  DataCell _buildCellDateStringObservations({
    required String messageObservations,
    required String text,
    required Widget widget,
    Color textColor = Colors.blueAccent,
    required BuildContext context,
    
  }) {
    return DataCell(
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            widget,
            MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      Offset offset = const Offset(0, 0);
                      return StatefulBuilder(
                        builder: (context, setState){
                          return Center(
                            child: GestureDetector(
                              onPanUpdate: (details) {
                                setState(() {
                                  offset += details.delta;
                                });
                              },
                              child: Transform.translate(
                                offset: offset,
                                child: Material(
                                  color: Colors.transparent,
                                  child: AlertDialog(
                                    title: const Text("Observaciones"),
                                    content: Text(
                                      messageObservations.isEmpty
                                          ? 'Sin Observaciones'
                                          : messageObservations,
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text("Cerrar"),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                      );
                    }
                  );
                },
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.blueAccent,
                    decorationThickness: 2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  DataCell _buildStatusCell(String text, Color textColor, BuildContext context, String idTren, String estacion, [String? messageObservations]) {
    //print('tren: $idTren, estacion: $estacionAct');
    //final trenProvider = Provider.of<TrenYFechaModel>(context, listen: false);
    final tablesProvider = Provider.of<TablesTrainsProvider>(context, listen: false);
    //final String tren = trenProvider.trenYFecha ?? '';
    /*final estacionProvider =
        Provider.of<EstacionesProvider>(context, listen: false);
    final String estacion = estacionProvider.selectedEstacion ?? '';*/
    //print('Datos del tren....tren: $idTren, estacion: $estacion');

    return DataCell(
      MouseRegion(
        cursor: (text == 'Rechazado' || text == 'Autorizado')
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        child: GestureDetector(
          onTap: () async {
            if ((text == 'Rechazado' && (idTren.isNotEmpty && estacion.isNotEmpty))) {
              final hasInfo = await tablesProvider.refreshTableDataTrain(context, idTren, estacion);
              if(!hasInfo)return;

              if (context.mounted) {
                showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (context){
                    Offset offset = const Offset(0, 0);
                    return StatefulBuilder(
                      builder: (context, setState) {
                        return Center(
                          child: GestureDetector(
                            onPanUpdate: (details) {
                              setState(() {
                                offset += details.delta;
                              });
                            },
                            child: Transform.translate(
                              offset: offset,
                              child: const Material(
                                color: Colors.transparent,
                                child: MostrarRechazoObsTrenes(),
                              ),
                            ),
                          ),
                        );
                      }
                    );
                  }
                );
              }
            } else if(text == 'Autorizado'){
              if (context.mounted) {
                showDialog(
                  context: context,
                  builder: (context) {
                    Offset offset = Offset.zero; // posición inicial
                    return StatefulBuilder(
                      builder: (context, setState) {
                        //Offset offset = Offset.zero; // posición inicial

                        return Center(
                          child: GestureDetector(
                            onPanUpdate: (details) {
                              setState(() {
                                offset += details.delta; // actualizar posición
                              });
                            },
                            child: Transform.translate(
                              offset: offset,
                              child: Material(
                                color: Colors.transparent,
                                child: AlertDialog(
                                  title: const Text("Observaciones"),
                                  content: Text(
                                    messageObservations == null || messageObservations.isEmpty
                                        ? 'Sin observaciones'
                                        : messageObservations,
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text("Cerrar"),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
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
                decorationColor: 
                    text == 'Rechazado' ? Colors.red : null,
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
            fontFamily: 'RobotoMono',
          ),
          textAlign: TextAlign.left,
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
