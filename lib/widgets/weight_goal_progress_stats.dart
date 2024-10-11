import 'package:flutter/material.dart';
import 'package:my_workout/data.dart';
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
    final info = goal.getInfo();

    final completeRepsCountStr =
        info.completedReps.toStringAsFixed(info.completedReps % 1 == 0 ? 0 : 1);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          alignment: wrapAlignment,
          children: [
            IconText(
              text: '${info.completedSets}/${info.totalSets}',
              icon: ui.stat.sets.icon,
              iconColor: ui.stat.sets.color,
              endGap: 8,
            ),
            IconText(
              text: '$completeRepsCountStr/${info.totalReps}',
              icon: ui.stat.reps.icon,
              iconColor: ui.stat.reps.color,
              endGap: 8,
            ),
            if (goal.goal.weight != 0)
              IconText(
                text:
                    '${info.completedWeight.toStringAsFixed(1)}/${info.totalWeight.toStringAsFixed(1)}',
                icon: ui.stat.weight.icon,
                iconColor: ui.stat.weight.color,
                endGap: 8,
              ),
            IconText(
              text: 'Goal completed by ${info.completedBy.toStringAsFixed(2)}%',
              icon: Icons.query_stats,
              iconColor: Colors.indigo,
            ),
          ],
        ),
      ],
    );
  }
}
