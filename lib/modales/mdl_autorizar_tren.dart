import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:safe_train_cco/modelos/autorizar_tren_provider.dart';
import 'package:safe_train_cco/modelos/ofrecimientos_provider.dart';
import 'package:safe_train_cco/modelos/tablas_tren_provider.dart';
import 'package:safe_train_cco/modelos/user_provider.dart';
import 'package:safe_train_cco/widgets/campo_fecha.dart';
import 'package:safe_train_cco/widgets/text_input_formatter_hour.dart';

class ModalAutorizarTren extends StatefulWidget {
  final String tren;
  final String estacion;
  final TextEditingController fechaController;
  final TextEditingController horaController;

  const ModalAutorizarTren({
    super.key,
    required this.tren,
    required this.estacion,
    required this.fechaController,
    required this.horaController,
  });

  @override
  _ModalAutorizarTrenState createState() => _ModalAutorizarTrenState();
}

class _ModalAutorizarTrenState extends State<ModalAutorizarTren> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    setState(() {
      widget.horaController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final fechaProvider = Provider.of<FechaProvider>(context);
    final autorizarTrenProvider = Provider.of<AutorizarTrenProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.userName;

    if (widget.fechaController.text.isEmpty) {
      widget.fechaController.text = fechaProvider.fecha;
    }

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      backgroundColor: Colors.white,
      elevation: 10,
      title: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            'Autorizar Tren',
            style: TextStyle(
              fontSize: 22.0,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              icon: const Icon(Icons.close, size: 24.0, color: Colors.red),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  widget.fechaController.clear();
                  widget.horaController.clear();
                });
              },
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 25.0),
            Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                            width: 180,
                            child: _buildTextField('Tren', widget.tren)),
                        const SizedBox(width: 22.0),
                        SizedBox(
                            width: 200,
                            child:
                                _buildTextField('Estación', widget.estacion)),
                        const SizedBox(width: 22.0),
                        const Text('Fecha',
                            style: TextStyle(
                                fontSize: 18.0, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 4.0),
                        SizedBox(
                          width: 200,
                          child: Fecha(
                            fechaController: widget.fechaController,
                            isEnabled: true,
                          ),
                        ),
                        const SizedBox(width: 10.0),
                        const Text('Hora',
                            style: TextStyle(
                                fontSize: 18.0, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 10.0),
                        SizedBox(
                          width: 110,
                          child: Consumer<HoraProvider>(
                            builder: (context, horaProvider, child) {
                              return TextFormField(
                                controller: widget.horaController,
                                style: const TextStyle(fontSize: 18.0),
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                                onChanged: (value) =>
                                    horaProvider.setHora(value),
                                inputFormatters: [HoraInputFormatter()],
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty)
                                    return 'Hora requerida';
                                  final regex =
                                      RegExp(r'^(?:[01]\d|2[0-3]):[0-5]\d$');

                                  return null;
                                },
                              );
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 15.0),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () {
                widget.fechaController.clear();
                widget.horaController.clear();
              },
              style: buttonStyle(),
              child: const Row(
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
              onPressed: autorizarTrenProvider.isLoading
                  ? null
                  : () async {
                      final idProvider =
                          Provider.of<IdTren>(context, listen: false);
                      final id = idProvider.idTren;

                      if (_formKey.currentState?.validate() ?? false) {
                        String fechaSistema = DateTime.now().toIso8601String();
                        String fecha = widget.fechaController.text;
                        String hora = widget.horaController.text;

                        try {
                          DateFormat format = DateFormat('dd-MM-yyyy HH:mm');
                          DateTime fechaHoraDateTime =
                              format.parse("$fecha $hora");

                          // Convertir fecha del sistema a DateTime
                          DateTime fechaSistemaDateTime =
                              DateTime.parse(fechaSistema);

                          // Restar fechas
                          Duration diferencia = fechaHoraDateTime
                              .difference(fechaSistemaDateTime);

                          // Si la diferencia es menor a 2 horas y media (150 minutos), mostrar alerta y salir
                          if (diferencia.inMinutes < 150) {
                            showFlushbar(
                                'Tren no autorizado. Hora de llamado menor al mínimo de 2h30m requerido',
                                Colors.red,
                                const Duration(seconds: 10),
                                context);
                            return;
                          }

                          String formatDateLlamado =
                              fechaHoraDateTime.toIso8601String();
                          print(
                              'Fecha y hora formateada en ISO: $formatDateLlamado');

                          // Mostrar el indicador de carga
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (ctx) => const Center(
                                child: CircularProgressIndicator()),
                          );

                          bool success =
                              await autorizarTrenProvider.autorizarTren(
                            id: id,
                            pendingTrainId: widget.tren,
                            autorizadoPor: user!,
                            fecha: fechaSistema,
                            estacionActual: widget.estacion,
                            fechaLlamado: formatDateLlamado,
                          );

                          if (success) {
                            Future.delayed(Duration.zero, () {
                              showFlushbar('Autorizando tren', Colors.orange,
                                      const Duration(seconds: 4), context)
                                  .then((_) {
                                if (context.mounted) {
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop();
                                }

                                _refreshTableData(context);
                                Provider.of<OfrecimientosProvider>(context,
                                        listen: false)
                                    .refreshOfrecimientos(context, user);
                              });
                            });
                          } else {
                            print("Error al autorizar el tren");
                            if (context.mounted) {
                              Navigator.of(context).pop();
                              Future.delayed(Duration.zero, () {
                                showFlushbar(
                                    'Error al autorizar el tren',
                                    Colors.red,
                                    const Duration(seconds: 4),
                                    context);
                              });
                            }
                          }
                        } catch (e) {
                          print('Error al formatear la fecha y hora: $e');
                          if (context.mounted) {
                            Navigator.of(context).pop();
                            showFlushbar(
                                'Error al autorizar el tren',
                                Colors.red,
                                const Duration(seconds: 4),
                                context);
                          }
                        }
                      } else {
                        print('Formulario no válido');
                      }
                    },
              style: buttonStyle(),
              child: const Row(
                children: [
                  Text('Aceptar',
                      style: TextStyle(color: Colors.green, fontSize: 18.0)),
                  SizedBox(width: 8),
                  Icon(Icons.check, color: Colors.green, size: 18.0),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // METODO PARA ACTUALIAR LOS DATOS DE LA TABLA
  void _refreshTableData(BuildContext context) async {
    final trenYFechaModel =
        Provider.of<TrenYFechaModel>(context, listen: false);
    final tren = trenYFechaModel.trenYFecha;

    final tablesProvider =
        Provider.of<TablesTrainsProvider>(context, listen: false);

    await tablesProvider.tableDataTrain(context, tren!);

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

  Future<void> showFlushbar(
      String message, Color color, Duration time, BuildContext context) {
    return Flushbar(
      duration: time,
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

  Widget _buildTextField(String label, String value,
      {bool isEditable = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 10.0),
        Expanded(
          child: TextFormField(
            initialValue: value,
            enabled: isEditable,
            style: TextStyle(
              fontSize: 18.0,
              color: isEditable ? Colors.black : Colors.grey.shade600,
              fontWeight: FontWeight.normal,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: isEditable ? Colors.white : Colors.grey.shade300,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.0),
                borderSide: const BorderSide(color: Colors.grey, width: 1.0),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
