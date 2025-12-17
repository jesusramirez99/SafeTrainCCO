import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:safe_train_cco/modelos/change_notifier_provider.dart';
import 'package:safe_train_cco/modelos/ofrecimientos_provider.dart';
import 'package:safe_train_cco/modelos/tablas_tren_provider.dart';
import 'package:safe_train_cco/modelos/user_provider.dart';
import 'package:safe_train_cco/pages/home/home_page.dart';
import 'package:safe_train_cco/pages/login/login_page.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final TextEditingController idTrainController;
  final FocusNode idTrainFocusNode;

  const CustomAppBar({
    super.key,
    required this.idTrainController,
    required this.idTrainFocusNode,
  });

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarState extends State<CustomAppBar> {
  bool _showDataTrain = true;
  bool _showInfoTrain = false;

  void toggleDataTrain() {
    setState(() {
      _showDataTrain = !_showDataTrain;
      _showInfoTrain = !_showInfoTrain;
    });
  }

  @override
  void initState() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.userName;
    super.initState();
    widget.idTrainFocusNode.requestFocus();
    Future.microtask(() {
      Provider.of<OfrecimientosProvider>(context, listen: false)
          .startAutoRefresh(context, user!);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLaptop = ResponsiveBreakpoints.of(context).equals('LAPTOP');
    final isMonitor = ResponsiveBreakpoints.of(context).equals('MONITOR');


    return AppBar(
      backgroundColor: const Color.fromARGB(255, 64, 63, 61),
      iconTheme: IconThemeData(
        color: Colors.grey.shade200,
        size: isLaptop ? 28.0 : 33.0,
      ),
      title: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 16.0,
            ),
            Image.asset(
              'assets/images/gmxt-logo.png',
              width: isLaptop? 120.0 : 145.0,
              height: isLaptop? 50.0 : 60.0,
            ),
            const SizedBox(width: 65.0),
            Expanded(
              child: Text(
                'Tren Seguro CCO',
                style: estiloTextBarApp(context),
              ),
            ),
            Consumer3<UserProvider, FfccProvider, RegionProvider>(
              builder:
                  (context, userProvider, ffccProvider, regionProvider, child) {
                return Row(
                  children: [
                    _iconNotification(context),
                    SizedBox(width: isLaptop? 8.0 : 12.0),
                    _lineaDivisora(),
                    SizedBox(width: isLaptop? 6.0 : 8.0),
                    Tooltip(
                      message: 'Usuario',
                      child: Row(
                        children: [
                            Icon(
                            Icons.account_circle_rounded,
                            size: isLaptop? 15.0 : 17.0,
                            color: const Color.fromARGB(255, 61, 233, 70),
                          ),
                          const SizedBox(width: 6.0),
                          Text(
                            userProvider.userName ?? '',
                            style:  TextStyle(
                              fontSize: isLaptop? 11.0 : 12.0,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: isLaptop? 6.0 : 8.0),
                    _lineaDivisora(),
                    SizedBox(
                      width: isLaptop? 6.0 : 8.0,
                    ),
                    Tooltip(
                      message: 'Región',
                      child: Row(
                        children: [
                          Icon(
                            Icons.terrain_rounded,
                            size: isLaptop? 16.0 : 18.0,
                            color: const Color.fromARGB(255, 61, 233, 70),
                          ),
                          const SizedBox(width: 6.0),
                          Text(
                            regionProvider.region ?? '',
                            style: TextStyle(
                                fontSize: isLaptop? 11.0 : 12.0, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: isLaptop? 6.0 : 8.0),
                    _lineaDivisora(),
                    SizedBox(width: isLaptop? 6.0 : 8.0),
                    Tooltip(
                      message: 'Ferrocarril',
                      child: Row(
                        children: [
                          Icon(
                            Icons.directions_train,
                            size: isLaptop? 15.0 : 17.0,
                            color: const Color.fromARGB(255, 61, 233, 70),
                          ),
                          const SizedBox(width: 6.0),
                          Text(
                            ffccProvider.selectedItem,
                            style: TextStyle(
                              fontSize: isLaptop? 11.0 : 12.0,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: isLaptop? 10.0 : 12.0),
                    _lineaDivisora(),
                    SizedBox(width: isLaptop? 10.0 : 14.0),
                    _btnSalir(context),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Icono de Notificaciones de trenes ofrecidos
  Widget _iconNotification(BuildContext context) {
    final ofrecimientoProvider = Provider.of<OfrecimientosProvider>(context);
    final trenesOfrecidos = ofrecimientoProvider.trenesOfrecidos;
    final isLoading = ofrecimientoProvider.isLoading;
    final errorMessage = ofrecimientoProvider.errorMessage;
    final trainProvider = Provider.of<TrenYFechaModel>(context, listen: true);
    final selectionNotifier = Provider.of<SelectionNotifier>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.userName;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.notifications_active, size: 17.0),
          tooltip: 'Trenes ofrecidos',
          onOpened: () =>
              ofrecimientoProvider.fetchOfrecimientos(context, user!),
          onSelected: (trainId) {
            selectionNotifier.updateSelectedRow(null);
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const Home()),
              (Route<dynamic> route) => false,
            );

            final estacion = trainId.split('-').last.trim();

            trainProvider.setTrenYFecha(trainId);

            widget.idTrainController.text =
                trainId.substring(0, trainId.length - 2);

            final tableProvider =
                Provider.of<TablesTrainsProvider>(context, listen: false);

            tableProvider.tableDataTrain(context, trainProvider.trenYFecha!, estacion);

            widget.idTrainFocusNode.requestFocus();
          },
          itemBuilder: (BuildContext context) {
            if (isLoading) {
              return [
                const PopupMenuItem(
                  child: Center(child: CircularProgressIndicator()),
                )
              ];
            }

            if (errorMessage != null) {
              return [
                PopupMenuItem(
                  child: Text('Error: $errorMessage',
                      style: const TextStyle(color: Colors.red)),
                ),
              ];
            }

            if (trenesOfrecidos.isEmpty) {
              return [
                const PopupMenuItem(
                  child: Text('No hay trenes ofrecidos'),
                ),
              ];
            }

            return trenesOfrecidos.map((train) {
              print(train);
              return PopupMenuItem<String>(
                value: train,
                child: Text(train),
              );
            }).toList();
          },
        ),
        Positioned(
          right: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            constraints: const BoxConstraints(
              minWidth: 3,
              minHeight: 3,
            ),
            decoration: BoxDecoration(
              color: trenesOfrecidos.isNotEmpty ? Colors.red : Colors.grey,
              borderRadius: BorderRadius.circular(10.0),
            ),
            alignment: Alignment.center,
            child: Text(
              isLoading ? '...' : '${trenesOfrecidos.length}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Opcion Salir del barApp
  TextButton _btnSalir(BuildContext context) {
    return TextButton(
      onPressed: () {
        //disconnectSession(context);

        // Navegar a la página de inicio y limpiar el historial de navegación
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const Login()),
          (Route<dynamic> route) => false,
        );
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
        dataTrainProvider
            .clearData(); // Asegúrate de implementar clearData() en tu provider

        print("Salir");
      },
      style: ButtonStyle(
        overlayColor: MaterialStateProperty.all(
          const Color.fromARGB(204, 203, 202, 202),
        ),
        mouseCursor: MaterialStateProperty.all<MouseCursor>(
          SystemMouseCursors.click,
        ),
      ),
      child: const Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.logout,
              color: Color.fromARGB(255, 255, 99, 97),
              size: 15.0,
            ),
            SizedBox(width: 10),
            Text(
              'Salir',
              style: TextStyle(
                fontSize: 14.0,
                color: Color.fromARGB(255, 255, 99, 97),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Linea divisora
  Text _lineaDivisora() {
    return const Text(
      '|',
      style: TextStyle(color: Colors.white, fontSize: 18.0),
    );
  }

  // Estilo titulo BARAPP
  TextStyle estiloTextBarApp(BuildContext context) {
    final isLaptop = ResponsiveBreakpoints.of(context).equals('LAPTOP');
    return TextStyle(
      fontWeight: FontWeight.w400,
      fontSize: isLaptop ? 16.0 : 25.0,
      color: const Color.fromARGB(255, 233, 227, 227),
    );
  }
}
