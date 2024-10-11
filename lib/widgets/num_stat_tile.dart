import 'package:flutter/material.dart';
import 'package:my_workout/dialogs/decimal_number_picker_dialog.dart';
import 'package:my_workout/dialogs/integer_number_picker_dialog.dart';
import 'package:my_workout/utils.dart';
import 'package:my_workout/widgets/icon_text.dart';

class NumStatTile<T> extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final double iconSize;
  final String title;
  final double titleFontSize;
  final T value;
  final double valueFontSize;
  final void Function(T value)? onChanged;
  final String Function(T value)? valueFormatter;
  final int? minValue;
  final int? maxValue;
  final List<int> offsets;

  const NumStatTile({
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
    this.offsets = const [1, 5, 10],
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

  String _formatValue(T value) {
    if (valueFormatter != null) {
      return valueFormatter!(value);
    }

    if (value is double) {
      return (value as double).toStringAsFixed(1);
    }

    return value.toString();
  }

  void _onTap(BuildContext context) async {
    final type = typeOf<T>();
    if (type == double) {
      await _onDecimalChange(context);
    } else if (type == int) {
      await _onIntegerChange(context);
    }
  }

  Future<void> _onIntegerChange(BuildContext context) async {
    final intValue = await showDialog<int?>(
      context: context,
      builder: (context) {
        return IntegerNumberPickerDialog(
          title: Center(
            child: IconText(icon: icon, text: title, iconColor: iconColor),
          ),
          value: value as int,
          minValue: minValue ?? 0,
          maxValue: maxValue ?? 999,
          offsets: offsets,
        );
      },
    );
    if (intValue != null) {
      onChanged!(intValue as T);
    }
  }

  Future<void> _onDecimalChange(BuildContext context) async {
    final doubleValue = await showDialog<double?>(
      context: context,
      builder: (context) {
        return DecimalNumberPickerDialog(
          title: Center(
            child: IconText(icon: icon, text: title, iconColor: iconColor),
          ),
          value: value as double,
          minValue: minValue ?? 0,
          maxValue: maxValue ?? 999,
          offsets: offsets,
        );
      },
    );
    if (doubleValue != null) {
      onChanged!(doubleValue as T);
    }
  }
}
