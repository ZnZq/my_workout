import 'package:duration_picker/duration_picker.dart';
import 'package:flutter/material.dart';
import 'package:my_workout/models/goal.dart';
import 'package:my_workout/utils.dart';
import 'package:my_workout/widgets/workout_expansion.dart';
import 'package:numberpicker/numberpicker.dart';

class GoalWeightDialog extends StatefulWidget {
  final WeightGoal goal;

  const GoalWeightDialog({super.key, required this.goal});

  @override
  State<GoalWeightDialog> createState() => _GoalWeightDialogState();
}

class _GoalWeightDialogState extends State<GoalWeightDialog> {
  int sets = 1;
  int reps = 1;
  double weight = 0;
  Duration rest = Duration(minutes: 1);

  final int minSets = 1;
  final int maxSets = 999;
  final int minReps = 1;
  final int maxReps = 999;
  final double minWeight = 0;
  final double maxWeight = 999;
  final Duration minRest = Duration.zero;

  @override
  void initState() {
    sets = widget.goal.sets;
    reps = widget.goal.reps;
    weight = widget.goal.weight;
    rest = widget.goal.rest;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final elevatedButtonStyle = ElevatedButton.styleFrom(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      minimumSize: Size(0, 0),
      elevation: 0,
    );

    return AlertDialog(
      title: Text('${widget.goal.executeMethod.name} goal'),
      actionsPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sets: $sets'),
            Row(
              children: [
                ElevatedButton(
                  style: elevatedButtonStyle,
                  onPressed: () => setState(
                    () => sets = (sets - 10).clamp(minSets, maxSets),
                  ),
                  child: Text('-10'),
                ),
                Expanded(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 150),
                    child: Center(
                      child: Card(
                        child: NumberPicker(
                          axis: Axis.horizontal,
                          itemWidth: 45,
                          value: sets,
                          minValue: minSets,
                          maxValue: maxSets,
                          onChanged: (value) => setState(() => sets = value),
                        ),
                      ),
                    ),
                  ),
                ),
                ElevatedButton(
                  style: elevatedButtonStyle,
                  onPressed: () => setState(
                    () => sets = (sets + 10).clamp(minSets, maxSets),
                  ),
                  child: Text('+10'),
                ),
              ],
            ),
            Text('Reps: $reps'),
            Row(
              children: [
                ElevatedButton(
                  style: elevatedButtonStyle,
                  onPressed: () => setState(
                    () => reps = (reps - 10).clamp(minReps, maxReps),
                  ),
                  child: Text('-10'),
                ),
                Expanded(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 150),
                    child: Center(
                      child: Card(
                        child: NumberPicker(
                          axis: Axis.horizontal,
                          itemWidth: 45,
                          value: reps,
                          minValue: minReps,
                          maxValue: maxReps,
                          onChanged: (value) => setState(() => reps = value),
                        ),
                      ),
                    ),
                  ),
                ),
                ElevatedButton(
                  style: elevatedButtonStyle,
                  onPressed: () => setState(
                    () => reps = (reps + 10).clamp(minReps, maxReps),
                  ),
                  child: Text('+10'),
                ),
              ],
            ),
            Text('Weight: ${weight.toStringAsFixed(1)}'),
            Row(
              children: [
                ElevatedButton(
                  style: elevatedButtonStyle,
                  onPressed: () => setState(
                    () => weight = (weight - 5.0).clamp(minWeight, maxWeight),
                  ),
                  child: Text('-5'),
                ),
                Expanded(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 150),
                    child: Card(
                      child: DecimalNumberPicker(
                        axis: Axis.horizontal,
                        itemWidth: 45,
                        itemHeight: 45,
                        value: weight,
                        minValue: minWeight.toInt(),
                        maxValue: maxWeight.toInt(),
                        onChanged: (value) => setState(() => weight = value),
                      ),
                    ),
                  ),
                ),
                ElevatedButton(
                  style: elevatedButtonStyle,
                  onPressed: () => setState(
                    () => weight = (weight + 5.0).clamp(minWeight, maxWeight),
                  ),
                  child: Text('+5'),
                ),
              ],
            ),
            WorkoutExpansion(
              title: 'Rest',
              displayValue: formatDuration(rest),
              actions: [
                ElevatedButton(
                  style: elevatedButtonStyle,
                  onPressed: () => _addRest(Duration(seconds: -30)),
                  child: Text('-30s'),
                ),
                SizedBox(width: 4),
                ElevatedButton(
                  style: elevatedButtonStyle,
                  onPressed: () => _addRest(Duration(seconds: 30)),
                  child: Text('+30s'),
                ),
              ],
              child: DurationPicker(
                duration: rest,
                lowerBound: minRest,
                baseUnit: BaseUnit.second,
                onChange: _setRest,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(WeightGoal(
              sets: sets,
              reps: reps,
              weight: weight,
              rest: rest,
            ));
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _addRest(Duration duration) {
    final newDuration = rest + duration;
    _setRest(newDuration <= minRest ? minRest : newDuration);
  }

  void _setRest(Duration duration) {
    setState(() => rest = duration);
  }
}
