import 'package:flutter/material.dart';
import 'package:my_workout/data.dart';
import 'package:my_workout/models/goal.dart';
import 'package:my_workout/utils.dart';
import 'package:my_workout/widgets/icon_text.dart';

class CardioGoalTile extends StatelessWidget {
  final CardioGoal goal;
  final void Function(CardioGoal)? goalEdited;

  const CardioGoalTile({super.key, required this.goal, this.goalEdited});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: goalEdited == null
          ? null
          : () async {
              final newGoal = await goalDialog(context, goal);
              if (newGoal != null) {
                goalEdited!(newGoal as CardioGoal);
              }
            },
      child: Padding(
        padding: const EdgeInsets.only(
          left: 12,
          top: 8,
          bottom: 8,
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (goal.duration != null)
                  IconText(
                    text:
                        '${ui.stat.duration.name}: ${formatDuration(goal.duration!)}',
                    icon: ui.stat.duration.icon,
                    iconColor: ui.stat.duration.color,
                    endGap: 8,
                  ),
                if (goal.heartRate != null)
                  IconText(
                    text: '${ui.stat.heartRate.name}: ${goal.heartRate}',
                    icon: ui.stat.heartRate.icon,
                    iconColor: ui.stat.heartRate.color,
                    endGap: 8,
                  ),
                if (goal.speed != null)
                  IconText(
                    text:
                        '${ui.stat.speed.name}: ${goal.speed!.toStringAsFixed(1)}',
                    icon: ui.stat.speed.icon,
                    iconColor: ui.stat.speed.color,
                    endGap: 8,
                  ),
                if (goal.distance != null)
                  IconText(
                    text:
                        '${ui.stat.distance.name}: ${goal.distance!.toStringAsFixed(1)}',
                    icon: ui.stat.distance.icon,
                    iconColor: ui.stat.distance.color,
                    endGap: 8,
                  ),
                if (goal.intensity != null)
                  IconText(
                    text:
                        '${ui.stat.intensity.name}: ${goal.intensity!.toStringAsFixed(1)}',
                    icon: ui.stat.intensity.icon,
                    iconColor: ui.stat.intensity.color,
                    endGap: 8,
                  ),
                if (goal.level != null)
                  IconText(
                    text:
                        '${ui.stat.level.name}: ${goal.level!.toStringAsFixed(1)}',
                    icon: ui.stat.level.icon,
                    iconColor: ui.stat.level.color,
                    endGap: 8,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
