import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum PickerMode { single, range }
class CustomDatePickerController {
  final TextEditingController textController = TextEditingController();

  DateTime? singleDate;
  DateTimeRange? range;

  void clear() {
    textController.clear();
    singleDate = null;
    range = null;
  }
}

class CustomDatePicker extends StatefulWidget {
  final PickerMode mode;
  final String label;
  final bool enabled;

  final CustomDatePickerController? controller;

  final void Function(DateTime?)? onSingle;
  final void Function(DateTimeRange?)? onRange;

  const CustomDatePicker({
    super.key,
    required this.mode,
    required this.label,
    this.controller,
    this.onSingle,
    this.onRange,
    this.enabled = true,
  });

  @override
  State<CustomDatePicker> createState() => _CustomDatePickerState();
}

class _CustomDatePickerState extends State<CustomDatePicker> {
  final DateFormat _format = DateFormat('dd/MM/yyyy');
  late final CustomDatePickerController _controller =
      widget.controller ?? CustomDatePickerController();

  Future<void> _pickDate() async {
    if (widget.mode == PickerMode.single) {
      final date = await showDatePicker(
        context: context,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
        initialDate: DateTime.now(),
      );

      if (date != null) {
        _controller.textController.text = _format.format(date);
        _controller.singleDate = date;

        widget.onSingle?.call(date);
      }
    } else {
      final range = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );

      if (range != null) {
        _controller.textController.text =
            "${_format.format(range.start)} - ${_format.format(range.end)}";

        _controller.range = range;

        widget.onRange?.call(range);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      enabled: widget.enabled,
      controller: _controller.textController,
      readOnly: true,
      onTap: widget.enabled ? _pickDate : null,
      decoration: InputDecoration(
        labelText: widget.label,
        suffixIcon: const Icon(Icons.calendar_today),
        border: const OutlineInputBorder(),
      ),
    );
  }
}

