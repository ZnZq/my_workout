import 'package:duration_picker/duration_picker.dart' show BaseUnit;
import 'package:flutter/material.dart';
import 'package:my_workout/dialogs/duration_picker_dialog.dart';
import 'package:my_workout/utils.dart';
import 'package:my_workout/widgets/icon_text.dart';

class DurationStatTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final double iconSize;
  final String title;
  final double titleFontSize;
  final Duration value;
  final double valueFontSize;
  final void Function(Duration value)? onChanged;
  final String Function(Duration value)? valueFormatter;
  final Duration? minValue;
  final Duration? maxValue;
  final List<Duration> offsets;
  final BaseUnit baseUnit;

  const DurationStatTile({
    super.key,
    required this.icon,
    required this.iconColor,
    this.iconSize = 24,
    required this.title,
    this.titleFontSize = 16,
    required this.value,
    this.valueFontSize = 16,
    this.onChanged,
    this.valueFormatter,
    this.minValue,
    this.maxValue,
    this.offsets = const [
      Duration(seconds: 30),
      Duration(minutes: 1),
      Duration(minutes: 5),
    ],
    this.baseUnit = BaseUnit.minute,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onChanged != null ? () => _onTap(context) : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: iconSize),
            Text(title, style: TextStyle(fontSize: titleFontSize)),
            Text(_formatValue(value),
                style: TextStyle(fontSize: valueFontSize)),
          ],
        ),
      ),
    );
  }

  String _formatValue(Duration value) {
    if (valueFormatter != null) {
      return valueFormatter!(value);
    }

    return formatDuration(value);
  }

  void _onTap(BuildContext context) async {
    final durationValue = await showDialog<Duration?>(
      context: context,
      builder: (context) {
        return DurationPickerDialog(
          title: Center(
            child: IconText(icon: icon, text: title, iconColor: iconColor),
          ),
          value: value,
          minValue: minValue ?? Duration.zero,
          maxValue: maxValue,
          offsets: offsets,
          baseUnit: baseUnit,
        );
      },
    );
    if (durationValue != null) {
      onChanged!(durationValue);
    }
  }
}
