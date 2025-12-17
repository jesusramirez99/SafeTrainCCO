import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safe_train_cco/modelos/motivo_rechazo_provider.dart';
import 'package:safe_train_cco/modelos/ofrecimientos_provider.dart';
import 'package:safe_train_cco/modelos/rechazar_tren_provider.dart';
import 'package:safe_train_cco/modelos/tablas_tren_provider.dart';
import 'package:safe_train_cco/modelos/user_provider.dart';

class MotivoRechazoModal extends StatefulWidget {
  final String estacion;

  const MotivoRechazoModal({
    super.key, 
    required this.estacion
  });

  @override
  _MotivoRechazoModalState createState() => _MotivoRechazoModalState();
}

class _MotivoRechazoModalState extends State<MotivoRechazoModal> {
  Future<void>? _cargarMotivosFuture;
  final Map<String, bool> _selectedMotivos = {};
  final TextEditingController obsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarMotivosFuture =
        Provider.of<MotivoRechazoProvider>(context, listen: false)
            .cargarMotivosRechazo();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _cargarMotivosFuture,
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const AlertDialog(
            title: Text('Cargando Motivos...'),
            content: CircularProgressIndicator(),
          );
        } else if (snapshot.error != null) {
          return AlertDialog(
            title: const Text('Error'),
            content:
                const Text('No se pudieron cargar los motivos de rechazo.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
                child: const Text('Cerrar'),
              ),
            ],
          );
        } else {
          final motivoProvider = Provider.of<MotivoRechazoProvider>(context);

          if (_selectedMotivos.isEmpty) {
            for (var motivo in motivoProvider.motivosRechazo) {
              _selectedMotivos[motivo['motivo']] = false;
            }
          }

          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            title: Stack(
              children: [
                Center(
                  child: Text(
                    'Motivos de Rechazo',
                    style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(
                      Icons.close,
                      size: 24.0,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                          motivoProvider.motivosRechazo.map<Widget>((motivo) {
                        final motivoName = motivo['motivo'] as String;
                        return Row(
                          children: [
                            Checkbox(
                              value: _selectedMotivos[motivoName],
                              onChanged: (value) {
                                setState(() {
                                  _selectedMotivos[motivoName] = value!;
                                });
                                print('Motivo seleccionado: $motivoName');
                              },
                            ),
                            Expanded(child: Text(motivoName)),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(width: 20.0),
                  Expanded(flex: 3, child: _campoObs()),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  obsController.clear();
                  setState(() {
                    _selectedMotivos.updateAll((key, value) =>
                        false); // Esto desmarca todos los checkboxes
                  });
                },
                style: buttonStyle(),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.cancel, color: Colors.red, size: 18.0),
                    SizedBox(width: 8),
                    Text('Cancelar',
                        style: TextStyle(color: Colors.red, fontSize: 18.0)),
                  ],
                ),
              ),
              const SizedBox(width: 15.0),
              TextButton(
                onPressed: () async {
                  if (!_selectedMotivos.containsValue(true)) {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        content: const Text(
                          'Debe seleccionar al menos un motivo de rechazo.',
                          style: TextStyle(fontSize: 17.0),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                    return;
                  }

                  List<Map<String, String>> motivosRechazo = _selectedMotivos
                      .entries
                      .where((e) => e.value)
                      .map((e) => {"motivo": e.key})
                      .toList();

                  String observaciones = obsController.text;

                  if (!context.mounted) return;

                  // Mostrar indicador de carga
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (ctx) =>
                        const Center(child: CircularProgressIndicator()),
                  );

                  try {
                    final providerDataTable = Provider.of<TablesTrainsProvider>(
                        context,
                        listen: false);
                    final idTrain = providerDataTable.trainData!.id;

                    final userProvider =
                        Provider.of<UserProvider>(context, listen: false);
                    final user = userProvider.userName;

                    await Provider.of<RechazoTrenProvider>(context,
                            listen: false)
                        .rechazarTren(
                      id: idTrain,
                      autorizadoPor: user!,
                      observaciones: observaciones,
                      motivosRechazo: motivosRechazo,
                    );

                    if (!context.mounted) return;

                    showFlushbar('Rechazando el tren', Colors.orange, context)
                        .then((_) {
                      if (context.mounted) {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      }
                      Future.delayed(Duration(seconds: 4));

                      _refreshTableData(context);
                      Provider.of<OfrecimientosProvider>(context, listen: false)
                          .refreshOfrecimientos(context, user);
                    });
                  } catch (e) {
                    print("Error al rechazar tren: $e");

                    if (context.mounted) {
                      Navigator.of(context).pop();
                      Future.delayed(Duration.zero, () {
                        showFlushbar(
                            'Error al rechazar el tren', Colors.red, context);
                      });
                    }
                  }
                },
                style: buttonStyle(),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check, color: Colors.green, size: 18.0),
                    SizedBox(width: 8),
                    Text('Rechazar',
                        style: TextStyle(color: Colors.green, fontSize: 18.0)),
                  ],
                ),
              ),
            ],
          );
        }
      },
    );
  }

  // CAMPO DE OBSERVACIONES
  Widget _campoObs() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                Icons.notes,
                color: Colors.black,
                size: 17.0,
              ),
              SizedBox(width: 8),
              Center(
                child: Text(
                  'Observaciones',
                  style: TextStyle(
                    fontSize: 17.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 330, // Ajusta este valor según el tamaño deseado
            child: TextFormField(
              controller: obsController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Favor de ingresar la descripción';
                }
                return null;
              },
              decoration: InputDecoration(
                filled: true,
                counterText: "",
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(3.0),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 15.0,
                  horizontal: 12.0,
                ),
              ),
              maxLines: 8, // Permite múltiples líneas sin expandirse
              maxLength: 300,
              textAlign: TextAlign.start,
              textAlignVertical: TextAlignVertical.top,
              keyboardType: TextInputType.multiline,
            ),
          ),
        ],
      ),
    );
  }

  // METODO PARA ACTUALIAR LOS DATOS DE LA TABLA
  void _refreshTableData(BuildContext context) async {
    final trenYFechaModel = Provider.of<TrenYFechaModel>(context, listen: false);
    final tren = trenYFechaModel.trenYFecha;
    final tablesProvider = Provider.of<TablesTrainsProvider>(context, listen: false);

    await tablesProvider.tableDataTrain(context, tren!, widget.estacion);

    print("El tren en el método handle es: $tren");
    print("Tabla actualizada correctamente.");
  }

  ButtonStyle buttonStyle(
      {Color borderColor = const Color.fromARGB(255, 186, 181, 181),
      Color textColor = Colors.black}) {
    return TextButton.styleFrom(
      foregroundColor: textColor,
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      backgroundColor: Colors.transparent,
      side: BorderSide(color: borderColor, width: 1.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    );
  }

  Future<void> showFlushbar(String message, Color color, BuildContext context) {
    return Flushbar(
      duration: const Duration(seconds: 4),
      flushbarPosition: FlushbarPosition.TOP,
      margin: const EdgeInsets.all(1.0),
      borderRadius: BorderRadius.circular(5.0),
      backgroundColor: color,
      messageText: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white),
      ),
    ).show(context);
  }
}
