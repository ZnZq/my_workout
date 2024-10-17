import 'package:duration_picker/duration_picker.dart';
import 'package:flutter/material.dart';
import 'package:my_workout/data.dart';
import 'package:my_workout/models/goal.dart';
import 'package:my_workout/widgets/duration_stat_tile.dart';
import 'package:my_workout/widgets/num_stat_tile.dart';

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
  Duration rest = const Duration(minutes: 1);

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
    return AlertDialog(
      title: Text('${widget.goal.executeMethod.name} goal'),
      actionsPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      content: SizedBox(
        width: double.maxFinite,
        child: GridView.count(
          shrinkWrap: true,
          crossAxisCount: 2,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1 / 1,
          children: [
            NumStatTile<int>(
              icon: ui.stat.sets.icon,
              iconColor: ui.stat.sets.color,
              title: ui.stat.sets.name,
              value: sets,
              onChanged: (value) => setState(() => sets = value),
              minValue: ui.stat.sets.minValue,
              maxValue: ui.stat.sets.maxValue,
            ),
            NumStatTile<int>(
              icon: ui.stat.reps.icon,
              iconColor: ui.stat.reps.color,
              title: ui.stat.reps.name,
              value: reps,
              onChanged: (value) => setState(() => reps = value),
              minValue: ui.stat.reps.minValue,
              maxValue: ui.stat.reps.maxValue,
            ),
            NumStatTile<double>(
              icon: ui.stat.weight.icon,
              iconColor: ui.stat.weight.color,
              title: ui.stat.weight.name,
              value: weight,
              onChanged: (value) => setState(() => weight = value),
              minValue: ui.stat.weight.minValue,
              maxValue: ui.stat.weight.maxValue,
            ),
            DurationStatTile(
              icon: ui.stat.rest.icon,
              iconColor: ui.stat.rest.color,
              title: ui.stat.rest.name,
              baseUnit: BaseUnit.second,
              value: rest,
              onChanged: (value) => setState(() => rest = value),
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
              id: widget.goal.id,
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
}
