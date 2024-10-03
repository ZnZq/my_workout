import 'package:flutter/material.dart';
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
              text: 'Sets: ${goal.sets}',
              icon: Icons.play_arrow,
              iconColor: Colors.orange,
              endGap: 8,
            ),
            IconText(
              text: 'Reps: ${goal.reps}',
              icon: Icons.repeat,
              iconColor: Colors.green,
              endGap: 8,
            ),
            IconText(
              text: 'Rest: ${formatDuration(goal.rest)}',
              icon: Icons.timer_sharp,
              iconColor: Colors.blue,
              endGap: 8,
            ),
            if (goal.weight > 0)
              IconText(
                text: 'Weight: ${goal.weight.toStringAsFixed(1)}',
                icon: Icons.fitness_center,
                iconColor: Colors.blue,
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
