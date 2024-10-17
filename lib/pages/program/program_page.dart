import 'package:flutter/material.dart';
import 'package:my_workout/dialogs/program_exercise_dialog.dart';
import 'package:my_workout/models/enum/exercise_execute_method.dart';
import 'package:my_workout/models/program.dart';
import 'package:my_workout/models/program_exercise.dart';
import 'package:my_workout/pages/activity/report_page.dart';
import 'package:my_workout/storage/storage.dart';
import 'package:my_workout/utils.dart';
import 'package:my_workout/widgets/icon_text.dart';

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

class _ProgramPageState extends State<ProgramPage> with WidgetsBindingObserver {
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
    return buildProgram(false) != widget.program;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      _save();
    }
  }

  void _onPopInvokedWithResult(
    BuildContext context,
    bool didPop,
    dynamic result,
  ) async {
    if (didPop) {
      return;
    }

    final program = _save();

    Navigator.of(context).pop(program);
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
            PopupMenuButton(
              icon: Icon(Icons.more_vert),
              itemBuilder: (context) {
                return [
                  PopupMenuItem(
                    value: 'rename',
                    child: IconText(
                      icon: Icons.edit,
                      text: 'Rename',
                      iconColor: Colors.white,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'report',
                    child: IconText(
                      icon: Icons.receipt_long_outlined,
                      text: 'Report',
                      iconColor: Colors.white,
                    ),
                  ),
                ];
              },
              onSelected: (value) {
                switch (value) {
                  case 'rename':
                    _editInfo();
                    break;
                  case 'report':
                    _generateReport();
                    break;
                }
              },
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

  void _generateReport() {
    final program = buildProgram(true);
    Navigator.of(context)
        .pushNamed<String?>(ReportPage.route, arguments: program);
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

  Program buildProgram(bool withClone) {
    return Program(
      id: widget.program.id,
      title: title,
      description: description,
      exercises:
          withClone ? exercises.map((e) => e.clone()).toList() : exercises,
    );
  }

  Program? _save() {
    final isDirty = _isDirty();
    final program = isDirty ? buildProgram(true) : null;
    if (program != null) {
      Storage.programStorage.update(program, insertIndex: 0);
    }

    return program;
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
