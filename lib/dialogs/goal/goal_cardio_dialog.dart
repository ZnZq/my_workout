import 'package:duration_picker/duration_picker.dart';
import 'package:flutter/material.dart';
import 'package:my_workout/data.dart';
import 'package:my_workout/models/goal.dart';
import 'package:my_workout/widgets/duration_stat_tile.dart';
import 'package:my_workout/widgets/num_stat_tile.dart';

class GoalCardioDialog extends StatefulWidget {
  final CardioGoal goal;

  const GoalCardioDialog({super.key, required this.goal});

  @override
  State<GoalCardioDialog> createState() => _GoalCardioDialogState();
}

class _GoalCardioDialogState extends State<GoalCardioDialog>
    with TickerProviderStateMixin {
  Duration duration = const Duration(seconds: 0);
  int heartRate = 0;
  double speed = 0;
  double distance = 0;
  double intensity = 0;
  double level = 0;
  double incline = 0;

  @override
  void initState() {
    duration = widget.goal.duration ?? Duration.zero;
    heartRate = widget.goal.heartRate ?? ui.stat.heartRate.minValue;
    speed = widget.goal.speed ?? ui.stat.speed.minValue + 0.0;
    distance = widget.goal.distance ?? ui.stat.distance.minValue + 0.0;
    intensity = widget.goal.intensity ?? ui.stat.intensity.minValue + 0.0;
    level = widget.goal.level ?? ui.stat.level.minValue + 0.0;
    incline = widget.goal.incline ?? ui.stat.incline.minValue + 0.0;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          final goal = generateGoal();
          Navigator.of(context).pop(goal);
        }
      },
      child: AlertDialog(
        title: Text('${widget.goal.executeMethod.name} goal'),
        actionsPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.25 / 1,
            children: [
              Opacity(
                opacity: duration != Duration.zero ? 1 : 0.5,
                child: DurationStatTile(
                  icon: ui.stat.duration.icon,
                  iconColor: ui.stat.duration.color,
                  title: ui.stat.duration.name,
                  baseUnit: BaseUnit.minute,
                  value: duration,
                  onChanged: (value) => setState(() => duration = value),
                ),
              ),
              Opacity(
                opacity: heartRate != ui.stat.heartRate.minValue ? 1 : 0.5,
                child: NumStatTile<int>(
                  icon: ui.stat.heartRate.icon,
                  iconColor: ui.stat.heartRate.color,
                  title: ui.stat.heartRate.name,
                  value: heartRate,
                  onChanged: (value) => setState(() => heartRate = value),
                  minValue: ui.stat.heartRate.minValue,
                  maxValue: ui.stat.heartRate.maxValue,
                ),
              ),
              Opacity(
                opacity: speed != ui.stat.speed.minValue + 0.0 ? 1 : 0.5,
                child: NumStatTile<double>(
                  icon: ui.stat.speed.icon,
                  iconColor: ui.stat.speed.color,
                  title: ui.stat.speed.name,
                  value: speed,
                  onChanged: (value) => setState(() => speed = value),
                  minValue: ui.stat.speed.minValue,
                  maxValue: ui.stat.speed.maxValue,
                ),
              ),
              Opacity(
                opacity: distance != ui.stat.distance.minValue + 0.0 ? 1 : 0.5,
                child: NumStatTile<double>(
                  icon: ui.stat.distance.icon,
                  iconColor: ui.stat.distance.color,
                  title: ui.stat.distance.name,
                  value: distance,
                  onChanged: (value) => setState(() => distance = value),
                  minValue: ui.stat.distance.minValue,
                  maxValue: ui.stat.distance.maxValue,
                ),
              ),
              Opacity(
                opacity:
                    intensity != ui.stat.intensity.minValue + 0.0 ? 1 : 0.5,
                child: NumStatTile<double>(
                  icon: ui.stat.intensity.icon,
                  iconColor: ui.stat.intensity.color,
                  title: ui.stat.intensity.name,
                  value: intensity,
                  onChanged: (value) => setState(() => intensity = value),
                  minValue: ui.stat.intensity.minValue,
                  maxValue: ui.stat.intensity.maxValue,
                ),
              ),
              Opacity(
                opacity: level != ui.stat.level.minValue + 0.0 ? 1 : 0.5,
                child: NumStatTile<double>(
                  icon: ui.stat.level.icon,
                  iconColor: ui.stat.level.color,
                  title: ui.stat.level.name,
                  value: level,
                  onChanged: (value) => setState(() => level = value),
                  minValue: ui.stat.level.minValue,
                  maxValue: ui.stat.level.maxValue,
                ),
              ),
              Opacity(
                opacity: incline != ui.stat.incline.minValue + 0.0 ? 1 : 0.5,
                child: NumStatTile<double>(
                  icon: ui.stat.incline.icon,
                  iconColor: ui.stat.incline.color,
                  title: ui.stat.incline.name,
                  value: incline,
                  onChanged: (value) => setState(() => incline = value),
                  minValue: ui.stat.incline.minValue,
                  maxValue: ui.stat.incline.maxValue,
                ),
              ),
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
        ],
      ),
    );
  }

  Goal generateGoal() {
    final duration = this.duration != Duration.zero ? this.duration : null;
    final heartRate =
        this.heartRate != ui.stat.heartRate.minValue ? this.heartRate : null;
    final speed =
        this.speed != ui.stat.speed.minValue + 0.0 ? this.speed : null;
    final distance =
        this.distance != ui.stat.distance.minValue + 0.0 ? this.distance : null;
    final intensity = this.intensity != ui.stat.intensity.minValue + 0.0
        ? this.intensity
        : null;
    final level =
        this.level != ui.stat.level.minValue + 0.0 ? this.level : null;
    final incline =
        this.incline != ui.stat.incline.minValue + 0.0 ? this.incline : null;

    return CardioGoal(
      id: widget.goal.id,
      duration: duration,
      heartRate: heartRate,
      speed: speed,
      distance: distance,
      intensity: intensity,
      level: level,
      incline: incline,
    );
  }
}
