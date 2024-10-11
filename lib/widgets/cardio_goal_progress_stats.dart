import 'package:flutter/material.dart';
import 'package:my_workout/data.dart';
import 'package:my_workout/models/cardio_goal_progress.dart';
import 'package:my_workout/utils.dart';
import 'package:my_workout/widgets/icon_text.dart';

class CardioGoalProgressStats extends StatelessWidget {
  final CardioGoalProgress goal;
  final WrapAlignment wrapAlignment;

  const CardioGoalProgressStats({
    super.key,
    required this.goal,
    this.wrapAlignment = WrapAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          alignment: wrapAlignment,
          children: [
            if (goal.goal.duration != null)
              IconText(
                text:
                    '${formatDuration(goal.actual.duration!)}/${formatDuration(goal.goal.duration!)}',
                icon: ui.stat.duration.icon,
                iconColor: ui.stat.duration.color,
                endGap: 8,
              ),
            if (goal.goal.heartRate != null)
              IconText(
                text: '${goal.actual.heartRate}/${goal.goal.heartRate}',
                icon: ui.stat.heartRate.icon,
                iconColor: ui.stat.heartRate.color,
                endGap: 8,
              ),
            if (goal.goal.speed != null)
              IconText(
                text:
                    '${goal.actual.speed!.toStringAsFixed(1)}/${goal.goal.speed!.toStringAsFixed(1)}',
                icon: ui.stat.speed.icon,
                iconColor: ui.stat.speed.color,
                endGap: 8,
              ),
            if (goal.goal.distance != null)
              IconText(
                text:
                    '${goal.actual.distance!.toStringAsFixed(1)}/${goal.goal.distance!.toStringAsFixed(1)}',
                icon: ui.stat.distance.icon,
                iconColor: ui.stat.distance.color,
                endGap: 8,
              ),
            if (goal.goal.intensity != null)
              IconText(
                text:
                    '${goal.actual.intensity!.toStringAsFixed(1)}/${goal.goal.intensity!.toStringAsFixed(1)}',
                icon: ui.stat.intensity.icon,
                iconColor: ui.stat.intensity.color,
                endGap: 8,
              ),
            if (goal.goal.level != null)
              IconText(
                text:
                    '${goal.actual.level!.toStringAsFixed(1)}/${goal.goal.level!.toStringAsFixed(1)}',
                icon: ui.stat.level.icon,
                iconColor: ui.stat.level.color,
                endGap: 8,
              ),
            if (goal.goal.incline != null)
              IconText(
                text:
                    '${goal.actual.incline!.toStringAsFixed(1)}/${goal.goal.incline!.toStringAsFixed(1)}',
                icon: ui.stat.incline.icon,
                iconColor: ui.stat.incline.color,
                endGap: 8,
              ),
          ],
        ),
      ],
    );
  }
}
