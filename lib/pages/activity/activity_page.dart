import 'package:flutter/material.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
import 'package:my_workout/dialogs/activity_exercises_dialog.dart';
import 'package:my_workout/dialogs/weight_goal_progress_set_dialog.dart';
import 'package:my_workout/models/activity.dart';
import 'package:my_workout/models/activity_exercise.dart';
import 'package:my_workout/models/cardio_goal_progress.dart';
import 'package:my_workout/models/enum/exercise_execute_method.dart';
import 'package:my_workout/models/goal_progress.dart';
import 'package:my_workout/models/progress_status.dart';
import 'package:my_workout/models/weight_goal_progress.dart';
import 'package:my_workout/models/weight_goal_progress_set.dart';
import 'package:my_workout/storage/storage.dart';
import 'package:my_workout/utils.dart';
import 'package:my_workout/widgets/activity_exercise_tab.dart';
import 'package:my_workout/widgets/cardio_goal_progress_stats.dart';
import 'package:my_workout/widgets/compact_button.dart';
import 'package:my_workout/widgets/icon_text.dart';
import 'package:my_workout/widgets/weight_goal_progress_set_tile.dart';
import 'package:my_workout/widgets/weight_goal_progress_stats.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:timelines/timelines.dart';

class ActivityPage extends StatefulWidget {
  static const route = '/activity';
  final Activity activity;

  const ActivityPage({super.key, required this.activity});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;

  StopWatchTimer? stopWatchTimer;
  ActivityExercise? selectedExercise;
  GoalProgress? selectedGoal;
  String title = '';
  DateTime date = DateTime.now();

