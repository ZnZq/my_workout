import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

class DecimalNumberPickerDialog extends StatefulWidget {
  final Widget title;
  final double value;
  final int minValue;
  final int maxValue;
  final bool autoSave;
  final List<int> offsets;

  const DecimalNumberPickerDialog({
    super.key,
    required this.title,
    required this.value,
    required this.minValue,
    required this.maxValue,
    this.autoSave = true,
    this.offsets = const [],
  });

  @override
  State<DecimalNumberPickerDialog> createState() =>
      _DecimalNumberPickerDialogState();
}

class _DecimalNumberPickerDialogState extends State<DecimalNumberPickerDialog> {
  double _value = 0;

  @override
  void initState() {
    _value = widget.value;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final elevatedButtonStyle = ElevatedButton.styleFrom(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      minimumSize: Size(0, 0),
      elevation: 0,
    );

    return PopScope(
      canPop: !widget.autoSave,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.of(context).pop(_value);
        }
      },
      child: AlertDialog(
        title: widget.title,
        content: Row(
          children: [
            if (widget.offsets.isNotEmpty)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final offset in widget.offsets)
                    ElevatedButton(
                      style: elevatedButtonStyle,
                      onPressed: () => setState(
                        () => _value = (_value - offset).clamp(
                            widget.minValue + 0.0, widget.maxValue + 0.0),
                      ),
                      child: Text('-$offset'),
                    ),
                ],
              ),
            Expanded(
              child: Card(
                child: DecimalNumberPicker(
                  axis: Axis.vertical,
                  itemHeight: 40,
                  itemWidth: 40,
                  value: _value,
                  textStyle: TextStyle(fontSize: 14),
                  selectedTextStyle: TextStyle(fontSize: 20),
                  minValue: widget.minValue,
                  maxValue: widget.maxValue,
                  onChanged: (value) => setState(() => _value = value),
                ),
              ),
            ),
            if (widget.offsets.isNotEmpty)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final offset in widget.offsets)
                    ElevatedButton(
                      style: elevatedButtonStyle,
                      onPressed: () => setState(
                        () => _value = (_value +
                                (_value == widget.minValue &&
                                        widget.minValue != 0
                                    ? offset - 1
                                    : offset))
                            .clamp(
                                widget.minValue + 0.0, widget.maxValue + 0.0),
                      ),
                      child: Text('+$offset'),
                    ),
                ],
              ),
          ],
        ),
        actions: widget.autoSave
            ? null
            : [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(_value),
                  child: Text('Save'),
                ),
              ],
      ),
    );
  }
}
