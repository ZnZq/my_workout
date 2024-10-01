import 'package:flutter/material.dart';
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
                icon: Icons.timer_sharp,
                iconColor: Colors.blue,
                endGap: 8,
              ),
            if (goal.goal.heartRate != null)
              IconText(
                text: '${goal.actual.heartRate}/${goal.goal.heartRate}',
                icon: Icons.favorite,
                iconColor: Colors.red,
                endGap: 8,
              ),
            if (goal.goal.speed != null)
              IconText(
                text:
                    '${goal.actual.speed!.toStringAsFixed(1)}/${goal.goal.speed!.toStringAsFixed(1)}',
                icon: Icons.speed,
                iconColor: Colors.orange,
                endGap: 8,
              ),
            if (goal.goal.distance != null)
              IconText(
                text:
                    '${goal.actual.distance!.toStringAsFixed(1)}/${goal.goal.distance!.toStringAsFixed(1)}',
                icon: Icons.location_on,
                iconColor: Colors.indigo,
                endGap: 8,
              ),
            if (goal.goal.intensity != null)
              IconText(
                text:
                    '${goal.actual.intensity!.toStringAsFixed(1)}/${goal.goal.intensity!.toStringAsFixed(1)}',
                icon: Icons.bolt,
                iconColor: Colors.green,
                endGap: 8,
              ),
            if (goal.goal.level != null)
              IconText(
                text:
                    '${goal.actual.level!.toStringAsFixed(1)}/${goal.goal.level!.toStringAsFixed(1)}',
                icon: Icons.leaderboard,
                iconColor: Colors.yellow,
                endGap: 8,
              ),
          ],
        ),
      ],
    );
  }
}