  final List<ActivityExercise> exercises = [];

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);

    date = widget.activity.date;
    title = widget.activity.title;
    exercises.addAll(widget.activity.exercises.map((e) => e.clone()));

    _tabController = TabController(length: exercises.length, vsync: this);

    if (title.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _editInfo());
    }

    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    stopWatchTimer?.dispose();

    super.dispose();
  }

  bool _isDirty() {
    return buildActivity(false) != widget.activity;
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

    final activity = _save();

    Navigator.of(context).pop(activity);
  }

  Activity? _save() {
    final isDirty = _isDirty();
    final activity = isDirty ? buildActivity(true) : null;
    if (activity != null) {
      Storage.activityStorage.update(activity, insertIndex: 0);
    }

    return activity;
  }

  void _editInfo() async {
    var programInfo = await infoDialog(context, title, showDescription: false);
    if (programInfo != null) {
      setState(() {
        title = programInfo['title']!;
      });
    }
  }

  Activity buildActivity(bool withClone) {
    return Activity(
      id: widget.activity.id,
      date: date,
      title: title,
      status: getActivityStatus(),
      exercises:
          withClone ? exercises.map((e) => e.clone()).toList() : exercises,
    );
  }

  ProgressStatus getActivityStatus() {
    if (exercises.isEmpty) {
      return ProgressStatus.planned;
    }

    if (exercises.every((e) => e.status == ProgressStatus.completed)) {
      return ProgressStatus.completed;
    }

    if (exercises.any((e) => e.status != ProgressStatus.planned)) {
      return ProgressStatus.inProgress;
    }

    return ProgressStatus.planned;
  }

  void _runGoalProgress(ActivityExercise? exercise, GoalProgress? goal) {
    setState(() {
      stopWatchTimer?.onStopTimer();
      stopWatchTimer?.dispose();
      stopWatchTimer = null;

      if (goal is CardioGoalProgress) {
        initCardioStopWatchTimer(goal);
      }

      selectedExercise = exercise;
      selectedGoal = goal;
    });
  }

  int getCardioPresetMillisecond(CardioGoalProgress goal) {
    if (goal.status == ProgressStatus.planned) {
      return goal.goal.duration == null
          ? 0
          : StopWatchTimer.getMilliSecFromSecond(goal.goal.duration!.inSeconds);
    }

    if (goal.status == ProgressStatus.inProgress) {
      return goal.goal.duration == null
          ? goal.actual.duration!.inMilliseconds
          : StopWatchTimer.getMilliSecFromSecond(
              goal.goal.duration!.inSeconds - goal.actual.duration!.inSeconds,
            );
    }

    return 0;
  }

  void initCardioStopWatchTimer(CardioGoalProgress goal) {
    final mode = goal.goal.duration == null
        ? StopWatchMode.countUp
        : StopWatchMode.countDown;

    final presetMillisecond = getCardioPresetMillisecond(goal);

    stopWatchTimer = StopWatchTimer(
      mode: mode,
      presetMillisecond: presetMillisecond,
      onEnded: mode == StopWatchMode.countDown
          ? () async {
              await vibrateThreeTimes();
            }
          : null,
    );
    stopWatchTimer!.secondTime.listen((seconds) {
      setState(() {
        if (goal.goal.duration == null) {
          goal.actual.duration = Duration(seconds: seconds);
        } else {
          goal.actual.duration =
              goal.goal.duration! - Duration(seconds: seconds);
        }
      });
    });

    if (goal.status != ProgressStatus.planned) {
      stopWatchTimer!.onStartTimer();
    }
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
              icon: Icon(Icons.edit),
              onPressed: _editInfo,
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(child: _buildActiveExercise(context)),
            Expanded(child: _buildExercises(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveExercise(BuildContext context) {
    if (selectedGoal == null) {
      return Center(child: Text('No goal selected'));
    }

    if (selectedGoal is WeightGoalProgress) {
      return _buildActiveWeightGoalProgress(
        context,
        selectedGoal as WeightGoalProgress,
      );
    }

    if (selectedGoal is CardioGoalProgress) {
      return _buildActiveCardioGoalProgress(
        context,
        selectedGoal as CardioGoalProgress,
      );
    }

    return Center(child: Text('Not implemented'));
  }

  Widget _buildActiveCardioGoalProgress(
    BuildContext context,
    CardioGoalProgress goal,
  ) {
    final actual = goal.actual;

    final elevatedButtonStyle = ElevatedButton.styleFrom(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      minimumSize: Size(0, 0),
      elevation: 0,
    );

    final gridItems = goal.status != ProgressStatus.inProgress
        ? <Widget>[]
        : <Widget>[
            if (goal.actual.speed != null) ...[
              Card(
                margin: EdgeInsets.all(4),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.speed, color: Colors.orange, size: 16),
                          SizedBox(width: 4),
                          Text('Speed: ${actual.speed!.toStringAsFixed(1)}'),
                        ],
                      ),
                      Spacer(),
                      SizedBox(
                        width: 43 * 3,
                        child: Card(
                          color: Colors.grey[850],
                          child: DecimalNumberPicker(
                            axis: Axis.vertical,
                            itemHeight: 40,
                            itemWidth: 40,
                            value: actual.speed!,
                            textStyle: TextStyle(fontSize: 14),
                            selectedTextStyle: TextStyle(fontSize: 20),
                            minValue: 0,
                            maxValue: 999,
                            onChanged: (value) =>
                                setState(() => goal.actual.speed = value),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            if (goal.actual.distance != null) ...[
              Card(
                margin: EdgeInsets.all(4),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.location_on,
                              color: Colors.indigo, size: 16),
                          SizedBox(width: 4),
                          Text(
                              'Distance: ${actual.distance!.toStringAsFixed(1)}'),
                        ],
                      ),
                      Spacer(),
                      SizedBox(
                        width: 43 * 3,
                        child: Card(
                          color: Colors.grey[850],
                          child: DecimalNumberPicker(
                            axis: Axis.vertical,
                            itemHeight: 40,
                            itemWidth: 40,
                            value: actual.distance!,
                            textStyle: TextStyle(fontSize: 14),
                            selectedTextStyle: TextStyle(fontSize: 20),
                            minValue: 0,
                            maxValue: 999,
                            onChanged: (value) =>
                                setState(() => goal.actual.distance = value),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            if (goal.actual.intensity != null) ...[
              Card(
                margin: EdgeInsets.all(4),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.bolt, color: Colors.green, size: 16),
                          SizedBox(width: 4),
                          Text(
                              'Intensity: ${actual.intensity!.toStringAsFixed(1)}'),
                        ],
                      ),
                      Spacer(),
                      SizedBox(
                        width: 43 * 3,
                        child: Card(
                          color: Colors.grey[850],
                          child: DecimalNumberPicker(
                            axis: Axis.vertical,
                            itemHeight: 40,
                            itemWidth: 40,
                            value: actual.intensity!,
                            textStyle: TextStyle(fontSize: 14),
                            selectedTextStyle: TextStyle(fontSize: 20),
                            minValue: 0,
                            maxValue: 999,
                            onChanged: (value) =>
                                setState(() => goal.actual.intensity = value),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            if (goal.actual.level != null) ...[
              Card(
                margin: EdgeInsets.all(4),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.leaderboard,
                              color: Colors.yellow, size: 16),
                          SizedBox(width: 4),
                          Text('Level: ${actual.level!.toStringAsFixed(1)}'),
                        ],
                      ),
                      Spacer(),
                      SizedBox(
                        width: 43 * 3,
                        child: Card(
                          color: Colors.grey[850],
                          child: DecimalNumberPicker(
                            axis: Axis.vertical,
                            itemHeight: 40,
                            itemWidth: 40,
                            value: actual.level!,
                            textStyle: TextStyle(fontSize: 14),
                            selectedTextStyle: TextStyle(fontSize: 20),
                            minValue: 0,
                            maxValue: 999,
                            onChanged: (value) =>
                                setState(() => goal.actual.level = value),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ];

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(left: 12, right: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (selectedExercise != null) ...[
              _buildSelectedExerciseCard(goal),
              SizedBox(height: 8),
            ],
            _buildGoalProgressStats(goal),
            SizedBox(height: 8),
            if (goal.status == ProgressStatus.planned)
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    goal.status = ProgressStatus.inProgress;
                    goal.startAt = DateTime.now();
                    goal.actual.duration = Duration.zero;
                    goal.actual.heartRate = goal.goal.heartRate;
                    goal.actual.speed = goal.goal.speed;
                    goal.actual.distance = goal.goal.distance;
                    goal.actual.intensity = goal.goal.intensity;
                    goal.actual.level = goal.goal.level;
                    initCardioStopWatchTimer(goal);
                  });
                },
                child: Text('Start goal'),
              ),
            if (goal.status == ProgressStatus.inProgress) ...[
              _buildCardioGoalProgressTimer(goal),
              SizedBox(height: 8),
              if (goal.actual.heartRate != null) ...[
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Row(
                      children: [
                        Icon(Icons.favorite, color: Colors.red, size: 16),
                        SizedBox(width: 4),
                        Text('Heart rate: ${actual.heartRate}'),
                        Spacer(),
                        ElevatedButton(
                          style: elevatedButtonStyle,
                          onPressed: () => setState(
                            () => goal.actual.heartRate =
                                (goal.actual.heartRate! - 10).clamp(40, 300),
                          ),
                          child: Text('-10'),
                        ),
                        SizedBox(
                          width: 43 * 3,
                          child: Card(
                            color: Colors.grey[850],
                            child: NumberPicker(
                              axis: Axis.horizontal,
                              itemWidth: 40,
                              value: goal.actual.heartRate!,
                              textStyle: TextStyle(fontSize: 14),
                              selectedTextStyle: TextStyle(fontSize: 20),
                              minValue: 40,
                              maxValue: 300,
                              onChanged: (value) =>
                                  setState(() => goal.actual.heartRate = value),
                            ),
                          ),
                        ),
                        ElevatedButton(
                          style: elevatedButtonStyle,
                          onPressed: () => setState(
                            () => goal.actual.heartRate =
                                (goal.actual.heartRate! + 10).clamp(40, 300),
                          ),
                          child: Text('+10'),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 8),
              ],
              if (gridItems.isNotEmpty) ...[
                GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  physics: NeverScrollableScrollPhysics(),
                  childAspectRatio: 1 / 1,
                  children: gridItems,
                ),
                SizedBox(height: 8),
              ],
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    goal.status = ProgressStatus.completed;
                    stopWatchTimer!.onStopTimer();
                  });
                },
                child: Text('Complete goal'),
              ),
              SizedBox(height: 8),
            ],
            if (goal.status == ProgressStatus.completed) ...[
              Center(child: Text('Goal completed'))
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildCardioGoalProgressTimer(CardioGoalProgress goal) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.timer_sharp, color: Colors.blue, size: 16),
            SizedBox(width: 4),
            StreamBuilder(
              stream: stopWatchTimer!.secondTime,
              initialData: goal.actual.duration!.inSeconds,
              builder: (context, snapshot) {
                final value = snapshot.data!;
                final displayTime = StopWatchTimer.getDisplayTime(
                  value * 1000,
                  milliSecond: false,
                );

                return Text(goal.goal.duration == null
                    ? '$displayTime passed'
                    : '$displayTime left');
              },
            ),
            Spacer(),
            CompactButton(
              text: stopWatchTimer!.isRunning ? 'Pause' : 'Play',
              backgroundColor: Colors.blue,
              onPressed: goal.goal.duration == null ||
                      goal.actual.duration!.inSeconds !=
                          goal.goal.duration!.inSeconds
                  ? () {
                      if (stopWatchTimer!.isRunning) {
                        stopWatchTimer!.onStopTimer();
                      } else {
                        stopWatchTimer!.onStartTimer();
                      }

                      setState(() {});
                    }
                  : null,
            ),
            if (goal.goal.duration == null ||
                goal.actual.duration!.inSeconds !=
                    goal.goal.duration!.inSeconds) ...[
              SizedBox(width: 8),
              CompactButton(
                text: goal.goal.duration == null ? 'Reset' : 'Finish',
                backgroundColor: Colors.indigo,
                onPressed: () {
                  if (goal.goal.duration == null) {
                    stopWatchTimer!.onResetTimer();
                    stopWatchTimer!.onStartTimer();
                  } else {
                    stopWatchTimer!.onStopTimer();
                    stopWatchTimer!.setPresetSecondTime(0, add: false);
                    stopWatchTimer!.onStartTimer();
                  }

                  setState(() {});
                },
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildGoalProgressStats(GoalProgress goal) {
    return SizedBox(
      width: double.maxFinite,
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Center(
            child: _buildGoalStats(goal, wrapAlignment: WrapAlignment.center),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveWeightGoalProgress(
    BuildContext context,
    WeightGoalProgress goal,
  ) {
    final set = goal.sets.firstWhere(
      (e) => !e.isDone,
      orElse: () => goal.sets.last,
    );

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(left: 12, right: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (selectedExercise != null) ...[
              _buildSelectedExerciseCard(goal, set: set),
              SizedBox(height: 8),
            ],
            _buildGoalProgressStats(goal),
            SizedBox(height: 8),
            if (set.status == ProgressStatus.planned)
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    set.status = ProgressStatus.inProgress;
                    set.reps = goal.goal.reps;
                    set.weight = goal.goal.weight;
                  });
                },
                child: Text('Start set'),
              ),
            if (set.status == ProgressStatus.inProgress) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Text('Reps: ${set.reps}/${goal.goal.reps}'),
                        ),
                        Card(
                          child: NumberPicker(
                            axis: Axis.horizontal,
                            itemWidth: 60,
                            value: set.reps,
                            minValue: 0,
                            maxValue: 999,
                            onChanged: (value) =>
                                setState(() => set.reps = value),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (goal.goal.weight != 0)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: Text(
                              'Weight: ${set.weight.toStringAsFixed(1)}/${goal.goal.weight.toStringAsFixed(1)}',
                            ),
                          ),
                          Card(
                            child: DecimalNumberPicker(
                              axis: Axis.horizontal,
                              itemWidth: 45,
                              itemHeight: 45,
                              value: set.weight,
                              minValue: 0,
                              maxValue: 999,
                              onChanged: (value) =>
                                  setState(() => set.weight = value),
                            ),
                          )
                        ],
                      ),
                    ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    set.status = ProgressStatus.completed;
                    set.endRestAt = DateTime.now().add(goal.goal.rest);
                  });
                },
                child: Text('Complete set'),
              ),
            ],
            if (set.status == ProgressStatus.completed) ...[
              if (set.endRestAt != null) ...[
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Resting'),
                        SizedBox(height: 12),
                        Center(
                          child: TimerCountdown(
                            format: CountDownTimerFormat.hoursMinutesSeconds,
                            endTime: set.endRestAt!,
                            onEnd: () async {
                              await vibrateThreeTimes();
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 4),
              ],
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    set.isDone = true;
                    if (set == goal.sets.last) {
                      goal.sets.add(WeightGoalProgressSet(
                        reps: 0,
                        weight: 0,
                        status: ProgressStatus.planned,
                      ));
                    }
                  });
                },
                child: Text(set == goal.sets.last ? 'Add set' : 'Next set'),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Future<void> vibrateThreeTimes() async {
    await vibrate();
    await Future.delayed(const Duration(milliseconds: 1000));
    await vibrate();
    await Future.delayed(const Duration(milliseconds: 1000));
    await vibrate();
  }

  Widget _buildSelectedExerciseCard(
    GoalProgress goal, {
    WeightGoalProgressSet? set,
  }) {
    return SizedBox(
      width: double.maxFinite,
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        size: 20,
                        selectedExercise!.executeMethod.icon,
                        color: selectedExercise!.executeMethod.color,
                      ),
                      SizedBox(width: 8),
                      Text(selectedExercise!.name),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                          'Goal #${selectedExercise!.goalProgress.indexOf(goal) + 1} of ${selectedExercise!.goalProgress.length}'),
                      SizedBox(width: 12),
                      if (goal is WeightGoalProgress && set != null)
                        Text(
                            'Set #${goal.sets.indexOf(set) + 1} of ${goal.sets.length}')
                    ],
                  )
                ],
              ),
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    _runGoalProgress(null, null);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExercises(BuildContext context) {
    return Column(
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Divider(height: 0),
            Row(
              children: [
                Expanded(
                  child: TabBar(
                    controller: _tabController,
                    dividerHeight: 0,
                    physics: const NeverScrollableScrollPhysics(),
                    isScrollable: true,
                    tabAlignment: TabAlignment.center,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                    tabs: exercises
                        .map((e) => ActivityExerciseTab(activityExercise: e))
                        .toList(),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () async {
                    await showDialog(
                      context: context,
                      builder: (context) {
                        return ActivityExercisesDialog(exercises: exercises);
                      },
                    );

                    for (var e in exercises) {
                      e.actualizeSets();
                    }

                    setState(() {
                      _tabController = TabController(
                        length: exercises.length,
                        vsync: this,
                      );
                    });
                  },
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Divider(height: 0),
            ),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children:
                exercises.map((e) => _buildExerciseView(context, e)).toList(),
          ),
        )
      ],
    );
  }

  Widget _buildExerciseView(BuildContext context, ActivityExercise exercise) {
    if (exercise.executeMethod == ExerciseExecuteMethod.weight) {
      return _buildWeightExerciseView(context, exercise);
    }

    if (exercise.executeMethod == ExerciseExecuteMethod.cardio) {
      return _buildCardioExerciseView(context, exercise);
    }

    return Center(child: Text('Not implemented'));
  }

  Widget _buildCardioExerciseView(
    BuildContext context,
    ActivityExercise exercise,
  ) {
    final goals = exercise.goalProgress.cast<CardioGoalProgress>();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(left: 12, top: 12),
        child: FixedTimeline.tileBuilder(
          theme: TimelineThemeData(
            nodePosition: 0,
            indicatorPosition: 0,
            connectorTheme: ConnectorThemeData(
              thickness: 3.0,
              color: Color(0xffd3d3d3),
            ),
            indicatorTheme: IndicatorThemeData(size: 24),
          ),
          builder: TimelineTileBuilder.connected(
            itemCount: goals.length,
            contentsBuilder: (context, index) {
              final goal = goals[index];

              return _buildCardioGoalProgress(context, exercise, goal, index);
            },
            connectorBuilder: (_, index, __) {
              final goal = goals[index];

              return SolidLineConnector(
                color: goal.status.color,
                indent: 4,
              );
            },
            lastConnectorBuilder: goals.isEmpty
                ? null
                : (context) {
                    final goal = goals.last;
                    return SolidLineConnector(
                      color: goal.status.color,
                      indent: 4,
                      endIndent: 8,
                    );
                  },
            indicatorBuilder: (_, index) {
              final goal = goals[index];

              return Padding(
                padding: const EdgeInsets.only(top: 4),
                child: DotIndicator(
                  color: goal.status.color,
                  child: Icon(goal.status.icon, color: Colors.white, size: 12),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildWeightExerciseView(
    BuildContext context,
    ActivityExercise exercise,
  ) {
    final goals = exercise.goalProgress.cast<WeightGoalProgress>();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(left: 12, top: 12),
        child: FixedTimeline.tileBuilder(
          theme: TimelineThemeData(
            nodePosition: 0,
            indicatorPosition: 0,
            connectorTheme: ConnectorThemeData(
              thickness: 3.0,
              color: Color(0xffd3d3d3),
            ),
            indicatorTheme: IndicatorThemeData(size: 24),
          ),
          builder: TimelineTileBuilder.connected(
            itemCount: goals.length,
            contentsBuilder: (context, index) {
              final goal = goals[index];

              return _buildWeightGoalProgress(context, exercise, goal, index);
            },
            connectorBuilder: (_, index, __) {
              final goal = goals[index];

              return SolidLineConnector(color: goal.status.color, indent: 4);
            },
            lastConnectorBuilder: goals.isEmpty
                ? null
                : (context) {
                    final goal = goals.last;

                    return SolidLineConnector(
                      color: goal.status.color,
                      indent: 4,
                      endIndent: 8,
                    );
                  },
            indicatorBuilder: (_, index) {
              final goal = goals[index];
              final dot = switch (goal.status) {
                ProgressStatus.planned => DotIndicator(
                    color: goal.status.color,
                    child:
                        Icon(goal.status.icon, color: Colors.white, size: 12),
                  ),
                ProgressStatus.inProgress => DotIndicator(
                    color: goal.status.color,
                    child:
                        Icon(goal.status.icon, color: Colors.white, size: 12),
                  ),
                ProgressStatus.completed => DotIndicator(
                    color: goal.status.color,
                    child:
                        Icon(goal.status.icon, color: Colors.white, size: 12),
                  ),
              };

              return Padding(
                padding: const EdgeInsets.only(top: 4),
                child: dot,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildWeightGoalProgress(
    BuildContext context,
    ActivityExercise exercise,
    WeightGoalProgress goal,
    int index,
  ) {
    return Card(
      margin: EdgeInsets.only(left: 12, right: 12, bottom: 8),
      clipBehavior: Clip.hardEdge,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            _buildWeightGoalProgressHeader(exercise, goal),
            Divider(),
            _buildWeightGoalProgressBody(goal),
            _buildWeightGoalProgressAddSet(goal)
          ],
        ),
      ),
    );
  }

  Widget _buildWeightGoalProgressAddSet(WeightGoalProgress goal) {
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: InkWell(
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        onTap: () {
          setState(() {
            goal.sets.add(WeightGoalProgressSet(
              reps: 0,
              weight: 0,
              status: ProgressStatus.planned,
            ));
          });
        },
        child: Padding(
          padding: const EdgeInsets.only(left: 2),
          child: Row(
            children: const [
              DotIndicator(
                size: 16,
                color: Colors.green,
                child: Icon(Icons.add, color: Colors.white, size: 8),
              ),
              SizedBox(width: 12),
              Text('Add set'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardioGoalProgress(
    BuildContext context,
    ActivityExercise exercise,
    CardioGoalProgress goal,
    int index,
  ) {
    return Card(
      margin: EdgeInsets.only(left: 12, right: 12, bottom: 8),
      clipBehavior: Clip.hardEdge,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            _buildCardioGoalProgressHeader(exercise, goal),
            Divider(height: 0),
            SizedBox(height: 8),
            _buildCardioGoalProgressBody(goal)
          ],
        ),
      ),
    );
  }

  Widget _buildCardioGoalProgressBody(CardioGoalProgress goal) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (goal.actual.duration != null)
          IconText(
            text: 'Duration: ${formatDuration(goal.actual.duration!)}',
            icon: Icons.timer_sharp,
            iconColor: Colors.blue,
            endGap: 8,
          ),
        if (goal.actual.heartRate != null)
          IconText(
            text: 'Heart rate: ${goal.actual.heartRate}',
            icon: Icons.favorite,
            iconColor: Colors.red,
            endGap: 8,
          ),
        if (goal.actual.speed != null)
          IconText(
            text: 'Speed: ${goal.actual.speed!.toStringAsFixed(1)}',
            icon: Icons.speed,
            iconColor: Colors.orange,
            endGap: 8,
          ),
        if (goal.actual.distance != null)
          IconText(
            text: 'Distance: ${goal.actual.distance!.toStringAsFixed(1)}',
            icon: Icons.location_on,
            iconColor: Colors.indigo,
            endGap: 8,
          ),
        if (goal.actual.intensity != null)
          IconText(
            text: 'Intensity: ${goal.actual.intensity!.toStringAsFixed(1)}',
            icon: Icons.bolt,
            iconColor: Colors.green,
            endGap: 8,
          ),
        if (goal.actual.level != null)
          IconText(
            text: 'Level: ${goal.actual.level}',
            icon: Icons.leaderboard,
            iconColor: Colors.yellow,
            endGap: 8,
          ),
      ],
    );
  }

  Widget _buildDeleteWeightGoalProgressSet(WeightGoalProgress goal, int index) {
    return InkWell(
      customBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      onTap: () {
        setState(() {
          goal.sets.removeAt(index);
        });
      },
      child: Icon(Icons.close, color: Colors.red, size: 16),
    );
  }

  Widget _buildEditWeightGoalProgressSet(WeightGoalProgress goal, int index) {
    final set = goal.sets[index];
    return InkWell(
      customBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      onTap: () async {
        await showDialog(
          context: context,
          builder: (context) {
            return WeightGoalProgressSetDialog(set: set);
          },
        );
        setState(() {});
      },
      child: Icon(Icons.edit, color: Colors.blue, size: 16),
    );
  }

  Widget _buildWeightGoalProgressBody(WeightGoalProgress goal) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: FixedTimeline.tileBuilder(
        theme: TimelineThemeData(
          nodePosition: 0,
          connectorTheme: ConnectorThemeData(
            thickness: 1.5,
            color: Color(0xffd3d3d3),
          ),
          indicatorTheme: IndicatorThemeData(size: 16),
        ),
        builder: TimelineTileBuilder.connected(
          itemCount: goal.sets.length,
          contentsBuilder: (context, index) {
            final set = goal.sets[index];
            return WeightGoalProgressSetTile(
              goal: goal,
              set: set,
              action: set.status == ProgressStatus.completed
                  ? _buildEditWeightGoalProgressSet(goal, index)
                  : (set.status == ProgressStatus.planned &&
                          index > goal.goal.sets - 1
                      ? _buildDeleteWeightGoalProgressSet(goal, index)
                      : null),
            );
          },
          connectorBuilder: (_, index, __) {
            final set = goal.sets[index];

            return SolidLineConnector(color: set.status.color);
          },
          indicatorBuilder: (_, index) {
            final set = goal.sets[index];
            switch (set.status) {
              case ProgressStatus.planned:
                return DotIndicator(
                  color: set.status.color,
                  child: Icon(set.status.icon, color: Colors.white, size: 8),
                );
              case ProgressStatus.inProgress:
                return DotIndicator(
                  color: set.status.color,
                  child: Icon(set.status.icon, color: Colors.white, size: 8),
                );
              case ProgressStatus.completed:
                return DotIndicator(
                  color: set.status.color,
                  child: Icon(set.status.icon, color: Colors.white, size: 8),
                );
            }
          },
        ),
      ),
    );
  }

  Widget _buildWeightGoalProgressHeader(
    ActivityExercise exercise,
    WeightGoalProgress goal,
  ) {
    final isRunEnabled = goal != selectedGoal;

    return Row(
      children: [
        Expanded(child: _buildGoalStats(goal)),
        if (goal.status != ProgressStatus.completed)
          CompactButton(
            text: 'Run',
            onPressed:
                isRunEnabled ? () => _runGoalProgress(exercise, goal) : null,
          ),
      ],
    );
  }

  Widget _buildCardioGoalProgressHeader(
    ActivityExercise exercise,
    CardioGoalProgress goal,
  ) {
    final isRunEnabled = goal != selectedGoal;

    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildGoalStats(goal),
          ),
        ),
        if (goal.status != ProgressStatus.completed)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: CompactButton(
              text: 'Run',
              onPressed:
                  isRunEnabled ? () => _runGoalProgress(exercise, goal) : null,
            ),
          ),
      ],
    );
  }

  Widget _buildGoalStats(
    GoalProgress goal, {
    WrapAlignment wrapAlignment = WrapAlignment.start,
  }) {
    if (goal is WeightGoalProgress) {
      return WeightGoalProgressStats(goal: goal, wrapAlignment: wrapAlignment);
    }

    if (goal is CardioGoalProgress) {
      return CardioGoalProgressStats(goal: goal, wrapAlignment: wrapAlignment);
    }

    return Center(child: Text('Not implemented'));
  }
}
