import 'package:flutter/material.dart';
import 'package:my_workout/dialogs/program_exercise_dialog.dart';
import 'package:my_workout/models/enum/exercise_execute_method.dart';
import 'package:my_workout/models/program.dart';
import 'package:my_workout/models/program_exercise.dart';
import 'package:my_workout/utils.dart';

class ProgramPage extends StatefulWidget {
  static const route = '/program';
  late final Program program;
  late final bool isNew;

  ProgramPage({super.key, Program? program}) {
    this.program = program ?? Program(title: 'New program');
    isNew = program == null;
  }

  @override
  State<ProgramPage> createState() => _ProgramPageState();
}

class _ProgramPageState extends State<ProgramPage> {
  String title = '';
  String description = '';
  final List<ProgramExercise> exercises = [];

  @override
  void initState() {
    title = widget.program.title;
    description = widget.program.description;
    exercises.addAll(widget.program.exercises.map((e) => e.clone()));

    super.initState();

    if (widget.isNew) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _editInfo());
    }
  }

  bool _isDirty() {
    return buildProgram() != widget.program;
  }

  void _onPopInvokedWithResult(
    BuildContext context,
    bool didPop,
    dynamic result,
  ) async {
    if (didPop) {
      return;
    }

    final isDirty = _isDirty();
    if (!isDirty) {
      Navigator.of(context).pop();
      return;
    }

    final message = widget.isNew
        ? 'You have unsaved changes, do you want to save this program?'
        : 'You have unsaved changes, do you want to save changes to this program?';
    final Map<String, dynamic> options = {
      'Yes': true,
      'No': false,
      'Cancel': null,
    };
    final result = await askDialog(context, message, options: options);
    if (!context.mounted || result == null) {
      return;
    }

    if (result == true) {
      _saveProgram();
      return;
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        _onPopInvokedWithResult(context, didPop, result);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _editInfo,
            ),
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _isDirty() ? _saveProgram : null,
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              ReorderableListView.builder(
                shrinkWrap: true,
                itemCount: exercises.length,
                itemBuilder: (context, index) {
                  final exercise = exercises[index];
                  return Padding(
                    key: ValueKey(exercise.id),
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: _buildExerciseCard(exercise, context, index),
                  );
                },
                onReorder: (oldIndex, newIndex) {
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
                  setState(() {
                    final exercise = exercises.removeAt(oldIndex);
                    exercises.insert(newIndex, exercise);
                  });
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Card(
                  clipBehavior: Clip.hardEdge,
                  child: InkWell(
                    onTap: _addExercise,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Icon(Icons.add),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseCard(
    ProgramExercise exercise,
    BuildContext context,
    int index,
  ) {
    return Card(
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
        onDismissed: (direction) {
          setState(() => exercises.remove(exercise));
        },
        confirmDismiss: (direction) async {
          return await askDialog(
              context, 'Are you sure you want to delete ${exercise.name}?');
        },
        child: ListTile(
          leading: Icon(
            exercise.executeMethod.icon,
            color: exercise.executeMethod.color,
          ),
          title: Text(exercise.name),
          subtitle: Text('Goal: ${exercise.goals.length}'),
          onTap: () => _editExercise(exercise),
        ),
      ),
    );
  }

  Program buildProgram() {
    return Program(
      id: widget.program.id,
      title: title,
      description: description,
      exercises: exercises,
    );
  }

  void _saveProgram() {
    final program = buildProgram();
    Navigator.of(context).pop(program);
  }

  void _addExercise() async {
    final exercise = await showDialog<ProgramExercise>(
      context: context,
      builder: (context) {
        return ProgramExerciseDialog(programExercise: ProgramExercise.empty());
      },
    );

    if (exercise != null) {
      setState(() => exercises.add(exercise));
    }
  }

  void _editExercise(ProgramExercise exercise) async {
    final newExercise = await showDialog<ProgramExercise>(
      context: context,
      builder: (context) {
        return ProgramExerciseDialog(
          programExercise: exercise,
          canChangeExecuteMethod: false,
        );
      },
    );

    if (newExercise != null) {
      final index = exercises.indexOf(exercise);
      setState(() => exercises[index] = newExercise);
    }
  }

  void _editInfo() async {
    var programInfo =
        await infoDialog(context, title, description: description);
    if (programInfo != null) {
      setState(() {
        title = programInfo['title']!;
        description = programInfo['description']!;
      });
    }
  }
}
