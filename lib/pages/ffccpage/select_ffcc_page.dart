import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safe_train_cco/modelos/user_provider.dart';
import 'package:safe_train_cco/pages/login/login_page.dart';

class SelectFC extends StatefulWidget {
  const SelectFC({super.key});

  @override
  State<SelectFC> createState() => _SelectFCState();
}

class _SelectFCState extends State<SelectFC> {
  String? _dropdownValue;
  String selectedItemFC = 'FFCC';

  @override
  void initState() {
    super.initState();
    _dropdownValue = 'FFCC';
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 102, 100, 97),
      body: Center(
        child: Container(
            width: 450.0,
            height: 435.0,
            color: const Color.fromRGBO(5, 5, 5, 0.6),
            child: Center(
                child: Column(
              children: <Widget>[
                const SizedBox(height: 25.0),
                _logoGMXT(),
                const SizedBox(height: 50.0),
                _titulo(),
                const SizedBox(height: 40.0),
                SizedBox(
                  width: 200.0,
                  height: 50.0,
                  child: _dropSelectFC(context),
                ),
                const SizedBox(height: 15.0),
                _botonEjecutar(context),
                const Spacer(),
                const Text(
                  'Copyright © 2025  |  Digital GMXT® ',
                  style: TextStyle(color: Colors.white, fontSize: 10.0),
                ),
              ],
            ))),
      ),
    );
  }

  // IMAGEN LOGO GMXT
  Image _logoGMXT() {
    return Image.asset(
      'assets/images/gmxt-logo.png',
      width: 160.0,
      height: 70.0,
      fit: BoxFit.cover,
    );
  }

  // TEXTO TITULO TREN SEGURO
  Text _titulo() {
    return const Text(
      'Tren Seguro CCO',
      style: TextStyle(
          color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.w200),
    );
  }

  DropdownButtonFormField<String> _dropSelectFC(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: _estiloDrop(),
      value: _dropdownValue,
      onChanged: (String? newValue) {
        if (newValue != 'FFCC') {
          setState(() {
            _dropdownValue = newValue;
          });
          // Guardar en el Provider
          Provider.of<FfccProvider>(context, listen: false)
              .setSelectedItem(newValue!);
        }
      },
      items: <String>['FFCC', 'FXE', 'FSRR']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          enabled: value != 'FFCC',
          child: Text(
            value,
            style: TextStyle(
                color: value == 'FFCC'
                    ? Colors.blue.shade600
                    : Colors.grey.shade600),
          ), // Deshabilita la primera opción
        );
      }).toList(),
    );
  }

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

  // Botón Ejecutar
  ElevatedButton _botonEjecutar(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        if (_dropdownValue == 'FFCC') {
          Flushbar(
            duration: const Duration(seconds: 4),
            backgroundColor: Colors.red,
            flushbarPosition: FlushbarPosition.TOP,
            margin: const EdgeInsets.all(1.0),
            borderRadius: BorderRadius.circular(5.0),
            messageText: const Text(
              'Por favor, seleccione un FFCC válido.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
          ).show(context);
        } else {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const Login(),
            ),
            (Route<dynamic> route) => false,
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(235, 114, 146, 251),
        padding: const EdgeInsets.symmetric(
          horizontal: 55.0,
          vertical: 10.0,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2.0),
        ),
      ),
      child: const Text(
        'Ingresar',
        style: TextStyle(color: Colors.white, fontSize: 12.0),
      ),
    );
  }
}
