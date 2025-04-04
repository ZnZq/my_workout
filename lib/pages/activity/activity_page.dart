import 'package:flutter/material.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
import 'package:my_workout/data.dart';
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
import 'package:my_workout/pages/activity/report_page.dart';
import 'package:my_workout/storage/storage.dart';
import 'package:my_workout/utils.dart';
import 'package:my_workout/widgets/activity_exercise_tab.dart';
import 'package:my_workout/widgets/cardio_goal_progress_stats.dart';
import 'package:my_workout/widgets/compact_button.dart';
import 'package:my_workout/widgets/delayed_button.dart';
import 'package:my_workout/widgets/icon_text.dart';
import 'package:my_workout/widgets/num_stat_tile.dart';
import 'package:my_workout/widgets/weight_goal_progress_set_tile.dart';
import 'package:my_workout/widgets/weight_goal_progress_stats.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:timelines_plus/timelines_plus.dart';

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

  void _generateReport() {
    final activity = buildActivity(true);
    Navigator.of(context)
        .pushNamed<String?>(ReportPage.route, arguments: activity);
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
              if (presetMillisecond != 0) {
                await vibrateThreeTimes();
              }
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
            PopupMenuButton(
              icon: const Icon(Icons.more_vert),
              itemBuilder: (context) {
                return [
                  const PopupMenuItem(
                    value: 'rename',
                    child: IconText(
                      icon: Icons.edit,
                      text: 'Rename',
                      iconColor: Colors.white,
                    ),
                  ),
                  const PopupMenuItem(
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
      return const Center(child: Text('No goal selected'));
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

    return const Center(child: Text('Not implemented'));
  }

  Widget _buildActiveCardioGoalProgress(
    BuildContext context,
    CardioGoalProgress goal,
  ) {
    final actual = goal.actual;

    // final elevatedButtonStyle = ElevatedButton.styleFrom(
    //   padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
    //   minimumSize: Size(0, 0),
    //   elevation: 0,
    // );

    final gridItems = goal.status != ProgressStatus.inProgress
        ? <Widget>[]
        : <Widget>[
            if (goal.actual.heartRate != null) ...[
              NumStatTile<int>(
                icon: ui.stat.heartRate.icon,
                iconColor: ui.stat.heartRate.color,
                title: ui.stat.heartRate.name,
                value: actual.heartRate!,
                minValue: ui.stat.heartRate.minValue,
                maxValue: ui.stat.heartRate.maxValue,
                valueFormatter: (value) => '$value / ${goal.goal.heartRate!}',
                onChanged: (value) =>
                    setState(() => goal.actual.heartRate = value),
              ),
            ],
            if (goal.actual.speed != null) ...[
              NumStatTile<double>(
                icon: ui.stat.speed.icon,
                iconColor: ui.stat.speed.color,
                title: ui.stat.speed.name,
                value: actual.speed!,
                minValue: ui.stat.speed.minValue,
                maxValue: ui.stat.speed.maxValue,
                valueFormatter: (value) =>
                    '${value.toStringAsFixed(1)} / ${goal.goal.speed!.toStringAsFixed(1)}',
                onChanged: (value) => setState(() => goal.actual.speed = value),
              ),
            ],
            if (goal.actual.distance != null) ...[
              NumStatTile<double>(
                icon: ui.stat.distance.icon,
                iconColor: ui.stat.distance.color,
                title: ui.stat.distance.name,
                value: actual.distance!,
                minValue: ui.stat.distance.minValue,
                maxValue: ui.stat.distance.maxValue,
                valueFormatter: (value) =>
                    '${value.toStringAsFixed(1)} / ${goal.goal.distance!.toStringAsFixed(1)}',
                onChanged: (value) =>
                    setState(() => goal.actual.distance = value),
              ),
            ],
            if (goal.actual.intensity != null) ...[
              NumStatTile<double>(
                icon: ui.stat.intensity.icon,
                iconColor: ui.stat.intensity.color,
                title: ui.stat.intensity.name,
                value: actual.intensity!,
                minValue: ui.stat.intensity.minValue,
                maxValue: ui.stat.intensity.maxValue,
                valueFormatter: (value) =>
                    '${value.toStringAsFixed(1)} / ${goal.goal.intensity!.toStringAsFixed(1)}',
                onChanged: (value) =>
                    setState(() => goal.actual.intensity = value),
              ),
            ],
            if (goal.actual.level != null) ...[
              NumStatTile<double>(
                icon: ui.stat.level.icon,
                iconColor: ui.stat.level.color,
                title: ui.stat.level.name,
                value: actual.level!,
                minValue: ui.stat.level.minValue,
                maxValue: ui.stat.level.maxValue,
                valueFormatter: (value) =>
                    '${value.toStringAsFixed(1)} / ${goal.goal.level!.toStringAsFixed(1)}',
                onChanged: (value) => setState(() => goal.actual.level = value),
              ),
            ],
            if (goal.actual.incline != null) ...[
              NumStatTile<double>(
                icon: ui.stat.incline.icon,
                iconColor: ui.stat.incline.color,
                title: ui.stat.incline.name,
                value: actual.incline!,
                minValue: ui.stat.incline.minValue,
                maxValue: ui.stat.incline.maxValue,
                valueFormatter: (value) =>
                    '${value.toStringAsFixed(1)} / ${goal.goal.incline!.toStringAsFixed(1)}',
                onChanged: (value) =>
                    setState(() => goal.actual.incline = value),
              ),
            ],
          ];

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(left: 12, right: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (selectedExercise != null) ...[
              _buildSelectedExerciseCard(goal),
              const SizedBox(height: 8),
            ],
            // _buildGoalProgressStats(goal),
            // SizedBox(height: 8),
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
                    goal.actual.incline = goal.goal.incline;
                    initCardioStopWatchTimer(goal);
                  });
                },
                child: const Text('Start goal'),
              ),
            if (goal.status == ProgressStatus.inProgress) ...[
              _buildCardioGoalProgressTimer(goal),
              const SizedBox(height: 4),
              if (gridItems.isNotEmpty) ...[
                GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 3,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1 / 1,
                  children: gridItems,
                ),
              ],
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    goal.status = ProgressStatus.completed;
                    stopWatchTimer!.onStopTimer();
                  });
                },
                child: const Text('Complete goal'),
              ),
              const SizedBox(height: 8),
            ],
            if (goal.status == ProgressStatus.completed) ...[
              const Center(child: Text('Goal completed'))
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
            Icon(
              ui.stat.duration.icon,
              color: ui.stat.duration.color,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(goal.goal.duration == null
                ? formatDuration(goal.actual.duration!)
                : '${formatDuration(goal.actual.duration!)}/${formatDuration(goal.goal.duration!)}'),
            const Spacer(),
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
              const SizedBox(width: 8),
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

  WeightGoalProgressSet getNextSet(WeightGoalProgress goal) {
    final set = goal.sets.firstWhere(
      (e) => !e.isDone,
      orElse: () => goal.sets.last,
    );

    return set;
  }

  Widget _buildActiveWeightGoalProgress(
    BuildContext context,
    WeightGoalProgress goal,
  ) {
    final set = getNextSet(goal);

    final gridItems = goal.status != ProgressStatus.inProgress
        ? <Widget>[]
        : <Widget>[
            NumStatTile<int>(
              icon: ui.stat.reps.icon,
              iconColor: ui.stat.reps.color,
              title: ui.stat.reps.name,
              value: set.reps,
              minValue: ui.stat.reps.minValue,
              maxValue: ui.stat.reps.maxValue,
              valueFormatter: (value) => '$value / ${goal.goal.reps}',
              onChanged: (value) => setState(() => set.reps = value),
            ),
            if (goal.goal.weight != 0) ...[
              NumStatTile<double>(
                icon: ui.stat.weight.icon,
                iconColor: ui.stat.weight.color,
                title: ui.stat.weight.name,
                value: set.weight,
                minValue: ui.stat.weight.minValue,
                maxValue: ui.stat.weight.maxValue,
                valueFormatter: (value) =>
                    '${value.toStringAsFixed(1)} / ${goal.goal.weight.toStringAsFixed(1)}',
                onChanged: (value) => setState(() => set.weight = value),
              ),
            ],
          ];

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(left: 12, right: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (selectedExercise != null) ...[
              _buildSelectedExerciseCard(goal, set: set),
              const SizedBox(height: 8),
            ],
            _buildGoalProgressStats(goal),
            const SizedBox(height: 4),
            if (set.status == ProgressStatus.planned)
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    set.status = ProgressStatus.inProgress;
                    set.reps = goal.goal.reps;
                    set.weight = goal.goal.weight;
                  });
                },
                child: const Text('Start set'),
              ),
            if (set.status == ProgressStatus.inProgress) ...[
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: gridItems.length,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: gridItems.length == 1 ? 3 / 1 : 1.5 / 1,
                children: gridItems,
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    set.status = ProgressStatus.completed;
                    set.endRestAt = DateTime.now().add(goal.goal.rest);
                  });
                },
                child: const Text('Complete set'),
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
                        const Text('Resting'),
                        const SizedBox(height: 12),
                        Center(
                          child: TimerCountdown(
                            format: CountDownTimerFormat.hoursMinutesSeconds,
                            endTime: set.endRestAt!,
                            onEnd: set.endRestAt!.isAfter(DateTime.now())
                                ? () async {
                                    await vibrateThreeTimes();
                                    setState(() {});
                                  }
                                : null,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 4),
              ],
              if (set == goal.sets.last)
                ElevatedButton(
                  onPressed: () async {
                    preventSkipRest(set, () {
                      setState(() {
                        set.isDone = true;
                        goal.sets.add(WeightGoalProgressSet(
                          reps: 0,
                          weight: 0,
                          status: ProgressStatus.planned,
                        ));
                      });
                    });
                  },
                  child: const Text('Add set'),
                ),
              set != goal.sets.last && set.endRestAt!.isAfter(DateTime.now())
                  ? ElevatedButton(
                      onPressed: () => _goNextSet(set, goal),
                      child: const Text('Next set'),
                    )
                  : set != goal.sets.last
                      ? DelayedButton(
                          onPressed: () => _goNextSet(set, goal),
                          child: const Text('Next set'),
                        )
                      : const SizedBox(),
            ]
          ],
        ),
      ),
    );
  }

  void _goNextSet(WeightGoalProgressSet set, WeightGoalProgress goal) {
    preventSkipRest(set, () {
      setState(() {
        set.isDone = true;
        final nextSet = getNextSet(goal);
        if (nextSet.status == ProgressStatus.planned) {
          nextSet.status = ProgressStatus.inProgress;
          nextSet.reps = goal.goal.reps;
          nextSet.weight = goal.goal.weight;
        }
      });
    });
  }

  Future<void> preventSkipRest(
      WeightGoalProgressSet set, VoidCallback callback) async {
    if (set.endRestAt != null && set.endRestAt!.isAfter(DateTime.now())) {
      final answer = await askDialog(context, 'Do you want to skip rest?');
      if (answer == false) {
        return;
      }
    }

    callback();
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
                  Padding(
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          size: 20,
                          selectedExercise!.executeMethod.icon,
                          color: selectedExercise!.executeMethod.color,
                        ),
                        const SizedBox(width: 8),
                        Text(selectedExercise!.name),
                      ],
                    ),
                  ),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     Text(
                  //         'Goal #${selectedExercise!.goalProgress.indexOf(goal) + 1} of ${selectedExercise!.goalProgress.length}'),
                  //     SizedBox(width: 12),
                  //     if (goal is WeightGoalProgress && set != null)
                  //       Text(
                  //           'Set #${goal.sets.indexOf(set) + 1} of ${goal.sets.length}')
                  //   ],
                  // )
                ],
              ),
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: IconButton(
                  padding: const EdgeInsets.all(4),
                  icon: const Icon(Icons.close, size: 16),
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
            const Divider(height: 0),
            Row(
              children: [
                Expanded(
                  child: TabBar(
                    controller: _tabController,
                    dividerHeight: 0,
                    // physics: const NeverScrollableScrollPhysics(),
                    isScrollable: true,
                    tabAlignment: TabAlignment.center,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                    tabs: exercises
                        .map((e) => ActivityExerciseTab(activityExercise: e))
                        .toList(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
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
                      final currentTabIndex = _tabController.index;
                      _tabController = TabController(
                        length: exercises.length,
                        vsync: this,
                      );

                      if (exercises.isEmpty) {
                        return;
                      }

                      _tabController.animateTo(
                          currentTabIndex >= exercises.length
                              ? exercises.length - 1
                              : currentTabIndex);
                    });
                  },
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.only(top: 1),
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

    return const Center(child: Text('Not implemented'));
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
            connectorTheme: const ConnectorThemeData(
              thickness: 3.0,
              color: Color(0xffd3d3d3),
            ),
            indicatorTheme: const IndicatorThemeData(size: 24),
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
            connectorTheme: const ConnectorThemeData(
              thickness: 3.0,
              color: Color(0xffd3d3d3),
            ),
            indicatorTheme: const IndicatorThemeData(size: 24),
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
      margin: const EdgeInsets.only(left: 12, right: 12, bottom: 8),
      clipBehavior: Clip.hardEdge,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            _buildWeightGoalProgressHeader(exercise, goal),
            const Divider(),
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
        child: const Padding(
          padding: EdgeInsets.only(left: 2),
          child: Row(
            children: [
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
      margin: const EdgeInsets.only(left: 12, right: 12, bottom: 8),
      clipBehavior: Clip.hardEdge,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            _buildCardioGoalProgressHeader(exercise, goal),
            const Divider(height: 0),
            const SizedBox(height: 8),
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
            text:
                '${ui.stat.duration.name}: ${formatDuration(goal.actual.duration!)}',
            icon: ui.stat.duration.icon,
            iconColor: ui.stat.duration.color,
            endGap: 8,
          ),
        if (goal.actual.heartRate != null)
          IconText(
            text: '${ui.stat.heartRate.name}: ${goal.actual.heartRate}',
            icon: ui.stat.heartRate.icon,
            iconColor: ui.stat.heartRate.color,
            endGap: 8,
          ),
        if (goal.actual.speed != null)
          IconText(
            text:
                '${ui.stat.speed.name}: ${goal.actual.speed!.toStringAsFixed(1)}',
            icon: ui.stat.speed.icon,
            iconColor: ui.stat.speed.color,
            endGap: 8,
          ),
        if (goal.actual.distance != null)
          IconText(
            text:
                '${ui.stat.distance.name}: ${goal.actual.distance!.toStringAsFixed(1)}',
            icon: ui.stat.distance.icon,
            iconColor: ui.stat.distance.color,
            endGap: 8,
          ),
        if (goal.actual.intensity != null)
          IconText(
            text:
                '${ui.stat.intensity.name}: ${goal.actual.intensity!.toStringAsFixed(1)}',
            icon: ui.stat.intensity.icon,
            iconColor: ui.stat.intensity.color,
            endGap: 8,
          ),
        if (goal.actual.level != null)
          IconText(
            text: '${ui.stat.level.name}: ${goal.actual.level}',
            icon: ui.stat.level.icon,
            iconColor: ui.stat.level.color,
            endGap: 8,
          ),
        if (goal.actual.incline != null)
          IconText(
            text: '${ui.stat.incline.name}: ${goal.actual.incline}',
            icon: ui.stat.incline.icon,
            iconColor: ui.stat.incline.color,
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
      child: const Icon(Icons.close, color: Colors.red, size: 16),
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
      child: const Icon(Icons.edit, color: Colors.blue, size: 16),
    );
  }

  Widget _buildWeightGoalProgressBody(WeightGoalProgress goal) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: FixedTimeline.tileBuilder(
        theme: TimelineThemeData(
          nodePosition: 0,
          connectorTheme: const ConnectorThemeData(
            thickness: 1.5,
            color: Color(0xffd3d3d3),
          ),
          indicatorTheme: const IndicatorThemeData(size: 16),
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

    return const Center(child: Text('Not implemented'));
  }
}
