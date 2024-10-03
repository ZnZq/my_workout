import 'package:duration_picker/duration_picker.dart';
import 'package:flutter/material.dart';
import 'package:my_workout/models/goal.dart';
import 'package:my_workout/utils.dart';
import 'package:numberpicker/numberpicker.dart';
import 'dart:math' as math;

class GoalCardioDialog extends StatefulWidget {
  final CardioGoal goal;

  const GoalCardioDialog({super.key, required this.goal});

  @override
  State<GoalCardioDialog> createState() => _GoalCardioDialogState();
}

class _GoalCardioDialogState extends State<GoalCardioDialog>
    with TickerProviderStateMixin {
  bool useDuration = false;
  bool useHeartRate = false;
  bool useSpeed = false;
  bool useDistance = false;
  bool useIntensity = false;
  bool useLevel = false;

  final minDuration = const Duration(seconds: 0);
  final int minHeartRate = 40;
  final int maxHeartRate = 300;
  final double minSpeed = 0;
  final double maxSpeed = 999;
  final double minDistance = 0;
  final double maxDistance = 999;
  final double minIntensity = 0;
  final double maxIntensity = 999;
  final double minLevel = 0;
  final double maxLevel = 999;

  bool expandDuration = false;
  bool expandHeartRate = false;
  bool expandSpeed = false;
  bool expandDistance = false;
  bool expandIntensity = false;
  bool expandLevel = false;

  late final AnimationController _expandDurationcontroller;
  late final AnimationController _expandHeartRatecontroller;
  late final AnimationController _expandSpeedcontroller;
  late final AnimationController _expandDistancecontroller;
  late final AnimationController _expandIntensitycontroller;
  late final AnimationController _expandLevelcontroller;

  Duration duration = const Duration(seconds: 0);
  int heartRate = 0;
  double speed = 0;
  double distance = 0;
  double intensity = 0;
  double level = 0;

  @override
  void initState() {
    const expandDuration = Duration(milliseconds: 250);
    _expandDurationcontroller =
        AnimationController(vsync: this, duration: expandDuration);
    _expandHeartRatecontroller =
        AnimationController(vsync: this, duration: expandDuration);
    _expandSpeedcontroller =
        AnimationController(vsync: this, duration: expandDuration);
    _expandDistancecontroller =
        AnimationController(vsync: this, duration: expandDuration);
    _expandIntensitycontroller =
        AnimationController(vsync: this, duration: expandDuration);
    _expandLevelcontroller =
        AnimationController(vsync: this, duration: expandDuration);

    useDuration = widget.goal.duration != null;
    useHeartRate = widget.goal.heartRate != null;
    useSpeed = widget.goal.speed != null;
    useDistance = widget.goal.distance != null;
    useIntensity = widget.goal.intensity != null;
    useLevel = widget.goal.level != null;

    duration = widget.goal.duration ?? minDuration;
    heartRate = widget.goal.heartRate ?? minHeartRate;
    speed = widget.goal.speed ?? minSpeed;
    distance = widget.goal.distance ?? minDistance;
    intensity = widget.goal.intensity ?? minIntensity;
    level = widget.goal.level ?? minLevel;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final elevatedButtonStyle = ElevatedButton.styleFrom(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      minimumSize: Size(0, 0),
      elevation: 0,
    );

    return AlertDialog(
      title: Text('${widget.goal.executeMethod.name} goal'),
      actionsPadding: EdgeInsets.only(left: 4, right: 8, bottom: 8),
      contentPadding: EdgeInsets.only(left: 8, right: 8),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPropertyHeader(
              'Duration',
              formatDuration(duration),
              useDuration,
              onDurationExpandChange,
              onUseDurationChange,
              _expandDurationcontroller,
            ),
            _buildDurationBody(elevatedButtonStyle),
            _buildPropertyHeader(
              'Heart rate',
              heartRate.toString(),
              useHeartRate,
              onHeartRateExpandChange,
              onUseHeartRateChange,
              _expandHeartRatecontroller,
            ),
            _buildHeartRateBody(elevatedButtonStyle),
            _buildPropertyHeader(
              'Speed',
              speed.toString(),
              useSpeed,
              onSpeedExpandChange,
              onUseSpeedChange,
              _expandSpeedcontroller,
            ),
            _buildSpeedBody(elevatedButtonStyle),
            _buildPropertyHeader(
              'Distance',
              distance.toString(),
              useDistance,
              onDistanceExpandChange,
              onUseDistanceChange,
              _expandDistancecontroller,
            ),
            _buildDistanceBody(elevatedButtonStyle),
            _buildPropertyHeader(
              'Intensity',
              intensity.toString(),
              useIntensity,
              onIntensityExpandChange,
              onUseIntensityChange,
              _expandIntensitycontroller,
            ),
            _buildIntensityBody(elevatedButtonStyle),
            _buildPropertyHeader(
              'Level',
              level.toString(),
              useLevel,
              onLevelExpandChange,
              onUseLevelChange,
              _expandLevelcontroller,
            ),
            _buildLevelBody(elevatedButtonStyle),
          ],
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
            final goal = generateGoal();
            Navigator.of(context).pop(goal);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  Widget _buildPropertyHeader(
    String name,
    String displayValue,
    bool isUse,
    void Function() expandChange,
    void Function(bool?) useChange,
    AnimationController controller,
  ) {
    return Row(
      children: [
        Checkbox(value: isUse, onChanged: useChange),
        Text(isUse ? '$name: $displayValue' : '$name: -'),
        if (isUse) ...[
          Spacer(),
          AnimatedBuilder(
            animation: controller,
            child: IconButton(
              onPressed: expandChange,
              icon: Icon(Icons.keyboard_arrow_down_sharp),
              iconSize: 16,
            ),
            builder: (BuildContext context, Widget? child) {
              return Transform.rotate(
                angle: controller.value * math.pi,
                child: child,
              );
            },
          ),
        ]
      ],
    );
  }

  Goal generateGoal() {
    final duration =
        useDuration && this.duration != minDuration ? this.duration : null;
    final heartRate = useHeartRate ? this.heartRate : null;
    final speed = useSpeed && this.speed != minSpeed ? this.speed : null;
    final distance =
        useDistance && this.distance != minDistance ? this.distance : null;
    final intensity =
        useIntensity && this.intensity != minIntensity ? this.intensity : null;
    final level = useLevel && this.level != minLevel ? this.level : null;

    return CardioGoal(
      id: widget.goal.id,
      duration: duration,
      heartRate: heartRate,
      speed: speed,
      distance: distance,
      intensity: intensity,
      level: level,
    );
  }

  Widget _buildLevelBody(ButtonStyle elevatedButtonStyle) {
    return AnimatedBuilder(
      animation: _expandLevelcontroller,
      builder: (context, child) {
        return SizeTransition(
          sizeFactor: _expandLevelcontroller,
          child: child,
        );
      },
      child: Row(
        children: [
          ElevatedButton(
            style: elevatedButtonStyle,
            onPressed: () => setState(
              () => level = (level - 5.0).clamp(minLevel, maxLevel),
            ),
            child: Text('-5'),
          ),
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 150),
              child: Card(
                child: DecimalNumberPicker(
                  axis: Axis.horizontal,
                  itemWidth: 45,
                  itemHeight: 45,
                  value: level,
                  minValue: minLevel.toInt(),
                  maxValue: maxLevel.toInt(),
                  onChanged: (value) => setState(() => level = value),
                ),
              ),
            ),
          ),
          ElevatedButton(
            style: elevatedButtonStyle,
            onPressed: () => setState(
              () => level = (level + 5.0).clamp(minLevel, maxLevel),
            ),
            child: Text('+5'),
          ),
        ],
      ),
    );
  }

  Widget _buildIntensityBody(ButtonStyle elevatedButtonStyle) {
    return AnimatedBuilder(
      animation: _expandIntensitycontroller,
      builder: (context, child) {
        return SizeTransition(
          sizeFactor: _expandIntensitycontroller,
          child: child,
        );
      },
      child: Row(
        children: [
          ElevatedButton(
            style: elevatedButtonStyle,
            onPressed: () => setState(
              () => intensity =
                  (intensity - 5.0).clamp(minIntensity, maxIntensity),
            ),
            child: Text('-5'),
          ),
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 150),
              child: Card(
                child: DecimalNumberPicker(
                  axis: Axis.horizontal,
                  itemWidth: 45,
                  itemHeight: 45,
                  value: intensity,
                  minValue: minIntensity.toInt(),
                  maxValue: maxIntensity.toInt(),
                  onChanged: (value) => setState(() => intensity = value),
                ),
              ),
            ),
          ),
          ElevatedButton(
            style: elevatedButtonStyle,
            onPressed: () => setState(
              () => intensity =
                  (intensity + 5.0).clamp(minIntensity, maxIntensity),
            ),
            child: Text('+5'),
          ),
        ],
      ),
    );
  }

  Widget _buildDistanceBody(ButtonStyle elevatedButtonStyle) {
    return AnimatedBuilder(
      animation: _expandDistancecontroller,
      builder: (context, child) {
        return SizeTransition(
          sizeFactor: _expandDistancecontroller,
          child: child,
        );
      },
      child: Row(
        children: [
          ElevatedButton(
            style: elevatedButtonStyle,
            onPressed: () => setState(
              () => distance = (distance - 5.0).clamp(minDistance, maxDistance),
            ),
            child: Text('-5'),
          ),
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 150),
              child: Card(
                child: DecimalNumberPicker(
                  axis: Axis.horizontal,
                  itemWidth: 45,
                  itemHeight: 45,
                  value: distance,
                  minValue: minDistance.toInt(),
                  maxValue: maxDistance.toInt(),
                  onChanged: (value) => setState(() => distance = value),
                ),
              ),
            ),
          ),
          ElevatedButton(
            style: elevatedButtonStyle,
            onPressed: () => setState(
              () => distance = (distance + 5.0).clamp(minDistance, maxDistance),
            ),
            child: Text('+5'),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedBody(ButtonStyle elevatedButtonStyle) {
    return AnimatedBuilder(
      animation: _expandSpeedcontroller,
      builder: (context, child) {
        return SizeTransition(
          sizeFactor: _expandSpeedcontroller,
          child: child,
        );
      },
      child: Row(
        children: [
          ElevatedButton(
            style: elevatedButtonStyle,
            onPressed: () => setState(
              () => speed = (speed - 5.0).clamp(minSpeed, maxSpeed),
            ),
            child: Text('-5'),
          ),
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 150),
              child: Card(
                child: DecimalNumberPicker(
                  axis: Axis.horizontal,
                  itemWidth: 45,
                  itemHeight: 45,
                  value: speed,
                  minValue: minSpeed.toInt(),
                  maxValue: maxSpeed.toInt(),
                  onChanged: (value) => setState(() => speed = value),
                ),
              ),
            ),
          ),
          ElevatedButton(
            style: elevatedButtonStyle,
            onPressed: () => setState(
              () => speed = (speed + 5.0).clamp(minSpeed, maxSpeed),
            ),
            child: Text('+5'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeartRateBody(ButtonStyle elevatedButtonStyle) {
    return AnimatedBuilder(
      animation: _expandHeartRatecontroller,
      builder: (context, child) {
        return SizeTransition(
          sizeFactor: _expandHeartRatecontroller,
          child: child,
        );
      },
      child: Row(
        children: [
          ElevatedButton(
            style: elevatedButtonStyle,
            onPressed: () => setState(
              () =>
                  heartRate = (heartRate - 5).clamp(minHeartRate, maxHeartRate),
            ),
            child: Text('-5'),
          ),
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 150),
              child: Center(
                child: Card(
                  child: NumberPicker(
                    axis: Axis.horizontal,
                    itemWidth: 45,
                    value: heartRate,
                    minValue: minHeartRate,
                    maxValue: maxHeartRate,
                    onChanged: (value) => setState(() => heartRate = value),
                  ),
                ),
              ),
            ),
          ),
          ElevatedButton(
            style: elevatedButtonStyle,
            onPressed: () => setState(
              () =>
                  heartRate = (heartRate + 5).clamp(minHeartRate, maxHeartRate),
            ),
            child: Text('+5'),
          ),
        ],
      ),
    );
  }

  Widget _buildDurationBody(ButtonStyle elevatedButtonStyle) {
    return AnimatedBuilder(
      animation: _expandDurationcontroller,
      builder: (context, child) {
        return SizeTransition(
          sizeFactor: _expandDurationcontroller,
          child: child,
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                style: elevatedButtonStyle,
                onPressed: () => _addDuration(Duration(minutes: -1)),
                child: Text('-1m'),
              ),
              ElevatedButton(
                style: elevatedButtonStyle,
                onPressed: () => _addDuration(Duration(minutes: -5)),
                child: Text('-5m'),
              ),
              ElevatedButton(
                style: elevatedButtonStyle,
                onPressed: () => _addDuration(Duration(minutes: -30)),
                child: Text('-30m'),
              ),
            ],
          ),
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: DurationPicker(
                  duration: duration,
                  lowerBound: minDuration,
                  onChange: (value) => setState(() => duration = value),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                style: elevatedButtonStyle,
                onPressed: () => _addDuration(Duration(minutes: 1)),
                child: Text('+1m'),
              ),
              ElevatedButton(
                style: elevatedButtonStyle,
                onPressed: () => _addDuration(Duration(minutes: 5)),
                child: Text('+5m'),
              ),
              ElevatedButton(
                style: elevatedButtonStyle,
                onPressed: () => _addDuration(Duration(minutes: 30)),
                child: Text('+30m'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void onDurationExpandChange() {
    setState(() {
      expandDuration = !expandDuration;
      if (expandDuration) {
        _expandDurationcontroller.forward();
      } else {
        _expandDurationcontroller.reverse();
      }
    });
  }

  void onUseDurationChange(bool? value) {
    setState(() {
      useDuration = value!;
      if (!useDuration) {
        expandDuration = false;
        _expandDurationcontroller.reverse();
      }
    });
  }

  void onHeartRateExpandChange() {
    setState(() {
      expandHeartRate = !expandHeartRate;
      if (expandHeartRate) {
        _expandHeartRatecontroller.forward();
      } else {
        _expandHeartRatecontroller.reverse();
      }
    });
  }

  void onUseHeartRateChange(bool? value) {
    setState(() {
      useHeartRate = value!;
      if (!useHeartRate) {
        expandHeartRate = false;
        _expandHeartRatecontroller.reverse();
      }
    });
  }

  void onSpeedExpandChange() {
    setState(() {
      expandSpeed = !expandSpeed;
      if (expandSpeed) {
        _expandSpeedcontroller.forward();
      } else {
        _expandSpeedcontroller.reverse();
      }
    });
  }

  void onUseSpeedChange(bool? value) {
    setState(() {
      useSpeed = value!;
      if (!useSpeed) {
        expandSpeed = false;
        _expandSpeedcontroller.reverse();
      }
    });
  }

  void onDistanceExpandChange() {
    setState(() {
      expandDistance = !expandDistance;
      if (expandDistance) {
        _expandDistancecontroller.forward();
      } else {
        _expandDistancecontroller.reverse();
      }
    });
  }

  void onUseDistanceChange(bool? value) {
    setState(() {
      useDistance = value!;
      if (!useDistance) {
        expandDistance = false;
        _expandDistancecontroller.reverse();
      }
    });
  }

  void onIntensityExpandChange() {
    setState(() {
      expandIntensity = !expandIntensity;
      if (expandIntensity) {
        _expandIntensitycontroller.forward();
      } else {
        _expandIntensitycontroller.reverse();
      }
    });
  }

  void onUseIntensityChange(bool? value) {
    setState(() {
      useIntensity = value!;
      if (!useIntensity) {
        expandIntensity = false;
        _expandIntensitycontroller.reverse();
      }
    });
  }

  void onLevelExpandChange() {
    setState(() {
      expandLevel = !expandLevel;
      if (expandLevel) {
        _expandLevelcontroller.forward();
      } else {
        _expandLevelcontroller.reverse();
      }
    });
  }

  void onUseLevelChange(bool? value) {
    setState(() {
      useLevel = value!;
      if (!useLevel) {
        expandLevel = false;
        _expandLevelcontroller.reverse();
      }
    });
  }

  void _addDuration(Duration duration) {
    setState(
      () {
        final newDuration = this.duration + duration;
        this.duration = newDuration <= minDuration ? minDuration : newDuration;
      },
    );
  }
}
