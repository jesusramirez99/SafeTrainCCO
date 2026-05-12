import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safe_train_cco/modelos/historico_validacion_trenes_provider.dart';


class HoverTrainTextHistory extends StatefulWidget {
  final String id;
  final String tcn;
  final String ffc;
  final String station;
  final Color color;

  const HoverTrainTextHistory({
    super.key, 
    required this.id, 
    required this.tcn,
    required this.ffc,
    required this.station, 
    required this.color
  });

  @override
  State<StatefulWidget> createState() => _HoverTrainTextHistoryState();

}

class _HoverTrainTextHistoryState extends State<HoverTrainTextHistory> {
  bool isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (event) => setState(() => isHovering = true),
      onExit: (event) => setState(() => isHovering = false),
      child:  GestureDetector(
        onTap: () {
          final provider = Provider.of<HistorialValidacionesProvider>(context, listen: false);
          provider.informationHistoryTrain(
            widget.tcn, 
            widget.ffc, 
            widget.station
          );
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              style: TextStyle(
                fontSize: 15.0,
                fontWeight: isHovering ? FontWeight.w900 : FontWeight.bold,
                color: isHovering ? Colors.blue : widget.color,
              ),
              child: Text(widget.id),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutCubic,
              margin: const EdgeInsets.only(top: 1),
              height: 2,
              width: isHovering ? 85 : 0,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}