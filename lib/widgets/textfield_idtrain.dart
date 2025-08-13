import 'package:flutter/material.dart';

class TextFieldIdTrain extends StatefulWidget {
  final bool isEnabled;
  final FocusNode focusNode;
  final TextEditingController idTrainController;

  const TextFieldIdTrain(
      {super.key,
      required this.idTrainController,
      required this.isEnabled,
      required this.focusNode});

  @override
  State<TextFieldIdTrain> createState() => TextFieldIdTrainState();
}

class TextFieldIdTrainState extends State<TextFieldIdTrain> {
  // Estilo texto del textfield
  InputDecoration decorationText() {
    return InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
      errorStyle: TextStyle(height: 1, color: Colors.red.shade100),
      errorMaxLines: 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55.0,
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 160,
            height: 55.0,
            child: Column(
              children: <Widget>[
                Expanded(
                  child: TextFormField(
                    controller: widget.idTrainController,
                    focusNode: widget.focusNode,
                    enabled: widget.isEnabled,
                    onChanged: (text) {
                      widget.idTrainController.text = text.toUpperCase();
                      widget.idTrainController.selection =
                          TextSelection.fromPosition(TextPosition(
                              offset: widget.idTrainController.text.length));
                    },
                    decoration: decorationText().copyWith(
                      fillColor: widget.isEnabled
                          ? Colors.white
                          : Colors.grey.shade300,
                      filled: true,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'ingresa el id del tren';
                      }
                      return null;
                    },
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
