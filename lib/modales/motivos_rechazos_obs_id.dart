import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safe_train_cco/modelos/rechazos_observaciones_data_provider.dart';

class RechazoObsTren extends StatelessWidget {
  const RechazoObsTren({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RechazosObservacionesData>(context);

    return AlertDialog(
      title: const Center(
        child: Text(
          'Motivos de Rechazo',
          style: TextStyle(
            fontSize: 22.0,
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            provider.motivosRechazo.isNotEmpty
                ? Column(
                    children: provider.motivosRechazo
                        .map(
                          (motivo) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.warning,
                                  color: Colors.orange,
                                  size: 24,
                                ),
                                const SizedBox(width: 10),
                                Flexible(
                                  child: Text(
                                    motivo,
                                    style: TextStyle(
                                      fontSize: 17.0,
                                      color: Colors.grey.shade600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  )
                : const Text(
                    "No hay motivos de rechazo",
                    style: TextStyle(fontSize: 16.0),
                    textAlign: TextAlign.center,
                  ),
            const SizedBox(height: 10),
            const Center(
              child: Text(
                "Observaciones:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 14.0),
            Center(
              child: Text(
                provider.observaciones.isNotEmpty
                    ? provider.observaciones
                    : "Sin observaciones",
                style: TextStyle(fontSize: 17.0, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            "Cerrar",
            style: TextStyle(color: Colors.red, fontSize: 16.0),
          ),
        ),
      ],
    );
  }
}
