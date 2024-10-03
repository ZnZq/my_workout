import 'package:flutter/material.dart';
import 'package:my_workout/models/weight_goal_progress.dart';
import 'package:my_workout/widgets/icon_text.dart';

class WeightGoalProgressStats extends StatelessWidget {
  final WeightGoalProgress goal;
  final WrapAlignment wrapAlignment;

  const WeightGoalProgressStats({
    super.key,
    required this.goal,
    this.wrapAlignment = WrapAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    final completeSets = goal.completedSets;
    final completeRepsTotal =
        completeSets.map((e) => e.reps).fold(0.0, (a, b) => a + b);
    final completedWeightTotal =
        completeSets.map((e) => e.weight).fold(0.0, (a, b) => a + b);
    final completedWeightAvg = completedWeightTotal == 0
        ? 0
        : completedWeightTotal / completeSets.length;

    final completeRepsCount = completeRepsTotal / completeSets.length;

    final completeRepsCountStr =
        completeRepsCount.toStringAsFixed(completeRepsCount % 1 == 0 ? 0 : 1);

    final maxComplete = goal.sets.length *
        goal.goal.reps *
        (goal.goal.weight == 0 ? 1 : goal.goal.weight);
    final currentComplete = completeSets.length *
        completeRepsTotal *
        (goal.goal.weight == 0 ? 1 : completedWeightAvg);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          alignment: wrapAlignment,
          children: [
            IconText(
              text: '${completeSets.length}/${goal.sets.length}',
              icon: Icons.play_arrow,
              iconColor: Colors.orange,
              endGap: 8,
            ),
            IconText(
              text: '$completeRepsCountStr/${goal.goal.reps}',
              icon: Icons.repeat,
              iconColor: Colors.green,
              endGap: 8,
            ),
            if (goal.goal.weight != 0)
              IconText(
                text:
                    '${completedWeightAvg.toStringAsFixed(1)}/${goal.goal.weight.toStringAsFixed(1)}',
                icon: Icons.fitness_center,
                iconColor: Colors.blue,
                endGap: 8,
              ),
            IconText(
              text:
                  'Goal completed by ${(currentComplete / maxComplete * 100).toStringAsFixed(2)}%',
              icon: Icons.query_stats,
              iconColor: Colors.indigo,
            ),
          ],
        ),
      ],
    );
  }
}
