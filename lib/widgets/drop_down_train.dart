import 'package:flutter/material.dart';

class DropDownTrain extends StatefulWidget {
  final bool enabled;

  const DropDownTrain({Key? key, required this.enabled}) : super(key: key);

  @override
  State<DropDownTrain> createState() => _DropDownTrainState();
}

class _DropDownTrainState extends State<DropDownTrain> {
  List<DropdownMenuItem<String>> dropdownItems = [];
  late List<Map<String, dynamic>> listaTrains = [];
  String? selectedItemTrain;

  @override
  void initState() {
    super.initState();
    // Llenar la lista de elementos del dropdown al iniciar el estado
    dropdownItems.add(const DropdownMenuItem(
      value: null,
      child: Text(
        'Seleccione un ID de Tren',
        style: TextStyle(fontSize: 12.0, color: Colors.black),
      ),
    ));
    dropdownItems.addAll(listaTrains.map<DropdownMenuItem<String>>((trenes) {
      return DropdownMenuItem<String>(
        value: trenes['id_trenes'].toString(),
        child: Text(trenes['clave_trenes'].toString()),
      );
    }).toList());
    // Asignar un valor inicial si lo deseas
    selectedItemTrain = dropdownItems.first.value;
  }

  // Estilo DropDown
  Decoration decoracionDropDown() {
    return BoxDecoration(
      border: Border.all(color: Colors.black),
      borderRadius: BorderRadius.circular(4.0),
      color: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      decoration: decoracionDropDown(),
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 160.0,
            height: 35.0,
            child: DropdownButton<String>(
              icon: const Icon(Icons.arrow_drop_down),
              iconSize: 20.0,
              elevation: 16,
              style: const TextStyle(fontSize: 18.0, color: Colors.white),
              underline: Container(),
              value: selectedItemTrain,
              onChanged: widget.enabled
                  ? (String? newValue) {
                      if (newValue != null) {
                        print('id Tren: $newValue');
                        setState(() {
                          selectedItemTrain = newValue;
                        });
                      }
                    }
                  : null, // Si no está habilitado, onChanged es null (deshabilitado)
              items: dropdownItems,
            ),
          ),
        ],
      ),
    );
  }
}
