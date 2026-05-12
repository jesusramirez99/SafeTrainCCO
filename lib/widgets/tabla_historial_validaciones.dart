import 'package:another_flushbar/flushbar.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:safe_train_cco/modales/motivos_rechazos_obs_id.dart';
import 'package:safe_train_cco/modelos/estaciones_provider.dart';
import 'package:safe_train_cco/modelos/historico_validacion_trenes_provider.dart';
import 'package:safe_train_cco/modelos/rechazos_observaciones_data_provider.dart';
import 'package:safe_train_cco/modelos/user_provider.dart';
import 'package:safe_train_cco/widgets/HoverTrainTextHistory.dart';
import 'package:safe_train_cco/widgets/custom_date.dart';
enum FilterType {none, day, range}

class HistorialValidacionesModal extends StatefulWidget {
  final Future<void>? historialFuture;

  const HistorialValidacionesModal({super.key, this.historialFuture});

  @override
  State<HistorialValidacionesModal> createState() => _HistorialValidacionesModalState();

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

class _HistorialValidacionesModalState extends State<HistorialValidacionesModal> {
  Offset _offset = Offset.zero;
  final rangeController  = CustomDatePickerController();
  final TextEditingController controllertren = TextEditingController();
  final TextEditingController controllerestacion = TextEditingController();
  final ValueNotifier<FilterType> selectedFilter = ValueNotifier(FilterType.none);
  final selectedDay = ValueNotifier<String?>(null);
  final List<String> items = ['01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24','25','26','27','28','29','30','31'];

  @override
  void dispose() {
    controllertren.dispose();
    controllerestacion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HistorialValidacionesProvider>(context);
    final trenProvider = Provider.of<TrenYFechaModel>(context, listen: false);
    final tren = trenProvider.trenYFecha;

    return FutureBuilder(
      future: widget.historialFuture ?? Future.value(), // Manejar Future null
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
        print('validacion: $validationHistory.isEmpty');

        final validationHistoryTrain = provider.validationHistoryTrain;
        bool isScrollableTrain = validationHistoryTrain.isNotEmpty;

        final informationHistoryTrain = provider.infoHistoryTrain;
        bool isScrollableInfoTrain = informationHistoryTrain.isNotEmpty;

        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(color: Colors.black45),
              )
            ),

