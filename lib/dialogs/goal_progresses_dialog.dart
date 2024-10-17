import 'package:flutter/material.dart';
import 'package:my_workout/models/activity_exercise.dart';
import 'package:my_workout/models/cardio_goal_progress.dart';
import 'package:my_workout/models/enum/exercise_execute_method.dart';
import 'package:my_workout/models/goal.dart';
import 'package:my_workout/models/goal_progress.dart';
import 'package:my_workout/models/progress_status.dart';
import 'package:my_workout/utils.dart';
import 'package:my_workout/widgets/cardio_goal_tile.dart';
import 'package:my_workout/widgets/icon_text.dart';
import 'package:my_workout/widgets/weight_goal_tile.dart';

class GoalProgressesDialog extends StatefulWidget {
  final ActivityExercise exercise;

  const GoalProgressesDialog({
    super.key,
    required this.exercise,
  });

  @override
  State<GoalProgressesDialog> createState() => _GoalProgressesDialogState();
}

class _GoalProgressesDialogState extends State<GoalProgressesDialog> {
  final nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    nameController.text = widget.exercise.name;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Goal progresses'),
      contentPadding: const EdgeInsets.only(right: 12, left: 12),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: double.maxFinite,
          height: MediaQuery.sizeOf(context).height * 0.5,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      widget.exercise.name = value;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: SegmentedButton<ExerciseExecuteMethod>(
                    showSelectedIcon: false,
                    multiSelectionEnabled: false,
                    emptySelectionAllowed: false,
                    selected: {widget.exercise.executeMethod},
                    segments: [
                      for (var value in ExerciseExecuteMethod.values)
                        ButtonSegment<ExerciseExecuteMethod>(
                          value: value,
                          label: IconText(
                              text: value.name,
                              icon: value.icon,
                              iconColor: value.color),
                          enabled: value == widget.exercise.executeMethod,
                        ),
                    ],
                    onSelectionChanged: (value) {},
                  ),
                ),
                const SizedBox(height: 4),
                ReorderableListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.exercise.goalProgress.length,
                  onReorder: (oldIndex, newIndex) {
                    if (oldIndex < newIndex) {
                      newIndex -= 1;
                    }
                    final exercise =
                        widget.exercise.goalProgress.removeAt(oldIndex);
                    setState(() {
                      widget.exercise.goalProgress.insert(newIndex, exercise);
                    });
                  },
                  itemBuilder: (context, index) {
                    return _buildGoalProgressCard(
                        widget.exercise.goalProgress[index]);
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: Card(
                    clipBehavior: Clip.hardEdge,
                    child: InkWell(
                      onTap: _addGoal,
                      child: const Center(
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Icon(Icons.add),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(widget.exercise.goalProgress);
          },
          child: const Text('Close'),
        ),
      ],
    );
  }

  void _addGoal() async {
    final goal = widget.exercise.goalProgress.lastOrNull?.goal.clone() ??
        Goal.create(widget.exercise.executeMethod);
    final newGoal = await goalDialog(context, goal);
    if (newGoal != null) {
      setState(() =>
          widget.exercise.goalProgress.add(GoalProgress.fromGoal(newGoal)));
    }
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
          setState(() => widget.exercise.goalProgress.remove(goalProgress));
        },
        child: goalProgress.goal is WeightGoal
            ? WeightGoalTile(
                goal: goalProgress.goal.clone() as WeightGoal,
                goalEdited: (goal) => _onGoalEdited(goalProgress, goal))
            : goalProgress.goal is CardioGoal
                ? CardioGoalTile(
                    goal: goalProgress.goal.clone() as CardioGoal,
                    goalEdited: (goal) => _onGoalEdited(goalProgress, goal))
                : const Text('WTF???'),
      ),
    );
  }

  void _onGoalEdited(GoalProgress goalProgress, Goal goal) {
    setState(() {
      goalProgress.goal = goal;
      if (goalProgress is CardioGoalProgress) {
        goalProgress.actual.actualizeFrom(goalProgress.goal,
            copyValues: goalProgress.status != ProgressStatus.planned);
      }
    });
  }
}
