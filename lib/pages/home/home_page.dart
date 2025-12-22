import 'package:flutter/material.dart';
import 'package:safe_train_cco/widgets/app_bar.dart';
import 'package:safe_train_cco/widgets/cuerpo.dart';
import 'package:safe_train_cco/widgets/menu_lateral.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => HomeState();
}

class HomeState extends State<Home> {
  bool _showDataTrain = true;
  bool _showInfoTrain = false;
  bool _showIndicatorTrain = false;
  bool _showValidatorTrain = false;
  bool _showDate = false;
  bool _showHora = false;

  final GlobalKey<CuerpoState> _cuerpoKey = GlobalKey<CuerpoState>();
  final TextEditingController _idTrainController = TextEditingController();
  final TextEditingController _fechaController = TextEditingController();
  final TextEditingController _estacionController = TextEditingController();
  final FocusNode _idTrainFocusNode = FocusNode();

  void _toggleTableData() {
    setState(() {
      _showDataTrain = true;
      _showInfoTrain = false;
      _showIndicatorTrain = false;
    });
  }

  void _toggleTableIndicator() {
    setState(() {
      if (_showIndicatorTrain) {
        _showDataTrain = true;
        _showIndicatorTrain = false;
      } else {
        _showDataTrain = false;
        _showInfoTrain = false;
        _showIndicatorTrain = true;
        _showValidatorTrain = false;
      }
    });
  }

  void _toggleTableInfo() {
    setState(() {
      if (_showInfoTrain) {
        _showDataTrain = true;
        _showInfoTrain = false;
      } else {
        _showDataTrain = false;
        _showInfoTrain = true;
        _showIndicatorTrain = false;
        _showValidatorTrain = false;
      }
    });
  }

  void _showValidatorTrainText() {
    setState(() {
      _showValidatorTrain = !_showValidatorTrain;
    });
  }

  void _showFecha() {
    setState(() {
      _showDate = !_showDate;
    });
  }

  void _showTime() {
    setState(() {
      _showHora = !_showHora;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        idTrainController: _idTrainController,
        idTrainFocusNode: _idTrainFocusNode,
      ),
      backgroundColor: Colors.white,
      body: Row(
        children: <Widget>[
          MenuLateral(
            toggleTableData: _toggleTableData,
            toggleTableIndicator: _toggleTableIndicator,
            toggleTableInfo: _toggleTableInfo,
            showValidateText: _showValidatorTrainText,
            showFecha: _showFecha,
            showHora: _showTime,
          ),
          Expanded(
            child: Cuerpo(
              key: _cuerpoKey,
              showDataTrain: _showDataTrain,
              showInfoTrain: _showInfoTrain,
              showIndicatorTrain: _showIndicatorTrain,
              showValidatorTrain: _showValidatorTrain,
              showFecha: _showDate,
              showTime: _showHora,
              idTrainController: _idTrainController,
              fechaController: _fechaController,
              focusNode: _idTrainFocusNode, 
            ),
          ),
        ],
      ),
    );
  }
}
