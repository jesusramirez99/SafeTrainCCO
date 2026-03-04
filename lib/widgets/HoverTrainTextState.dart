import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safe_train_cco/modelos/tablas_tren_provider.dart';

class HoverTrainText extends StatefulWidget {
  final String id;
  final String station;
  final Color color;

  const HoverTrainText({
    super.key, 
    required this.id, 
    required this.station, 
    required this.color
  });

  @override
  State<StatefulWidget> createState() => _HoverTrainTextState();

}


class _HoverTrainTextState extends State<HoverTrainText> {
  bool isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (event) => setState(() => isHovering = true),
      onExit: (event) => setState(() => isHovering = false),
      child:  GestureDetector(
        onTap: () {
            final trainProvider = Provider.of<TablesTrainsProvider>(context, listen: false);
            trainProvider.tableDataTrain(
            context, 
            widget.id,  
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
        )
        

        
      ),
    );
  }
}