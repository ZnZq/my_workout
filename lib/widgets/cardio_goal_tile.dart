import 'package:flutter/material.dart';
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
                    text: 'Duration: ${formatDuration(goal.duration!)}',
                    icon: Icons.timer_sharp,
                    iconColor: Colors.blue,
                    endGap: 8,
                  ),
                if (goal.heartRate != null)
                  IconText(
                    text: 'Heart rate: ${goal.heartRate}',
                    icon: Icons.favorite,
                    iconColor: Colors.red,
                    endGap: 8,
                  ),
                if (goal.speed != null)
                  IconText(
                    text: 'Speed: ${goal.speed!.toStringAsFixed(1)}',
                    icon: Icons.speed,
                    iconColor: Colors.orange,
                    endGap: 8,
                  ),
                if (goal.distance != null)
                  IconText(
                    text: 'Distance: ${goal.distance!.toStringAsFixed(1)}',
                    icon: Icons.location_on,
                    iconColor: Colors.indigo,
                    endGap: 8,
                  ),
                if (goal.intensity != null)
                  IconText(
                    text: 'Intensity: ${goal.intensity!.toStringAsFixed(1)}',
                    icon: Icons.bolt,
                    iconColor: Colors.green,
                    endGap: 8,
                  ),
                if (goal.level != null)
                  IconText(
                    text: 'Level: ${goal.level!.toStringAsFixed(1)}',
                    icon: Icons.leaderboard,
                    iconColor: Colors.yellow,
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
