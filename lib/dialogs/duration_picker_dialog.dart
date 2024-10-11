import 'package:duration_picker/duration_picker.dart';
import 'package:flutter/material.dart';
import 'package:my_workout/utils.dart';

class DurationPickerDialog extends StatefulWidget {
  final Widget title;
  final Duration value;
  final Duration minValue;
  final Duration? maxValue;
  final BaseUnit baseUnit;
  final bool autoSave;
  final List<Duration> offsets;

  const DurationPickerDialog({
    super.key,
    required this.title,
    required this.value,
    required this.minValue,
    required this.maxValue,
    this.baseUnit = BaseUnit.minute,
    this.autoSave = true,
    this.offsets = const [],
  });

  @override
  State<DurationPickerDialog> createState() => _DurationPickerDialogState();
}

class _DurationPickerDialogState extends State<DurationPickerDialog> {
  Duration _value = Duration.zero;

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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.offsets.isNotEmpty)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final offset in widget.offsets) ...[
                    ElevatedButton(
                      style: elevatedButtonStyle,
                      onPressed: () => _addValue(-offset),
                      child: Text('-${formatDuration(offset)}'),
                    ),
                    SizedBox(width: 8),
                  ]
                ],
              ),
            Card(
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: DurationPicker(
                  duration: _value,
                  lowerBound: widget.minValue,
                  upperBound: widget.maxValue,
                  baseUnit: widget.baseUnit,
                  onChange: (value) => setState(() => _value = value),
                ),
              ),
            ),
            if (widget.offsets.isNotEmpty)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final offset in widget.offsets) ...[
                    ElevatedButton(
                      style: elevatedButtonStyle,
                      onPressed: () => _addValue(offset),
                      child: Text('+${formatDuration(offset)}'),
                    ),
                    SizedBox(width: 8),
                  ]
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

  void _addValue(Duration duration) {
    final newDuration = _value + duration;
    _setRest(newDuration <= widget.minValue ? widget.minValue : newDuration);
  }

  void _setRest(Duration duration) {
    setState(() => _value = duration);
  }
}
