import 'package:flutter/material.dart';
import 'package:my_workout/models/enum/exercise_execute_method.dart';
import 'package:my_workout/models/goal.dart';
import 'package:my_workout/models/program_exercise.dart';
import 'package:my_workout/utils.dart';
import 'package:my_workout/widgets/cardio_goal_tile.dart';
import 'package:my_workout/widgets/icon_text.dart';
import 'package:my_workout/widgets/weight_goal_tile.dart';

class ProgramExerciseDialog extends StatefulWidget {
  final ProgramExercise programExercise;
  final bool canChangeExecuteMethod;

  const ProgramExerciseDialog({
    super.key,
    required this.programExercise,
    this.canChangeExecuteMethod = true,
  });

  @override
  State<ProgramExerciseDialog> createState() => _ProgramExerciseDialogState();
}

class _ProgramExerciseDialogState extends State<ProgramExerciseDialog> {
  final TextEditingController nameController = TextEditingController();
  final List<Goal> goals = [];

  final _formKey = GlobalKey<FormState>();

  ExerciseExecuteMethod executeMethod = ExerciseExecuteMethod.weight;

  @override
  void initState() {
    nameController.text = widget.programExercise.name;
    executeMethod = widget.programExercise.executeMethod;
    goals.addAll(widget.programExercise.goals);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: nameController,
                textCapitalization: TextCapitalization.words,
                autofocus: widget.canChangeExecuteMethod,
                decoration: InputDecoration(
                  labelText: 'Name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter value';
                  }
                  return null;
                },
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: SegmentedButton<ExerciseExecuteMethod>(
                      showSelectedIcon: false,
                      multiSelectionEnabled: false,
                      emptySelectionAllowed: false,
                      selected: {executeMethod},
                      segments: [
                        for (var value in ExerciseExecuteMethod.values)
                          ButtonSegment<ExerciseExecuteMethod>(
                            value: value,
                            label: IconText(
                                text: value.name,
                                icon: value.icon,
                                iconColor: value.color),
                            enabled: widget.canChangeExecuteMethod
                                ? true
                                : value == executeMethod,
                          ),
                      ],
                      onSelectionChanged: (value) async {
                        if (goals.isNotEmpty) {
                          final confirm = await askDialog(context,
                              'Changing the execute method will remove all goals. Are you sure?');
                          if (!confirm) {
                            return;
                          }
                        }

                        goals.clear();
                        setState(() => executeMethod = value.first);
                      },
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text('Goals'),
                  Spacer(),
                  IconButton(
                    onPressed: () async {
                      final goal = goals.lastOrNull?.clone() ??
                          Goal.create(executeMethod);
                      final newGoal = await goalDialog(context, goal);
                      if (newGoal != null) {
                        setState(() => goals.add(newGoal));
                      }
                    },
                    icon: Icon(Icons.add),
                    iconSize: 20,
                  ),
                ],
              ),
              SizedBox(
                height: 200,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final pair in goals.indexed)
                        Card(
                          margin: EdgeInsets.only(bottom: 8),
                          clipBehavior: Clip.hardEdge,
                          child: Dismissible(
                            key: ValueKey(pair.$2.id),
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
                            onDismissed: (direction) {
                              setState(() => goals.remove(pair.$2));
                            },
                            child: pair.$2 is WeightGoal
                                ? WeightGoalTile(
                                    goal: pair.$2 as WeightGoal,
                                    goalEdited: (goal) =>
                                        _onGoalEdited(goal, pair.$1))
                                : pair.$2 is CardioGoal
                                    ? CardioGoalTile(
                                        goal: pair.$2 as CardioGoal,
                                        goalEdited: (goal) =>
                                            _onGoalEdited(goal, pair.$1))
                                    : Text('WTF???'),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) {
              return;
            }

            Navigator.of(context).pop(ProgramExercise(
              id: widget.programExercise.id,
              name: nameController.text,
              executeMethod: executeMethod,
              goals: goals,
            ));
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _onGoalEdited(Goal goal, int index) {
    setState(() => goals[index] = goal);
  }
}
