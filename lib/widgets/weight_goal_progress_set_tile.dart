import 'package:flutter/material.dart';
import 'package:my_workout/data.dart';
import 'package:my_workout/models/progress_status.dart';
import 'package:my_workout/models/weight_goal_progress.dart';
import 'package:my_workout/models/weight_goal_progress_set.dart';

class WeightGoalProgressSetTile extends StatelessWidget {
  final WeightGoalProgress goal;
  final WeightGoalProgressSet set;
  final Widget? action;

  const WeightGoalProgressSetTile({
    super.key,
    required this.goal,
    required this.set,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: set.status == ProgressStatus.planned ? .5 : 1,
      child: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(ui.stat.reps.icon, color: ui.stat.reps.color, size: 16),
                  SizedBox(width: 4),
                  Text('${ui.stat.reps.name}: ${set.reps.toString()}'),
                  if (goal.goal.weight != 0) ...[
                    SizedBox(width: 8),
                    Icon(
                      ui.stat.weight.icon,
                      color: ui.stat.weight.color,
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Text(
                        '${ui.stat.weight.name}: ${set.weight.toStringAsFixed(1)}'),
                  ],
                  if (action != null) ...[
                    Spacer(),
                    action!,
                  ],
                ],
              ),
            ),
            Divider(height: 0),
          ],
        ),
      ),
    );
  }
}