            Transform.translate(
              offset: _offset,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    _offset += details.delta;
                  });
                },
                child: Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Container(
                    constraints: const BoxConstraints(
                      maxWidth: 1405,//MediaQuery.of(context).size.width * 0.9,
                      maxHeight: 800,//MediaQuery.of(context).size.height * 0.8,
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
                            _buildSearchBar(context, controllertren, controllerestacion, rangeController, selectedDay),
                            const SizedBox(height: 22.0),
                            
                            if (provider.isLoading)
                              const Center(
                                child: CircularProgressIndicator(),
                              )
                            else if (provider.isFilter)
                              validationHistoryTrain.isEmpty
                                  ? emptyMessage
                                  : Flexible(
                                      child: _buildDataTableFilter(
                                        validationHistoryTrain,
                                        isScrollableTrain,
                                        context,
                                      ),
                                    )
                            else if (provider.isConsulting)
                              informationHistoryTrain.isEmpty
                              ? emptyMessage
                              : Flexible(
                                child: _buildDataTable(
                                  informationHistoryTrain, 
                                  isScrollableInfoTrain, 
                                  context,
                                ),
                              )
                            else
                              validationHistory.isEmpty
                                  ? emptyMessage
                                  : Flexible(
                                      child: _buildDataTable(
                                        validationHistory,
                                        isScrollable,
                                        context,
                                      ),
                                    ),

                            const SizedBox(height: 20.0),
                            _buildCloseButton(context),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget emptyMessage = const Center(
    child: Text(
      'No hay datos disponibles',
      style: TextStyle(fontSize: 16, color: Colors.grey),
    ),
  );

  Widget _buildSearchBar(
      BuildContext context,
      TextEditingController controllerTren,
      TextEditingController controllerestacion,
      CustomDatePickerController rangeController,
      ValueNotifier<String?> selectedDay) {
      final trainProvider = Provider.of<TrenYFechaModel>(context, listen: false);
      final trainId = trainProvider.trenYFecha;
      final provider = Provider.of<HistorialValidacionesProvider>(context, listen: false);
      final estacionesNombres = Provider.of<EstacionesProvider>(context).estaciones
        .map<String>((s) => s['id_estacion'] as String)
        .toList();
    // Función para realizar la búsqueda concatenando los dos campos
    Future<void> performSearch(BuildContext context) async {

      final trenId = controllerTren.text.trim();
      final estacion = controllerestacion.text.trim();
      String selectedDropdown = '';
      String start = '';
      String end = '';

      if (selectedFilter.value == FilterType.day) {
        selectedDropdown = selectedDay.value ?? '';
      }
      /// rango
      if (selectedFilter.value == FilterType.range && rangeController.range != null) {
        start = DateFormat('yyyy/MM/dd').format(rangeController.range!.start);
        end = DateFormat('yyyy/MM/dd').format(rangeController.range!.end);
      }
      final hasRangeDate = start.isNotEmpty && end.isNotEmpty;
      if(trenId.isEmpty && estacion.isEmpty && !hasRangeDate && selectedDropdown.isEmpty){
        _showFlushbar(context, 'Favor de ingresar datos para la busqueda', Colors.red.shade400, );
        return;
      }

      if(trenId.isEmpty){
        _showFlushbar(
          context, 
          'Favor de ingresar el ID Tren para la busqueda', 
          Colors.red.shade400,
        );
        return;
      }

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

      final trenID = '$formattedTrenId$selectedDropdown';
      await provider.historialValidacionTren(trenID, estacion, "", start, end);
    }

    return Row(
      children: [
        SizedBox(
          width: 170,
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
              LengthLimitingTextInputFormatter(10),
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


        Row(
          children: [
            SizedBox(
              width: 210,
              child: ValueListenableBuilder<FilterType>(
                valueListenable: selectedFilter,
                builder: (_, filter, __) {
                  final enabled = filter != FilterType.range;
                  return DropdownButton2<String>(
                    isExpanded: true,
                    underline: const SizedBox(),
                    hint: const Text(
                      'Seleccione el día',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    items: items.map(
                      (item) => DropdownItem<String>(
                        value: item,
                        height: 40,
                        child: Text(item),
                      ),
                    ).toList(),
                    valueListenable: selectedDay,
                    onChanged: enabled ? (String? newValue) {
                          selectedDay.value = newValue;
                          if (newValue != null) {
                            selectedFilter.value = FilterType.day;
                            /// limpiar rango
                            rangeController.clear();
                          } else {
                            selectedFilter.value = FilterType.none;
                          }
                        }
                      : null,
                    buttonStyleData: ButtonStyleData(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black54),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      overlayColor: WidgetStateProperty.all(Colors.transparent),
                    ),
                    dropdownStyleData: DropdownStyleData(
                      maxHeight: 300,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  );
                },
              ),
            ),


            const SizedBox(width: 12.0),

            SizedBox(
              width: 280,
              child: ValueListenableBuilder<FilterType>(
                valueListenable: selectedFilter,
                builder: (_, filter, __) {
                  final enabled = filter != FilterType.day;
                  return CustomDatePicker(
                    mode: PickerMode.range,
                    label: 'Periodo',
                    controller: rangeController,
                    enabled: enabled,
                    onRange: (range) {
                      if (range != null) {
                        selectedFilter.value = FilterType.range;
                        /// limpiar dropdown
                        selectedDay.value = null;
                      } else {
                        selectedFilter.value = FilterType.none;
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),

        const SizedBox(width: 15.0),

        SizedBox(
          width: 150,
          child: Autocomplete<String>(
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text.isEmpty) {
                return const Iterable<String>.empty();
              }

              final input = textEditingValue.text.toUpperCase();

              return estacionesNombres.where((option) {
                return option.toUpperCase().contains(input);
              });
            },
            onSelected: (String selection) {
              controllerestacion.text = selection.toUpperCase();
            },
            fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
              controllerestacion = controller;
              return TextFormField(
                controller: controller,
                focusNode: focusNode,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(7),
                  FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z]')),
                ],
                onChanged: (text) {
                  final upperText = text.toUpperCase();
                  controller.value = TextEditingValue(
                    text: upperText,
                    selection: TextSelection.collapsed(offset: upperText.length),
                  );
                },
                decoration: const InputDecoration(
                  labelText: 'Estación',
                  border: OutlineInputBorder(),
                ),
              );
            },
            optionsViewBuilder: (context, onSelected, options) {
              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  elevation: 4.0,
                  child: SizedBox(
                    width: 150, // 👈 MISMO WIDTH QUE EL INPUT
                    height: 300,
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: options.length,
                      itemBuilder: (context, index) {
                        final option = options.elementAt(index);
                        return ListTile(
                          title: Text(option),
                          onTap: () => onSelected(option),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),


        const SizedBox(width: 15.0),
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () => performSearch(context),
        ),
        const SizedBox(width: 12.0),

        IconButton(
          icon: const Icon(Icons.clear, color: Colors.red),
          onPressed: () async {
            controllerTren.clear();
            controllerestacion.clear();
            rangeController.clear();
            /// reset dropdown
            selectedDay.value = null;
            /// reset filtros
            selectedFilter.value = FilterType.none;
            provider.setQuery(false);
            if (trainId != null && trainId.isNotEmpty) {
              await provider.historialValidaciones(trainId);
            } else {
              provider.setFilter(false);
              provider.setQuery(false);
            }
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

  Widget _buildDataTableFilter(List<Map<String, dynamic>> validationHistoryTrain,
      bool isScrollableTrain, BuildContext context) {
        final isLaptop = ResponsiveBreakpoints.of(context).equals('LAPTOP');
    return SizedBox(
      height: 900,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            border: TableBorder.all(color: Colors.grey.shade400, width: 1.0),
            columnSpacing: 10.0,
            dataRowHeight: 65.0,
            headingRowColor: MaterialStateProperty.all(Colors.black),
            columns: _buildTableHeaderstFilter(context),
            rows: validationHistoryTrain
                .map((data) => _buildDataRowTrain(data, context))
                .toList(),
          ),
        ),
      ),
    );
  }

  List<DataColumn> _buildTableHeaderstFilter(context) {
    return [
      _buildHeaderColumn('Tren', context),
      _buildHeaderColumn('Estación Actual', context),
      _buildHeaderColumn('Fecha Llamado', context),

    ];
  }

  DataRow _buildDataRowTrain(Map<String, dynamic> data, BuildContext context) {
    final isLaptop = ResponsiveBreakpoints.of(context).equals('LAPTOP');
    final ffc = context.watch<FfccProvider>();

    return DataRow(
      cells: [
        _buildDataCellIdTrain(
          idTrain: data['ID_TREN'] ?? '',
          tcn: data['TCN'] ?? '', 
          ffc: ffc.selectedItem,
          station: data['ESTACION'] ?? '', 
          color: Colors.black, 
          width: 438
        ),
        _buildDataCellFilter(data['ESTACION'] ?? '', Colors.black, context, width: 438),
        _buildCellDateStringFilter(
          SizedBox(
            width: 438,
            child: Center(child: Text(
              (data['FECHA']?.toString().split(' ').first ?? ''),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            
            ),),
          ),
          Colors.black, 
          context
        ),
      ],
    );
  }

  DataCell _buildDataCellIdTrain({
    required String idTrain,
    required String tcn,
    required String ffc,
    required String station,
    Color color = Colors.black,
    double width = 120,
  }){
    return DataCell(
      SizedBox(
        width: width,
        child: Center(
          child: HoverTrainTextHistory(
            id: idTrain,
            tcn: tcn,
            ffc: ffc, 
            station: station, 
            color: color
          ),
        ),
      ),
    );
  }

  DataCell _buildDataCellFilter(String value, Color textColor, BuildContext context, {double width = 120}) {
    return DataCell(
      Container(
        width: width, // Asignar el ancho específico
        alignment: Alignment.center, // Centrar el contenido
        color: Colors.transparent, // No color de fondo
        child: Text(
          value.contains('T') ? _formatDateTime(value) : value.toString(),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: textColor,
            fontSize: 15.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  DataCell _buildCellDateStringFilter(
    Widget widget,
    Color color,
    BuildContext context
  ) {
    return DataCell(
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Primer texto
            widget,
            
          ],
        ),
      ),
    );
  }

  Widget _buildDataTable(List<Map<String, dynamic>> validationHistory,
      bool isScrollable, BuildContext context) {
    return SizedBox(
      height: 500,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            border: TableBorder.all(color: Colors.grey.shade400, width: 1.0),
            columnSpacing: 10.0,
            dataRowHeight: 65.0,
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
     /* _buildHeaderColumn('Cargados', context),
      _buildHeaderColumn('Vacíos', context),*/
      _buildHeaderColumn('Estatus\nValidación', context),
      _buildHeaderColumn('Fecha\nValidado', context),
      //_buildHeaderColumn('Ofrecido\nPor', context),
      _buildHeaderColumn('Fecha\nOfrecido', context),
      _buildHeaderColumn('Estatus\nCCO', context),
      _buildHeaderColumn('Estatus CCO\nAutorizado/Rechazado', context),
      _buildHeaderColumn('Fecha Envio\nde Llamado', context),
      _buildHeaderColumn('Fecha\nLlamado', context),
      _buildHeaderColumn('Salida de\nTerminal', context),
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
    final isLaptop = ResponsiveBreakpoints.of(context).equals('LAPTOP');
    final int id = record['ID'];
    final String? validado = record['validado'];
    final String? autorizado = record['autorizado'];

    return DataRow(
      cells: [
        _buildDataCell(record['IdTren'] ?? '', Colors.black, context),
        _buildDataCell(record['origen'] ?? '', Colors.black, context),
        _buildDataCell(record['destino'] ?? '', Colors.black, context),
        _buildDataCell(record['estacion_actual'] ?? '', Colors.black, context),
        _buildDataCellCars(
          '${'Cargados'.padRight(isLaptop? 8 : 20)}${(record['cargados'] ?? '').toString().padLeft(5)}\n'
          '${'Vacios'.padRight(isLaptop? 8 : 20)}${(record['vacios'] ?? '').toString().padLeft(8)}\n'
          '${'Total'.padRight(isLaptop? 8 : 20)}${(record['carros'] ?? '').toString().padLeft(10)}\n', 
          Colors.black, context),
        
        // 🔥 "Validado" en rojo si es "Rechazado" o "Error de formación"
        _buildDataCell(
            validado ?? '',
            (validado == 'Rechazado' || validado == 'Error de formación')
                ? Colors.red
                : Colors.black,
            context),

        // 🔥 "Fecha Validado" en rojo si "Validado" es "Error de formación"
        _buildCellDateString(
            record['validado_por'] ?.toString()?? '',
            formattedDateCell(
              date: record['fecha_validado']?.toString() ?? '',
              format: 'dd/MM/yyyy \n HH:mm',
            ),
            Colors.black,           
            context
        ),

        //Ofrecido Por
        _buildCellDateString(
          record['ofrecido_por']?.toString() ?? '', 
          formattedDateCell(
            date: record['fecha_ofrecido']?.toString() ?? '',
            format: 'dd/MM/yyyy \n HH:mm'
          ), 
          Colors.black, 
          context
        ),

        //"Estatus CCO" en rojo solo si es "Rechazado"
        _buildStatusCell(
          autorizado ?? 'Autorizado',
          autorizado == 'Rechazado' ? Colors.red : Colors.black,
          context,
          id,
        ),


        // 🔥 "Fecha Autorizado" en rojo si "Estatus CCO" es "Rechazado"
        _buildCellDateString(
          record['autorizado_por']?.toString() ?? '', 
          formattedDateCell(
            date: record['fecha_autorizado']?.toString() ?? '',
            format: 'dd/MM/yyyy \n HH:mm'
          ), 
          Colors.black, 
          context
        ),   

        _buildCellDateString(
          record['llamado_por']?.toString() ?? '', 
          formattedDateCell(
            date: record['fecha_llamado']?.toString() ?? '',
            format: 'dd/MM/yyyy \n HH:mm',
          ), 
          Colors.black, 
          context
        ), 

        _buildCellDateString(
          record['llamado_por']?.toString() ?? '', 
          formattedDateCell(
            date: record['fecha_llamado']?.toString() ?? '',
            format: 'dd/MM/yyyy \n HH:mm',
          ), 
          Colors.black, 
          context
        ),

        buildCellExitterminal(
          widget: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                record['fecha_salida_rc2'] != null? 'RC2 ${record['fecha_salida_rc2']}' : '',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                record['fecha_salida_lector'] != null? 'AEI ${record['fecha_salida_lector']}' : '',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),    
      ],
    );
  }

  DataCell buildCellExitterminal({
    required Widget widget,
  }) {
    return DataCell(
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Primer texto
            widget,
          ],
        ),
      ),
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
                    builder: (context){
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
                              child: const Material(
                                color: Colors.transparent,
                                child: RechazoObsTren(),
                              ),
                            ),
                          ),  
                        );
                        }
                      );
                    },                
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
                decorationColor: text == 'Rechazado'? Colors.red : null,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

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

  DataCell _buildDataCellCars(String text, Color textColor, BuildContext context){
    return DataCell(
      Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 15.0,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
          textAlign: TextAlign.start,
        ),
      ),
    );
  }

  DataCell _buildCellDateString(
    String text,
    Widget widget,
    Color color,
    BuildContext context
  ) {
    return DataCell(
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Primer texto
            widget,
            Text(
              text,
              style: TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
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
}
