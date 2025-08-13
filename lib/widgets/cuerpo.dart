import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safe_train_cco/modales/mdl_comparacion_consist.dart';
import 'package:safe_train_cco/modelos/change_notifier_provider.dart';
import 'package:safe_train_cco/modelos/estaciones_provider.dart';
import 'package:safe_train_cco/modelos/excel_download_provider.dart';
import 'package:safe_train_cco/modelos/tablas_tren_provider.dart';
import 'package:safe_train_cco/modelos/user_provider.dart';
import 'package:safe_train_cco/widgets/btn_cancelar.dart';
import 'package:safe_train_cco/widgets/campo_fecha.dart';
import 'package:safe_train_cco/widgets/table_data_train.dart';
import 'package:safe_train_cco/widgets/table_indicators_train.dart';
import 'package:safe_train_cco/widgets/table_info_train.dart';
import 'package:safe_train_cco/widgets/textfield_idtrain.dart';

class Cuerpo extends StatefulWidget {
  final bool showDataTrain;
  final bool showInfoTrain;
  final bool showIndicatorTrain;
  final bool showValidatorTrain;
  final bool showFecha;
  final bool showTime;
  final FocusNode focusNode;
  final TextEditingController idTrainController;
  final TextEditingController fechaController;

  const Cuerpo({
    super.key,
    required this.showDataTrain,
    required this.showInfoTrain,
    required this.showIndicatorTrain,
    required this.showValidatorTrain,
    required this.showFecha,
    required this.showTime,
    required this.idTrainController,
    required this.fechaController,
    required this.focusNode,
  });

  @override
  State<Cuerpo> createState() => CuerpoState();
}

class CuerpoState extends State<Cuerpo> {
  TextEditingController controllerEstacion = TextEditingController();

  bool _isHovered = false;
  bool _enabledIdTrain = false;
  bool _enabledFecha = false;
  bool _enabledEstacion = true;
  bool _iconSearchEnable = true;
  bool _iconCompareEnable = true;
  bool _iconPrintEnable = true;
  bool _showIndicatorTrain = false;
  bool _showDataTrain = true;
  bool _showInfoTrain = false;
  bool _isLoading = false;
  String _trenYFecha = '';
  int maxLength = 7;
  final FocusNode _focusNode = FocusNode();

  Widget userValidator() {
    return Consumer<UserProvider>(builder: (context, userProvider, child) {
      return Text(
        'autorizado por:   ${userProvider.userName ?? 'No user'}',
        style: const TextStyle(color: Colors.white, fontSize: 13.0),
      );
    });
  }

  List<Map<String, dynamic>> _dataTrain = []; // Almacena los datos del tren

  String? _dropdownValue;
  final _formKey = GlobalKey<FormState>();

  void toggleIndicatorTrain() {
    setState(() {
      _showIndicatorTrain = !_showIndicatorTrain;
      _showDataTrain = !_showDataTrain;
      _showInfoTrain;
    });
  }

  void toggleDataTrain() {
    setState(() {
      _showDataTrain = !_showDataTrain;
      _showInfoTrain = !_showInfoTrain;
    });
  }

  void toggleInfoTrain() {
    setState(() {
      _showDataTrain = !_showDataTrain;
      _showInfoTrain = !_showInfoTrain;
    });
  }

  @override
  void initState() {
    super.initState();
    _dropdownValue = null;
    Future.microtask(() =>
        Provider.of<EstacionesProvider>(context, listen: false)
            .fetchEstaciones());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    widget.idTrainController.dispose();
    widget.fechaController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (widget.idTrainController.text.isEmpty ||
        widget.fechaController.text.isEmpty ||
        _dropdownValue == 'ESTACION') {
      showFlushbar('Favor de ingresar todos los datos requeridos', Colors.red);
      return;
    } else {
      setState(() {
        _enabledEstacion = true;
        _toggleSearch();
        _isLoading = true;
      });

      String idTrain = widget.idTrainController.text;
      String fecha = widget.fechaController.text;

      if (fecha.length >= 2) {
        String dia = fecha.substring(0, 2);

        String espacios = '';
        if (idTrain.length == 5) {
          espacios = '   '; // 3 espacios
        } else if (idTrain.length == 6) {
          espacios = '  '; // 2 espacios
        } else if (idTrain.length == 7) {
          espacios = ' '; // 1 espacio
        } else if (idTrain.length == 8) {
          espacios = ''; // sin espacios
        }

        _trenYFecha = '$idTrain$espacios$dia';
        print('datos del tren: $_trenYFecha');

        final provider =
            Provider.of<TablesTrainsProvider>(context, listen: false);

        await provider.tableDataTrain(context, _trenYFecha);

        if (provider.trainData == null) {
          showFlushbar(
              'No se encontró información del tren ingresado.', Colors.red);

          return;
        }
      } else {
        print('La fecha debe tener al menos dos caracteres');
      }
    }
  }

