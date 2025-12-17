import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:safe_train_cco/modales/mdl_autorizar_tren.dart';
import 'package:safe_train_cco/modales/mdl_rechazar_tren.dart';
import 'package:safe_train_cco/modelos/change_notifier_provider.dart';
import 'package:safe_train_cco/modelos/estaciones_provider.dart';
import 'package:safe_train_cco/modelos/historico_validacion_trenes_provider.dart';
import 'package:safe_train_cco/modelos/tablas_tren_provider.dart';
import 'package:safe_train_cco/modelos/user_provider.dart';
import 'package:safe_train_cco/widgets/tabla_historial_validaciones.dart';

class MenuLateral extends StatefulWidget {
  final VoidCallback toggleTableData;
  final VoidCallback toggleTableIndicator;
  final VoidCallback showValidateText;
  final VoidCallback toggleTableInfo;
  final VoidCallback showFecha;
  final VoidCallback showHora;

  const MenuLateral({
    super.key,
    required this.toggleTableData,
    required this.toggleTableIndicator,
    required this.toggleTableInfo,
    required this.showValidateText,
    required this.showFecha,
    required this.showHora,
  });

  @override
  State<MenuLateral> createState() => MenuLateralState();
}

enum TableView { none, indicators, information }

class MenuLateralState extends State<MenuLateral> {
  TableView? _currentView;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String? _dropdownValue;

  int? _selectedRowIndex;
  int? _selectedTrainId;

  bool _isInformation = true;
  bool _isIndicator = true;
  bool _isButtonEnabled = true;

  void procesarTren() {
    setState(() {
      _selectedRowIndex = -1;
      _selectedTrainId = null;
    });
  }

  @override
  void initState() {
    super.initState();
    _dropdownValue = "Rechazado por:";
  }

