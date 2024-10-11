import 'package:flutter/material.dart';
import 'package:my_workout/data.dart';
import 'package:my_workout/models/goal.dart';
import 'package:my_workout/utils.dart';
import 'package:my_workout/widgets/icon_text.dart';

class WeightGoalTile extends StatelessWidget {
  final WeightGoal goal;
  final void Function(WeightGoal)? goalEdited;

  const WeightGoalTile({super.key, required this.goal, this.goalEdited});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: goalEdited == null
          ? null
          : () async {
              final newGoal = await goalDialog(context, goal);
              if (newGoal != null) {
                goalEdited!(newGoal as WeightGoal);
              }
            },
      child: Padding(
        padding: const EdgeInsets.only(
          left: 12,
          top: 8,
          bottom: 8,
        ),
        child: Wrap(
          children: [
            IconText(
              text: '${ui.stat.sets.name}: ${goal.sets}',
              icon: ui.stat.sets.icon,
              iconColor: ui.stat.sets.color,
              endGap: 8,
            ),
            IconText(
              text: '${ui.stat.reps.name}: ${goal.reps}',
              icon: ui.stat.reps.icon,
              iconColor: ui.stat.reps.color,
              endGap: 8,
            ),
            IconText(
              text: '${ui.stat.rest.name}: ${formatDuration(goal.rest)}',
              icon: ui.stat.rest.icon,
              iconColor: ui.stat.rest.color,
              endGap: 8,
            ),
            if (goal.weight > 0)
              IconText(
                text:
                    '${ui.stat.weight.name}: ${goal.weight.toStringAsFixed(1)}',
                icon: ui.stat.weight.icon,
                iconColor: ui.stat.weight.color,
                endGap: 8,
              ),
          ],
        ),
        // child: Row(
        //   children: [
        //     Column(
        //       crossAxisAlignment: CrossAxisAlignment.start,
        //       mainAxisSize: MainAxisSize.min,
        //       children: [

        //         Text(
        //             'Sets: ${goal.sets}, Reps: ${goal.reps}, Rest: ${formatDuration(goal.rest)}'),
        //         if (goal.weight > 0)
        //           Text('Weight: ${goal.weight.toStringAsFixed(1)}'),
        //       ],
        //     ),
        //   ],
        // ),
      ),
    );
  }
}
