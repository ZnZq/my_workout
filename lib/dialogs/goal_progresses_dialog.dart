import 'package:flutter/material.dart';
import 'package:my_workout/models/enum/exercise_execute_method.dart';
import 'package:my_workout/models/goal.dart';
import 'package:my_workout/models/goal_progress.dart';
import 'package:my_workout/utils.dart';
import 'package:my_workout/widgets/cardio_goal_tile.dart';
import 'package:my_workout/widgets/icon_text.dart';
import 'package:my_workout/widgets/weight_goal_tile.dart';

class GoalProgressesDialog extends StatefulWidget {
  final ExerciseExecuteMethod executeMethod;
  final List<GoalProgress> goals;

  const GoalProgressesDialog(
      {super.key, required this.executeMethod, required this.goals});

  @override
  State<GoalProgressesDialog> createState() => _GoalProgressesDialogState();
}

class _GoalProgressesDialogState extends State<GoalProgressesDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Text('Goal progresses'),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final goal = widget.goals.lastOrNull?.goal.clone() ??
                  Goal.create(widget.executeMethod);
              final newGoal = await goalDialog(context, goal);
              if (newGoal != null) {
                setState(
                    () => widget.goals.add(GoalProgress.fromGoal(newGoal)));
              }
            },
          ),
        ],
      ),
      contentPadding: const EdgeInsets.only(right: 8, left: 8),
      content: SizedBox(
        width: double.maxFinite,
        height: MediaQuery.sizeOf(context).height * 0.5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            SegmentedButton<ExerciseExecuteMethod>(
              showSelectedIcon: false,
              multiSelectionEnabled: false,
              emptySelectionAllowed: false,
              selected: {widget.executeMethod},
              segments: [
                for (var value in ExerciseExecuteMethod.values)
                  ButtonSegment<ExerciseExecuteMethod>(
                    value: value,
                    label: IconText(
                        text: value.name,
                        icon: value.icon,
                        iconColor: value.color),
                    enabled: value == widget.executeMethod,
                  ),
              ],
              onSelectionChanged: (value) {},
            ),
            SizedBox(height: 4),
            Expanded(
              child: ReorderableListView.builder(
                itemCount: widget.goals.length,
                onReorder: (oldIndex, newIndex) {
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
                  final exercise = widget.goals.removeAt(oldIndex);
                  setState(() {
                    widget.goals.insert(newIndex, exercise);
                  });
                },
                itemBuilder: (context, index) {
                  return _buildGoalProgressCard(widget.goals[index]);
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(widget.goals);
          },
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildGoalProgressCard(GoalProgress goalProgress) {
    return Card(
      key: ValueKey(goalProgress.id),
      clipBehavior: Clip.hardEdge,
      child: Dismissible(
        key: ValueKey(goalProgress.id),
        direction: DismissDirection.endToStart,
        background: Container(
          color: Colors.red,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 16),
          child: const Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
        confirmDismiss: (direction) async {
          return await askDialog(
            context,
            'Are you sure you want to delete this goal?',
          );
        },
        onDismissed: (direction) {
          setState(() => widget.goals.remove(goalProgress));
        },
        child: goalProgress.goal is WeightGoal
            ? WeightGoalTile(
                goal: goalProgress.goal.clone() as WeightGoal,
                goalEdited: (goal) => _onGoalEdited(goalProgress, goal))
            : goalProgress.goal is CardioGoal
                ? CardioGoalTile(
                    goal: goalProgress.goal.clone() as CardioGoal,
                    goalEdited: (goal) => _onGoalEdited(goalProgress, goal))
                : Text('WTF???'),
      ),
    );
  }

  void _onGoalEdited(GoalProgress goalProgress, Goal goal) {
    setState(() {
      goalProgress.goal = goal;
    });
  }
}
