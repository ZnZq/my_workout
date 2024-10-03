import 'package:flutter/material.dart';
import 'package:my_workout/dialogs/goal_progresses_dialog.dart';
import 'package:my_workout/models/activity_exercise.dart';
import 'package:my_workout/models/enum/exercise_execute_method.dart';
import 'package:my_workout/utils.dart';

class ActivityExercisesDialog extends StatefulWidget {
  final List<ActivityExercise> exercises;

  const ActivityExercisesDialog({super.key, required this.exercises});

  @override
  State<ActivityExercisesDialog> createState() =>
      _ActivityExercisesDialogState();
}

class _ActivityExercisesDialogState extends State<ActivityExercisesDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Text('Activity exercises'),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {},
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: MediaQuery.sizeOf(context).height * 0.5,
        child: ReorderableListView.builder(
          itemCount: widget.exercises.length,
          onReorder: (oldIndex, newIndex) {
            if (oldIndex < newIndex) {
              newIndex -= 1;
            }
            final exercise = widget.exercises.removeAt(oldIndex);
            widget.exercises.insert(newIndex, exercise);
          },
          itemBuilder: (context, index) {
            return _buildActivityExerciseCard(widget.exercises[index]);
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(widget.exercises);
          },
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildActivityExerciseCard(ActivityExercise exercise) {
    return Card(
      key: ValueKey(exercise.id),
      clipBehavior: Clip.hardEdge,
      child: Dismissible(
        key: ValueKey(exercise.id),
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
            'Are you sure you want to delete ${exercise.name}?',
          );
        },
        onDismissed: (direction) {
          setState(() => widget.exercises.remove(exercise));
        },
        child: ListTile(
          leading: Icon(
            exercise.executeMethod.icon,
            color: exercise.executeMethod.color,
          ),
          title: Text(
            exercise.name,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
          onTap: () async {
            await showDialog(
              context: context,
              builder: (context) {
                return GoalProgressesDialog(
                  executeMethod: exercise.executeMethod,
                  goals: exercise.goalProgress,
                );
              },
            );

            setState(() {});
          },
        ),
      ),
    );
  }
}
