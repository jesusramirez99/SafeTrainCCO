import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:safe_train_cco/modelos/change_notifier_provider.dart';
import 'package:safe_train_cco/modelos/estaciones_provider.dart';
import 'package:safe_train_cco/modelos/tablas_tren_provider.dart';
import 'package:safe_train_cco/modelos/user_provider.dart';
import 'package:safe_train_cco/pages/home/home_page.dart';

class BotonCancelar extends StatefulWidget {
  const BotonCancelar({super.key});

  @override
  State<BotonCancelar> createState() => _BotonCancelarState();
}

class _BotonCancelarState extends State<BotonCancelar> {
  @override
  Widget build(BuildContext context) {
    final isLaptop = ResponsiveBreakpoints.of(context).equals('LAPTOP');
    return IconButton(
      icon: Icon(Icons.cancel, color: Colors.red.shade500, size: isLaptop? 25.0 : 35.0),
      onPressed: () {
        // Limpiar selección en SelectionNotifier
        Provider.of<SelectionNotifier>(context, listen: false)
            .updateSelectedRow(null);

        // Resetear estado de los botones en ButtonStateNotifier
        final buttonStateNotifier =
            Provider.of<ButtonStateNotifier>(context, listen: false);
        buttonStateNotifier.setButtonState('indicador', false);
        buttonStateNotifier.setButtonState('informacion', false);
        buttonStateNotifier.setButtonState('validar', true);

        // Limpiar datos de las tablas
        final dataTrainProvider =
            Provider.of<TablesTrainsProvider>(context, listen: false);
        dataTrainProvider.clearData();

        // Limpiar tren del icono de imprimir
        final trenProvider =
            Provider.of<TrenYFechaModel>(context, listen: false);
        trenProvider.clearData();

        final estacionProvider =
            Provider.of<EstacionesProvider>(context, listen: false);
        estacionProvider.clearData();

        // Navegar a la página de inicio y limpiar el historial de navegación
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const Home()),
          (Route<dynamic> route) => false,
        );
      },
    );
  }
}
