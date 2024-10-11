import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:vibration/vibration.dart';

const uuid = Uuid();
const listEquality = ListEquality();
final dateFormat = DateFormat('dd.MM.yyyy');
final timeFormat = DateFormat('HH:mm');
final dateTimeFormat = DateFormat('dd.MM.yyyy HH:mm');
late final bool hasVibrator;

init() async {
  hasVibrator = await Vibration.hasVibrator() ?? false;
}

final ui = _UI();

class _UI {
  final _Stat stat = _Stat();
}

class _Stat {
  StatData duration = StatData(
    name: 'Duration',
    icon: Icons.timer_sharp,
    color: Colors.blue,
  );
  StatRangeData heartRate = StatRangeData(
    name: 'Heart Rate',
    icon: Icons.favorite,
    color: Colors.red,
    minValue: 0,
    maxValue: 300,
  );
  StatRangeData speed = StatRangeData(
    name: 'Speed',
    icon: Icons.speed,
    color: Colors.orange,
    minValue: 0,
    maxValue: 999,
  );
  StatRangeData distance = StatRangeData(
    name: 'Distance',
    icon: Icons.location_on,
    color: Colors.indigo,
    minValue: 0,
    maxValue: 999,
  );
  StatRangeData intensity = StatRangeData(
    name: 'Intensity',
    icon: Icons.bolt,
    color: Colors.green,
    minValue: 0,
    maxValue: 999,
  );
  StatRangeData level = StatRangeData(
    name: 'Level',
    icon: Icons.trending_up,
    color: Colors.yellow,
    minValue: 0,
    maxValue: 999,
  );
  StatRangeData sets = StatRangeData(
    name: 'Sets',
    icon: Icons.play_arrow,
    color: Colors.orange,
    minValue: 1,
    maxValue: 999,
  );
  StatRangeData reps = StatRangeData(
    name: 'Reps',
    icon: Icons.repeat,
    color: Colors.green,
    minValue: 1,
    maxValue: 999,
  );
  StatData rest = StatData(
    name: 'Rest',
    icon: Icons.timer_sharp,
    color: Colors.blue,
  );
  StatRangeData weight = StatRangeData(
    name: 'Weight',
    icon: Icons.fitness_center,
    color: Colors.blue,
    minValue: 0,
    maxValue: 999,
  );
  StatData cardio = StatData(
    name: 'Cardio',
    icon: Icons.monitor_heart,
    color: Colors.green,
  );
}

class StatData {
  final String name;
  final IconData icon;
  final Color color;

  const StatData({
    required this.name,
    required this.icon,
    required this.color,
  });
}

class StatRangeData extends StatData {
  final int minValue;
  final int maxValue;

  const StatRangeData({
    required super.name,
    required super.icon,
    required super.color,
    required this.minValue,
    required this.maxValue,
  });
}
