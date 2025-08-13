import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safe_train_cco/modelos/autorizar_tren_provider.dart';
import 'package:safe_train_cco/modelos/change_notifier_provider.dart';
import 'package:safe_train_cco/modelos/estaciones_provider.dart';
import 'package:safe_train_cco/modelos/excel_download_provider.dart';
import 'package:safe_train_cco/modelos/historico_validacion_trenes_provider.dart';
import 'package:safe_train_cco/modelos/indicadores_train_provider.dart';
import 'package:safe_train_cco/modelos/login_provider_cco.dart';
import 'package:safe_train_cco/modelos/motivo_rechazo_provider.dart';
import 'package:safe_train_cco/modelos/ofrecimientos_provider.dart';
import 'package:safe_train_cco/modelos/rechazar_tren_provider.dart';
import 'package:safe_train_cco/modelos/rechazos_observaciones_data_provider.dart';
import 'package:safe_train_cco/modelos/tablas_tren_provider.dart';
import 'package:safe_train_cco/modelos/user_provider.dart';
import 'package:safe_train_cco/pages/home/home_page.dart';
import 'package:safe_train_cco/pages/login/login_page.dart';
import 'package:safe_train_cco/pages/ffccpage/select_ffcc_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LoginProviderCCO()),
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => SelectionNotifier()),
        ChangeNotifierProvider(create: (context) => ButtonStateNotifier()),
        ChangeNotifierProvider(create: (context) => TrainSelectionProvider()),
        ChangeNotifierProvider(create: (context) => TrenYFechaModel()),
        ChangeNotifierProvider(create: (context) => TablesTrainsProvider()),
        ChangeNotifierProvider(create: (context) => DateProvider()),
        ChangeNotifierProvider(create: (context) => FechaProvider()),
        ChangeNotifierProvider(create: (context) => HoraProvider()),
        ChangeNotifierProvider(create: (context) => EstacionesProvider()),
        ChangeNotifierProvider(create: (context) => OfrecimientosProvider()),
        ChangeNotifierProvider(create: (context) => IndicatorTrainProvider()),
        ChangeNotifierProvider(create: (context) => MotivoRechazoProvider()),
        ChangeNotifierProvider(create: (context) => AutorizarTrenProvider()),
        ChangeNotifierProvider(create: (context) => ExcelDownloadProvider()),
        ChangeNotifierProvider(create: (context) => FfccProvider()),
        ChangeNotifierProvider(create: (context) => RechazoTrenProvider()),
        ChangeNotifierProvider(create: (context) => IdTren()),
        ChangeNotifierProvider(create: (context) => EstatusCCOProvider()),
        ChangeNotifierProvider(
            create: (context) => HistorialValidacionesProvider()),
        ChangeNotifierProvider(create: (context) => MotRechazoObs()),
        ChangeNotifierProvider(
            create: (context) => RechazosObservacionesData()),
        ChangeNotifierProvider(create: (context) => RegionProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/ffcc',
      routes: {
        '/ffcc': (context) => const SelectFC(),
        '/login': (context) => const Login(),
        '/home': (context) => const Home(),
      },
    );
  }
}
