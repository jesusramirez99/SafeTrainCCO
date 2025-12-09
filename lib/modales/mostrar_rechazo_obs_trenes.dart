import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safe_train_cco/modelos/tablas_tren_provider.dart';

class MostrarRechazoObsTrenes extends StatelessWidget {
  const MostrarRechazoObsTrenes({super.key});

  @override
  Widget build(BuildContext context) {
    final idTren = Provider.of<TablesTrainsProvider>(context);

    return AlertDialog(
      title: const Center(
        child: Text(
          'Motivos de Rechazo',
          style: TextStyle(
            fontSize: 22.0,
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            idTren.motivosRechazo.isNotEmpty
                ? Column(
                    children: idTren.motivosRechazo
                        .map((motivo) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 5.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.warning,
                                      color: Colors.orange),
                                  const SizedBox(
                                      width:
                                          8.0), 
                                  Text(
                                    motivo,
                                    style: TextStyle(
                                        fontSize: 17.0,
                                        color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                            ))
                        .toList(),
                  )
                : const Text(
                    'No hay motivos de rechazo',
                    style: TextStyle(fontSize: 16.0),
                  ),
            const SizedBox(height: 17.0),
            const Text(
              'Observaciones:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
            ),
            const SizedBox(height: 14.0),
            Text(
              idTren.observaciones.isNotEmpty
                  ? idTren.observaciones
                  : 'Sin observaciones',
              style: TextStyle(fontSize: 17.0, color: Colors.grey.shade600),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Cerrar',
            style: TextStyle(color: Colors.red, fontSize: 16.0),
          ),
        ),
      ],
    );
  }
}