  void showFlushbar(String message, Color color) {
    Flushbar(
      duration: const Duration(seconds: 6),
      flushbarPosition: FlushbarPosition.TOP,
      margin: const EdgeInsets.all(1.0),
      borderRadius: BorderRadius.circular(5.0),
      backgroundColor: color, // Agregar esta línea
      messageText: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white),
      ),
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    final estacionProvider = Provider.of<EstacionesProvider>(context);
    final estacion = estacionProvider.selectedEstacion;

    final trenProvider = Provider.of<TrenYFechaModel>(context);
    final tren = trenProvider.trenYFecha;

    return Scaffold(
      body: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              const SizedBox(
                width: 30.0,
                height: 55.0,
              ),
              Expanded(
                child: Center(
                  child: textoListaTrenes('Autorización de Trenes'),
                ),
              ),
            ],
          ),
          Center(
            child: Container(
              color: Colors.grey.shade600,
              height: 105.0,
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: Row(
                        children: <Widget>[
                          const SizedBox(width: 110.0),
                          textos('Tren'),
                          const SizedBox(width: 25.0),
                          TextFieldIdTrain(
                            focusNode: widget.focusNode,
                            idTrainController: widget.idTrainController,
                            isEnabled: !_enabledIdTrain,
                          ),
                          const SizedBox(width: 40.0),
                          textos('Fecha'),
                          const SizedBox(width: 1.0),
                          Fecha(
                            fechaController: widget.fechaController,
                            isEnabled: !_enabledFecha,
                          ),
                          const SizedBox(width: 40.0),
                          _dropdownEstacion(context),
                          const SizedBox(width: 40.0),
                          iconSearch(),
                          const SizedBox(width: 25.0),
                          const BotonCancelar(),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                _iconCompareConsist(context),
                                const SizedBox(width: 20.0),
                                iconPrint(context),
                                const SizedBox(width: 45.0),
                                dateTime(context, "fecha"),
                                const SizedBox(width: 10.0),
                                const Text(
                                  '-',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 17.0),
                                ),
                                const SizedBox(width: 10.0),
                                dateTime(context, "hora  hrs."),
                              ],
                            ),
                          ),
                          const SizedBox(width: 80.0),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: <Widget>[
                if (widget.showIndicatorTrain)
                  IndicatorTrainTable(
                      trainInfo: tren!,
                      estacionActual: estacionProvider.selectedEstacion ??
                          'Estacion no seleccionada',
                      toggleTableIndicator: () {
                        setState(() {
                          toggleIndicatorTrain();
                        });
                      }),
                if (widget.showDataTrain)
                  DataTrainTable(
                      data: _dataTrain,
                      isLoading: _isLoading,
                      selectedTrain: _trenYFecha,
                      toggleTableData: () {
                        setState(() {
                          toggleDataTrain();
                        });
                      }),
                if (widget.showInfoTrain)
                  InfoTrainTable(
                    trainInfo: tren!,
                    estacion: estacion ?? 'Estación no seleccionada',
                    toggleTableInfo: () {
                      setState(() {
                        toggleInfoTrain();
                      });
                    },
                  ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET PARA LA FECHA Y HORA
  Widget dateTime(BuildContext context, String texto) {
    final dateProvider = Provider.of<DateProvider>(context);

    String displayText = '';

    if (texto.toLowerCase() == "fecha") {
      displayText = dateProvider.currentDate;
    } else {
      displayText = "${dateProvider.currentTime} hrs.";
    }

    return Text(
      displayText,
      style: const TextStyle(fontSize: 17.0, color: Colors.white),
    );
  }

  // Texto Tren Pendiente
  Text textoListaTrenes(String texto) {
    return Text(
      texto,
      style: TextStyle(
        fontSize: 20.0,
        fontWeight: FontWeight.w700,
        color: Colors.grey.shade700,
      ),
    );
  }

  // Texto ID Tren y Fecha
  Text textos(String texto) {
    return Text(
      texto,
      style: const TextStyle(
        fontSize: 15.0,
        fontWeight: FontWeight.w300,
        color: Colors.white,
      ),
    );
  }

  // ICONO DE BUSQUEDA DE TREN
  Widget iconSearch() {
    return InkWell(
      onTap: _iconSearchEnable
          ? () {
              _submit();
              _iconPrintEnable;
            }
          : null,
      onHover: !_iconSearchEnable
          ? (value) {
              setState(() {
                _isHovered = false;
              });
            }
          : null, // Si el widget está deshabilitado, onHover será null
      child: Icon(
        Icons.search,
        size: 35.0,
        color: _isHovered ? Colors.grey.shade300 : Colors.white,
      ),
    );
  }

  // ICONO PARA COMPARACION DE CONSIST
  Widget _iconCompareConsist(BuildContext context) {
    return Tooltip(
      message: 'Comparación de Consist',
      child: InkWell(
        onTap: _iconCompareEnable
            ? () {
                showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (context) => const ComparacionConsistModal(),
                );
              }
            : null,
        child: const Icon(
          Icons.difference,
          size: 23.0,
          color: Colors.white,
        ),
      ),
    );
  }

  // ICONO PARA IMPRIMIR EXCEL
  Widget iconPrint(BuildContext context) {
    final trenProvider = Provider.of<TrenYFechaModel>(context, listen: false);
    final tren = trenProvider.trenYFecha;

    final estacionProvider =
        Provider.of<EstacionesProvider>(context, listen: false);
    final estacion = estacionProvider.selectedEstacion;

    return Tooltip(
      message: 'Consist de tren',
      child: InkWell(
        onTap: _iconPrintEnable
            ? () {
                if (tren == null || tren.isEmpty) {
                  showFlushbar('No hay tren seleccionado', Colors.red);
                  return;
                }

                if (estacion == null || estacion.isEmpty) {
                  showFlushbar('No hay tren seleccionado', Colors.red);
                  return;
                }

                showFlushbar(
                    'Descargando archivo para Tren: $tren', Colors.green);

                final excelProvider =
                    Provider.of<ExcelDownloadProvider>(context, listen: false);
                excelProvider.descargarExcel(tren, estacion);
              }
            : null,
        child: const Icon(
          Icons.print,
          size: 23.0,
          color: Colors.white,
        ),
      ),
    );
  }

  // Dropdown Estacion
  Widget _dropdownEstacion(BuildContext context) {
    return Consumer<EstacionesProvider>(
      builder: (context, estacionesProvider, _) {
        final estaciones = estacionesProvider.estaciones;
        final estacionesNombres = estaciones
            .map<String>((station) => station['id_estacion'] as String)
            .toList();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          width: 220.0,
          height: 45.0,
          child: estaciones.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : Autocomplete<String>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return const Iterable<String>.empty();
                    }
                    // Convertir texto de entrada y opciones a mayúsculas
                    final input = textEditingValue.text.toUpperCase();
                    return estacionesNombres.where((String option) {
                      return option.toUpperCase().contains(input);
                    });
                  },
                  onSelected: (String selection) {
                    final selectedStation = estaciones.firstWhere(
                      (station) => station['id_estacion'] == selection,
                    );

                    // Actualizamos la estación seleccionada en el provider
                    estacionesProvider
                        .updateSelectedEstacion(selectedStation['id_estacion']);

                    print(
                        'Estación seleccionada: ${selectedStation['id_estacion']}');
                  },
                  fieldViewBuilder:
                      (context, controller, focusNode, onEditingComplete) {
                    return StatefulBuilder(
                      builder: (context, setState) {
                        return TextFormField(
                          controller: controller,
                          focusNode: focusNode,
                          enabled: _enabledEstacion,
                          onChanged: (text) {
                            // Si el texto supera el límite actual, recortarlo
                            if (text.length > maxLength) {
                              controller.value = controller.value.copyWith(
                                text: text.substring(0, maxLength),
                                selection:
                                    TextSelection.collapsed(offset: maxLength),
                              );
                            } else {
                              controller.value = controller.value.copyWith(
                                text: text.toUpperCase(),
                                selection: TextSelection.collapsed(
                                    offset: text.length),
                              );
                            }
                          },
                          decoration: _estiloDrop().copyWith(
                            hintText: 'ESTACION',
                            hintStyle: const TextStyle(color: Colors.grey),
                            suffixIcon: const Icon(
                              Icons.add_road_outlined,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    );
                  },
                  optionsViewBuilder: (context, onSelected, options) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        elevation: 4.0,
                        child: SizedBox(
                          height: 200.0,
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: options.length,
                            itemBuilder: (context, index) {
                              final option = options.elementAt(index);
                              return ListTile(
                                title: Text(option
                                    .toUpperCase()), // Mostrar en mayúsculas
                                onTap: () {
                                  onSelected(option);
                                  // Actualizar la longitud máxima según el elemento seleccionado
                                  setState(() {
                                    maxLength = option.length;
                                  });
                                  // Establecer el texto seleccionado en el controlador
                                  controllerEstacion.text =
                                      option.toUpperCase();
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }

  // Estilo de Dropdown
  InputDecoration _estiloDrop() {
    return InputDecoration(
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4.0),
        borderSide: const BorderSide(color: Colors.black),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }

  // Método para controlar el botón buscar si está habilitado o deshabilitado
  void _toggleSearch() {
    setState(() {
      if (widget.idTrainController.text.isEmpty ||
          widget.fechaController.text.isEmpty) {
        _iconSearchEnable = true;
      } else {
        _iconSearchEnable = false;
        _iconPrintEnable = true;
      }
      _enabledIdTrain = !_enabledIdTrain;
      _enabledFecha = !_enabledFecha;
      _enabledEstacion = !_enabledEstacion;
    });
  }
}
