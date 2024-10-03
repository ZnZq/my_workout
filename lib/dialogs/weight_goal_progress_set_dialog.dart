import 'package:flutter/material.dart';
import 'package:my_workout/models/weight_goal_progress_set.dart';
import 'package:numberpicker/numberpicker.dart';

class WeightGoalProgressSetDialog extends StatefulWidget {
  final WeightGoalProgressSet set;

  const WeightGoalProgressSetDialog({super.key, required this.set});

  @override
  State<WeightGoalProgressSetDialog> createState() =>
      _WeightGoalProgressSetDialogState();
}

class _WeightGoalProgressSetDialogState
    extends State<WeightGoalProgressSetDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit set progress'),
      contentPadding: const EdgeInsets.only(left: 16, right: 16, top: 16),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Text('Reps: ${widget.set.reps}'),
                    ),
                    Card(
                      child: NumberPicker(
                        axis: Axis.horizontal,
                        itemWidth: 45,
                        value: widget.set.reps,
                        minValue: 0,
                        maxValue: 999,
                        onChanged: (value) =>
                            setState(() => widget.set.reps = value),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (widget.set.weight != 0)
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Text(
                          'Weight: ${widget.set.weight.toStringAsFixed(1)}',
                        ),
                      ),
                      Card(
                        child: DecimalNumberPicker(
                          axis: Axis.horizontal,
                          itemWidth: 45,
                          itemHeight: 45,
                          value: widget.set.weight,
                          minValue: 0,
                          maxValue: 999,
                          onChanged: (value) =>
                              setState(() => widget.set.weight = value),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            )
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(widget.set);
          },
          child: const Text('Close'),
        ),
      ],
    );
  }
}