  @override
  Widget build(BuildContext context) {
    final isLaptop = ResponsiveBreakpoints.of(context).equals('LAPTOP');
    final menuWidth = isLaptop ? 150.0 : 190.0;
    final fontSize = isLaptop ? 10.5 : 13.0;
    final iconTextSpacing = isLaptop ? 6.0 : 10.0;

    return Container(
      width: menuWidth,
      color: Colors.black,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Divider(),
          _btnIndicadores(fontSize, iconTextSpacing),
          const Divider(),
          _btnInfo(fontSize, iconTextSpacing),
          const Divider(),
          const SizedBox(height: 4.0),
          _btnHistorial(context, fontSize, iconTextSpacing),
          const Divider(),
          _btnRechazar(fontSize, iconTextSpacing),
          const Divider(),
          const SizedBox(height: 4.0),
          _btnAutorizar(fontSize, iconTextSpacing),
          const Divider(),
          // Form(key: formKey, child: _campoObs()),
        ],
      ),
    );
  }

  // BOTON INDCADORES DEL TREN
  Widget _btnIndicadores(double fontSize, double iconText) {
    final selectionNotifier = Provider.of<SelectionNotifier>(context);
    final isLaptop = ResponsiveBreakpoints.of(context).equals('LAPTOP');

    return ValueListenableBuilder<int?>(
      valueListenable: selectionNotifier.selectedRowNotifier,
      builder: (context, selectedIndex, Widget? child) {
        bool isActive = _currentView == TableView.indicators;
        return TextButton(
          onPressed: selectedIndex == null || selectedIndex == -1
              ? null
              : () {
                  setState(() {
                    _currentView = isActive ? null : TableView.indicators;
                  });
                  widget.toggleTableIndicator();
                },
          style: _buttonStyle(selectedIndex),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  isActive ? Icons.article_outlined : Icons.analytics_outlined,
                  color: Colors.white,
                ),
                SizedBox(width: iconText),
                Text(
                  isActive ? 'Datos del Tren' : 'Indicadores',
                  style: TextStyle(
                    fontSize: fontSize,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _btnInfo(double fontSize, double iconText) {
    final selectionNotifier = Provider.of<SelectionNotifier>(context);

    return ValueListenableBuilder<int?>(
      valueListenable: selectionNotifier.selectedRowNotifier,
      builder: (context, selectedIndex, Widget? child) {
        bool isActive = _currentView == TableView.information;
        return TextButton(
          onPressed: selectedIndex == null || selectedIndex == -1
              ? null
              : () {
                  setState(() {
                    _currentView = isActive ? null : TableView.information;
                  });
                  widget.toggleTableInfo();
                },
          style: _buttonStyle(selectedIndex),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  isActive
                      ? Icons.article_outlined
                      : Icons.perm_device_information,
                  color: Colors.white,
                ),
                SizedBox(width: iconText),
                Text(
                  isActive ? 'Datos del Tren' : 'Información del Tren',
                  style: TextStyle(
                    fontSize: fontSize,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // BOTON HISTORIAL ESTATUS DEL TREN
  Widget _btnHistorial(BuildContext contextdouble, fontSize, double iconText) {
    return TextButton(
      onPressed: () async {
        final trainProvider =
            Provider.of<TrenYFechaModel>(context, listen: false);
        final trainId = trainProvider.trenYFecha;

        final provider = Provider.of<HistorialValidacionesProvider>(
          context,
          listen: false,
        );

        // Si el trainId es nulo o vacío, simplemente manda un Future vacío sin consulta
        Future<void> historialFuture;
        if (trainId != null && trainId.isNotEmpty) {
          historialFuture = provider.historialValidaciones(trainId);
        } else {
          historialFuture =
              Future.value(); // Un Future vacío para abrir el modal sin datos
        }

        // Abre el modal
        HistorialValidacionesModal.showHistorialValidacionesModal(
          context,
          historialFuture,
        );
      },
      style: ButtonStyle(
        overlayColor: MaterialStateProperty.all(
          const Color.fromRGBO(163, 159, 159, 0.8),
        ),
        foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Icon(Icons.add_task_outlined, color: Colors.white),
            SizedBox(width: iconText),
            Text(
              'Historial',
              style: TextStyle(fontSize: fontSize, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  // BOTON AUTORIZAR TREN
  Widget _btnAutorizar(double fontSize, double iconText) {
    return Consumer<EstatusCCOProvider>(
      builder: (context, estatusProvider, child) {
        final selectionNotifier = Provider.of<SelectionNotifier>(context);
        final estacionProvider = Provider.of<EstacionesProvider>(context);
        final estacion = estacionProvider.selectedEstacion;
        final trenProvider = Provider.of<TrenYFechaModel>(context);
        final tren = trenProvider.trenYFecha;
        final horaProvider = Provider.of<HoraProvider>(context);
        final hora = horaProvider.hora;

        bool isDisabled = estatusProvider.estatusCCO == 'Autorizado' ||
            selectionNotifier.selectedRowNotifier.value == null ||
            selectionNotifier.selectedRowNotifier.value == -1;

        return TextButton(
          onPressed: isDisabled
              ? null
              : () {
                  showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (ctx) => ModalAutorizarTren(
                      tren: tren!,
                      estacion: estacion ?? 'Estación no seleccionada',
                      fechaController: TextEditingController(),
                      horaController: TextEditingController(text: hora),
                      observacionesController: TextEditingController(),

                    ),
                  );
                },
          style: _buttonStyle(
              selectionNotifier.selectedRowNotifier.value, isDisabled),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Icon(
                  Icons.train,
                  color: Color.fromARGB(255, 145, 228, 148),
                ),
                SizedBox(width: iconText),
                Text(
                  'Autorizar Tren',
                  style: TextStyle(
                    fontSize: fontSize,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // BOTON RECHAZAR TREN
  Widget _btnRechazar(double fontSize, double iconText) {
    return Consumer2<EstatusCCOProvider, SelectionNotifier>(
      builder: (context, estatusProvider, selectionNotifier, child) {
        int? selectedIndex = selectionNotifier.selectedRowNotifier.value;
        String estatus = estatusProvider.estatusCCO;
        final estacionProvider = Provider.of<EstacionesProvider>(context);
        final estacion = estacionProvider.selectedEstacion;

        bool isDisabled = estatus == 'Rechazado' ||
                estatus == 'Autorizado' ||
                selectedIndex == null ||
                selectedIndex == -1 ||
                (selectedIndex == null || selectedIndex == -1) && estatus != ''
            ? true
            : false;

        return TextButton(
          onPressed: isDisabled
              ? null
              : () async {
                  final bool? isRejected = await showDialog<bool>(
                    barrierDismissible: false,
                    context: context,
                    builder: (ctx) => MotivoRechazoModal(
                      estacion: estacion ?? '',
                    ),
                  );

                  if (isRejected == true) {
                    estatusProvider.updateEstatusCCO("Rechazado");
                    estatusProvider.notifyListeners();

                    // 🔥 Llamar al método de MenuLateral
                    final menuLateralState =
                        context.findAncestorStateOfType<MenuLateralState>();
                    menuLateralState?.procesarTren();
                  }
                },
          style: _buttonStyle(selectedIndex, isDisabled),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Icon(Icons.cancel, color: Colors.red),
                SizedBox(width: iconText),
                Text(
                  'Rechazar Tren',
                  style: TextStyle(fontSize: fontSize, color: Colors.white),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Estilo de los botones
  ButtonStyle _buttonStyle(int? selectedIndex, [bool isDisabled = false]) {
    return ButtonStyle(
      overlayColor: MaterialStateProperty.all(
        const Color.fromRGBO(163, 159, 159, 0.8),
      ),
      mouseCursor: MaterialStateProperty.all<MouseCursor>(
        isDisabled || selectedIndex == null || selectedIndex == -1
            ? SystemMouseCursors.forbidden
            : SystemMouseCursors.click,
      ),
      foregroundColor: MaterialStateProperty.all<Color>(
        isDisabled ? Colors.grey : Colors.white, // Color del texto del botón
      ),
    );
  }

  // METODO PARA ACTUALIAR LOS DATOS DE LA TABLA
  void _handleValidateAndRefresh() async {
    final trenYFechaModel =
        Provider.of<TrenYFechaModel>(context, listen: false);
    final tren = trenYFechaModel.trenYFecha;
    final estacionProvider = Provider.of<EstacionesProvider>(context);
    final estacion = estacionProvider.selectedEstacion;
    //widget.toggleTableData();
    Provider.of<TablesTrainsProvider>(context, listen: false)
        .tableDataTrain(context, tren!, estacion);
    print("el tren en el metodo handle es: $tren");
  }

  /// FUNCIÓN PARA LA BARRA DE ALERTA
  void _showFlushbarTreAutorizado(String message, Color backgroundColor) {
    Flushbar(
      duration: const Duration(seconds: 5),
      backgroundColor: backgroundColor,
      flushbarPosition: FlushbarPosition.TOP,
      margin: const EdgeInsets.all(1.0),
      borderRadius: BorderRadius.circular(5.0),
      messageText: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white),
      ),
    ).show(context).then((_) async {
      // Mostrar la segunda barra después de que la primera finalice

      // Después de que ambas barras se hayan mostrado y cerrado
      setState(() {
        Provider.of<ButtonStateNotifier>(context, listen: false)
            .setButtonState('autorizar', false);
        _isButtonEnabled = false; // Deshabilitar el botón

        _handleValidateAndRefresh(); // Actualizar la tabla aquí
        //widget.showValidateText();
        //widget.showFecha();
        //widget.showHora();
      });
    });
  }

  void _showFlushbarValidado(
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
    ).show(context);
  }
}
