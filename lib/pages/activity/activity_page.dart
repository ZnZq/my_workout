import 'package:flutter/material.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
import 'package:intl/intl.dart';
import 'package:my_workout/models/activity_exercise.dart';
import 'package:my_workout/models/enum/exercise_execute_method.dart';
import 'package:my_workout/models/goal_progress.dart';
import 'package:my_workout/models/program.dart';
import 'package:my_workout/utils.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:timelines/timelines.dart';

class ActivityPage extends StatefulWidget {
  static const route = '/activity';
  final Program program;

  const ActivityPage({super.key, required this.program});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  StopWatchTimer? stopWatchTimer;
  ActivityExercise? selectedExercise;
  GoalProgress? selectedGoal;
  String title = 'New activity';
  DateTime date = DateTime.now();
  DateFormat dateFormat = DateFormat('dd.MM.yyyy');

  final List<ActivityExercise> exercises = [];

  @override
  void initState() {
    // title with current date + program title
    date = DateTime.now();
    title = widget.program.title;
    // title = '${} ${widget.program.title}';
    exercises.addAll(
      widget.program.exercises.map((e) => ActivityExercise.fromExercise(e)),
    );

    _tabController = TabController(length: exercises.length, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    stopWatchTimer?.dispose();

    super.dispose();
  }

  // void _nextTab() {
  //   if (_tabController.index < _tabController.length - 1) {
  //     _tabController.animateTo(_tabController.index + 1);
  //   }
  // }

  // void _previousTab() {
  //   if (_tabController.index > 0) {
  //     _tabController.animateTo(_tabController.index - 1);
  //   }
  // }

  void _runGoalProgress(ActivityExercise exercise, GoalProgress goal) {
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
    return Scaffold(
      appBar: AppBar(
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(dateFormat.format(date)),
            SizedBox(width: 8),
            Text(title),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(child: _buildActiveExercise(context)),
          Expanded(child: _buildExercises(context)),
        ],
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
            _buildCompactButton(
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
              _buildCompactButton(
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
            child: _buildGoalStats(
              goal,
              wrapAlignment: WrapAlignment.center,
            ),
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
            // if (set.status == ProgressStatus.completed)
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
                  setState(() => set.isDone = true);
                },
                child: Text('Next set'),
              ),
            ]
          ],
        ),
      ),
    );
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
          child: Column(
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
            TabBar(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              isScrollable: true,
              tabAlignment: TabAlignment.center,
              labelPadding: const EdgeInsets.symmetric(horizontal: 4),
              tabs: exercises.map((e) => _buildExerciseTab(e)).toList(),
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

  Widget _buildExerciseTab(ActivityExercise e) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Tab(
        child: Row(
          children: [
            Icon(
              e.executeMethod.icon,
              color: e.executeMethod.color,
              size: 16,
            ),
            SizedBox(width: 4),
            Text(e.name),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseView(BuildContext context, ActivityExercise exercise) {
    if (exercise.executeMethod == ExerciseExecuteMethod.weight) {
      return _buildWeightExercise(context, exercise);
    }

    if (exercise.executeMethod == ExerciseExecuteMethod.cardio) {
      return _buildCardioExercise(context, exercise);
    }

    return Center(child: Text('Not implemented'));
  }

  Widget _buildCardioExercise(
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

  Widget _buildWeightExercise(
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
            _buildWeightGoalProgressBody(goal)
          ],
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
      children: [
        if (goal.actual.duration != null)
          Row(
            children: [
              Icon(Icons.timer_sharp, color: Colors.blue, size: 16),
              SizedBox(width: 4),
              Text('Duration: ${formatDuration(goal.actual.duration!)}'),
              SizedBox(width: 8),
            ],
          ),
        if (goal.actual.heartRate != null)
          Row(
            children: [
              Icon(Icons.favorite, color: Colors.red, size: 16),
              SizedBox(width: 4),
              Text('Heart rate: ${goal.actual.heartRate}'),
              SizedBox(width: 8),
            ],
          ),
        if (goal.actual.speed != null)
          Row(
            children: [
              Icon(Icons.speed, color: Colors.orange, size: 16),
              SizedBox(width: 4),
              Text('Speed: ${goal.actual.speed!.toStringAsFixed(1)}'),
              SizedBox(width: 8),
            ],
          ),
        if (goal.actual.distance != null)
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.indigo, size: 16),
              SizedBox(width: 4),
              Text('Distance: ${goal.actual.distance!.toStringAsFixed(1)}'),
              SizedBox(width: 8),
            ],
          ),
        if (goal.actual.intensity != null)
          Row(
            children: [
              Icon(Icons.bolt, color: Colors.green, size: 16),
              SizedBox(width: 4),
              Text('Intensity: ${goal.actual.intensity!.toStringAsFixed(1)}'),
              SizedBox(width: 8),
            ],
          ),
        if (goal.actual.level != null)
          Row(
            children: [
              Icon(Icons.leaderboard, color: Colors.yellow, size: 16),
              SizedBox(width: 4),
              Text('Level: ${goal.actual.level}'),
              SizedBox(width: 8),
            ],
          ),
      ],
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
            return _buildWeightGoalProgressSet(context, goal, goal.sets[index]);
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
          _buildCompactButton(
            text: 'Run',
            onPressed:
                isRunEnabled ? () => _runGoalProgress(exercise, goal) : null,
          ),
      ],
    );
  }

  Widget _buildCompactButton({
    required String text,
    Function()? onPressed,
    Color backgroundColor = Colors.green,
  }) {
    final isEnabled = onPressed != null;
    return Opacity(
      opacity: isEnabled ? 1 : .5,
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: InkWell(
          onTap: isEnabled ? onPressed : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(text),
          ),
        ),
      ),
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
            child: _buildCompactButton(
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
      return _buildWeightGoalStats(goal, wrapAlignment: wrapAlignment);
    }

    if (goal is CardioGoalProgress) {
      return _buildCardioGoalStats(goal, wrapAlignment: wrapAlignment);
    }

    return Center(child: Text('Not implemented'));
  }

  Widget _buildCardioGoalStats(
    CardioGoalProgress goal, {
    WrapAlignment wrapAlignment = WrapAlignment.start,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          alignment: wrapAlignment,
          children: [
            if (goal.goal.duration != null)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.timer_sharp, color: Colors.blue, size: 16),
                  SizedBox(width: 4),
                  Text(
                      '${formatDuration(goal.actual.duration!)}/${formatDuration(goal.goal.duration!)}'),
                  SizedBox(width: 8),
                ],
              ),
            if (goal.goal.heartRate != null)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.favorite, color: Colors.red, size: 16),
                  SizedBox(width: 4),
                  Text('${goal.actual.heartRate}/${goal.goal.heartRate}'),
                  SizedBox(width: 8),
                ],
              ),
            if (goal.goal.speed != null)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.speed, color: Colors.orange, size: 16),
                  SizedBox(width: 4),
                  Text(
                      '${goal.actual.speed!.toStringAsFixed(1)}/${goal.goal.speed!.toStringAsFixed(1)}'),
                  SizedBox(width: 8),
                ],
              ),
            if (goal.goal.distance != null)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_on, color: Colors.indigo, size: 16),
                  SizedBox(width: 4),
                  Text(
                      '${goal.actual.distance!.toStringAsFixed(1)}/${goal.goal.distance!.toStringAsFixed(1)}'),
                  SizedBox(width: 8),
                ],
              ),
            if (goal.goal.intensity != null)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bolt, color: Colors.green, size: 16),
                  SizedBox(width: 4),
                  Text(
                      '${goal.actual.intensity!.toStringAsFixed(1)}/${goal.goal.intensity!.toStringAsFixed(1)}'),
                  SizedBox(width: 8),
                ],
              ),
            if (goal.goal.level != null)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.leaderboard, color: Colors.yellow, size: 16),
                  SizedBox(width: 4),
                  Text(
                      '${goal.actual.level!.toStringAsFixed(1)}/${goal.goal.level!.toStringAsFixed(1)}'),
                  SizedBox(width: 8),
                ],
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildWeightGoalStats(
    WeightGoalProgress goal, {
    WrapAlignment wrapAlignment = WrapAlignment.start,
  }) {
    final completeSets = goal.completedSets;
    final completeRepsCount = completeSets
        .map((e) => e.reps / goal.goal.reps)
        .fold(0.0, (a, b) => a + b);
    final completedWeightTotal =
        completeSets.map((e) => e.weight).fold(0.0, (a, b) => a + b);
    final completedWeightAvg = completedWeightTotal == 0
        ? 0
        : completedWeightTotal / completeSets.length;

    final completeRepsCountStr =
        completeRepsCount.toStringAsFixed(completeRepsCount % 1 == 0 ? 0 : 1);

    final maxComplete = goal.sets.length *
        goal.goal.reps *
        (goal.goal.weight == 0 ? 1 : goal.goal.weight);
    final currentComplete = completeSets.length *
        completeRepsCount *
        (goal.goal.weight == 0 ? 1 : completedWeightAvg);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          alignment: wrapAlignment,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.play_arrow, color: Colors.orange, size: 16),
                SizedBox(width: 4),
                Text('${completeSets.length}/${goal.sets.length}'),
                SizedBox(width: 8),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.repeat, color: Colors.green, size: 16),
                SizedBox(width: 4),
                Text('$completeRepsCountStr/${goal.goal.reps}'),
                SizedBox(width: 8),
              ],
            ),
            if (goal.goal.weight != 0) ...[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.fitness_center, color: Colors.blue, size: 16),
                  SizedBox(width: 4),
                  Text(
                    '${completedWeightAvg.toStringAsFixed(1)}/${goal.goal.weight.toStringAsFixed(1)}',
                  ),
                  SizedBox(width: 8),
                ],
              ),
            ],
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.query_stats, color: Colors.indigo, size: 16),
                SizedBox(width: 4),
                Text(
                  'Goal completed by ${(currentComplete / maxComplete * 100).toStringAsFixed(2)}%',
                ),
              ],
            ),
          ],
        )
        // Row(
        //   mainAxisSize: MainAxisSize.min,
        //   children: [
        //     Icon(Icons.play_arrow, color: Colors.orange, size: 16),
        //     SizedBox(width: 4),
        //     Text('${completeSets.length}/${goal.sets.length}'),
        //     SizedBox(width: 8),
        //     Icon(Icons.repeat, color: Colors.green, size: 16),
        //     SizedBox(width: 4),
        //     Text('$completeRepsCountStr/${goal.goal.reps}'),
        //     if (goal.goal.weight != 0) ...[
        //       SizedBox(width: 8),
        //       Icon(Icons.fitness_center, color: Colors.blue, size: 16),
        //       SizedBox(width: 4),
        //       Text(
        //         '${completedWeightAvg.toStringAsFixed(1)}/${goal.goal.weight.toStringAsFixed(1)}',
        //       ),
        //     ],
        //   ],
        // ),
        // Row(
        //   mainAxisSize: MainAxisSize.min,
        //   children: [
        //     Icon(Icons.query_stats, color: Colors.indigo, size: 16),
        //     SizedBox(width: 4),
        //     Text(
        //       'Goal completed by ${(currentComplete / maxComplete * 100).toStringAsFixed(2)}%',
        //     )
        //   ],
        // )
      ],
    );
  }

  Widget _buildWeightGoalProgressSet(
    BuildContext context,
    WeightGoalProgress goal,
    WeightGoalProgressSet set,
  ) {
    return Opacity(
      opacity: set.status == ProgressStatus.completed ? 1 : .5,
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
                  Icon(Icons.repeat, color: Colors.green, size: 16),
                  SizedBox(width: 4),
                  Text('Reps: ${set.reps.toString()}'),
                  if (goal.goal.weight != 0) ...[
                    SizedBox(width: 8),
                    Icon(Icons.fitness_center, color: Colors.blue, size: 16),
                    SizedBox(width: 4),
                    Text('Weight: ${set.weight.toStringAsFixed(1)}'),
                  ]
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
