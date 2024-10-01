import 'package:flutter/material.dart';
import 'package:my_workout/dialogs/goal/goal_cardio_dialog.dart';
import 'package:my_workout/dialogs/goal/goal_weight_dialog.dart';
import 'package:my_workout/models/goal.dart';

class GoalDialog extends StatelessWidget {
  final Goal goal;
  final bool isNew;

  const GoalDialog({super.key, required this.goal, this.isNew = false});

  @override
  Widget build(BuildContext context) {
    return goal is WeightGoal
        ? GoalWeightDialog(goal: goal as WeightGoal)
        : goal is CardioGoal
            ? GoalCardioDialog(goal: goal as CardioGoal)
            : Container();
  }
}
