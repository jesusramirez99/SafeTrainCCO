import 'package:flutter/material.dart';

class ComparacionConsistModal extends StatefulWidget {
  const ComparacionConsistModal({Key? key}) : super(key: key);

  @override
  _ComparacionConsistModalState createState() =>
      _ComparacionConsistModalState();
}

class _ComparacionConsistModalState extends State<ComparacionConsistModal> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Center(
        child: Text(
          'Comparación de Consist',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20.0,
              color: Colors.grey.shade600),
        ),
      ),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Existen diferencias entre el consist ofrecido y el actual',
            style: TextStyle(fontSize: 18.0, color: Colors.red),
          ),
          SizedBox(height: 20),
          CircularProgressIndicator(),
        ],
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
