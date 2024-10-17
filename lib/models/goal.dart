import 'package:equatable/equatable.dart';
import 'package:my_workout/data.dart';
import 'package:my_workout/models/enum/exercise_execute_method.dart';
import 'package:my_workout/utils.dart';

class GoalFactory {
  static Goal fromJson(Map json) {
    if (!json.containsKey("__type")) {
      throw Exception('Invalid goal type');
    }

    final type = json['__type'] as String;
    switch (type) {
      case WeightGoal.__type:
        return WeightGoal.fromJson(json);
      case CardioGoal.__type:
        return CardioGoal.fromJson(json);
    }

    throw Exception('Invalid goal type');
  }
}

abstract class Goal with EquatableMixin {
  late final String id;

  static Goal create(ExerciseExecuteMethod executeMethod) {
    switch (executeMethod) {
      case ExerciseExecuteMethod.weight:
        return WeightGoal.empty();
      case ExerciseExecuteMethod.cardio:
        return CardioGoal.empty();
    }
  }

  ExerciseExecuteMethod get executeMethod {
    if (this is WeightGoal) {
      return ExerciseExecuteMethod.weight;
    } else if (this is CardioGoal) {
      return ExerciseExecuteMethod.cardio;
    } else {
      throw Exception('Unknown goal type');
    }
  }

  Goal(String? id) : id = id ?? uuid.v4();

  Goal clone();

  String generateReport(int index);

  Goal.fromJson(Map json) {
    id = json['id'] ?? uuid.v4();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
    };
  }
}

class WeightGoal extends Goal {
  static const __type = 'WeightGoal';

  int sets = 1;
  int reps = 1;
  double weight = 0;
  Duration rest = const Duration(minutes: 1);

  WeightGoal({
    required this.sets,
    required this.reps,
    required this.weight,
    required this.rest,
    String? id,
  }) : super(id);

  WeightGoal.empty() : super(uuid.v4());

  WeightGoal.fromJson(Map json) : super.fromJson(json) {
    sets = json.getOrDefault('sets', 1);
    reps = json.getOrDefault('reps', 1);
    weight = json.getOrDefault('weight', 0.0);
    rest = Duration(seconds: json.getOrDefault('rest', 60));
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__type': __type,
      ...super.toJson(),
      'sets': sets,
      'reps': reps,
      'weight': weight,
      'rest': rest.inSeconds,
    };
  }

  @override
  WeightGoal clone() {
    return WeightGoal(
      id: id,
      sets: sets,
      reps: reps,
      weight: weight,
      rest: rest,
    );
  }

  @override
  String generateReport(int index) {
    final data = [
      'Sets: $sets',
      'Reps: $reps',
      if (weight != 0) 'Weight: $weight',
      'Rest: ${formatDuration(rest)}',
    ];

    return '$index. ${data.join(', ')}';
  }

  @override
  String toString() {
    final parts = <String>[];
    if (sets >= 1) {
      parts.add('Sets: $sets');
    }

    if (reps >= 1) {
      parts.add('Reps: $reps');
    }

    if (weight > 0) {
      parts.add('Weight: ${weight.toStringAsFixed(1)}');
    }

    return parts.join(', ');
  }

  @override
  List<Object?> get props => [id, sets, reps, weight];
}

class CardioGoal extends Goal {
  static const __type = 'CardioGoal';

  Duration? duration;
  int? heartRate;
  double? speed;
  double? distance;
  double? intensity;
  double? level;
  double? incline;

  CardioGoal({
    this.duration,
    this.heartRate,
    this.speed,
    this.distance,
    this.intensity,
    this.level,
    this.incline,
    String? id,
  }) : super(id);

  CardioGoal.empty() : super(uuid.v4());

  CardioGoal.fromJson(Map json) : super.fromJson(json) {
    duration = json['duration'] != null
        ? Duration(seconds: json['duration'] as int)
        : null;
    heartRate = json['heartRate'] as int?;
    speed = json['speed'] as double?;
    distance = json['distance'] as double?;
    intensity = json['intensity'] as double?;
    level = json['level'] as double?;
    incline = json.getOrDefault('incline', null) as double?;
  }

  actualizeFrom(CardioGoal goal, {bool copyValues = false}) {
    if (goal.duration != null && duration == null) {
      duration = copyValues ? goal.duration : Duration.zero;
    }
    if (goal.heartRate != null && heartRate == null) {
      heartRate = copyValues ? goal.heartRate : 0;
    }
    if (goal.speed != null && speed == null) {
      speed = copyValues ? goal.speed : 0;
    }
    if (goal.distance != null && distance == null) {
      distance = copyValues ? goal.distance : 0;
    }
    if (goal.intensity != null && intensity == null) {
      intensity = copyValues ? goal.intensity : 0;
    }
    if (goal.level != null && level == null) {
      level = copyValues ? goal.level : 0;
    }
    if (goal.incline != null && incline == null) {
      incline = copyValues ? goal.incline : 0;
    }

    if (goal.duration == null && duration != null) {
      duration = null;
    }
    if (goal.heartRate == null && heartRate != null) {
      heartRate = null;
    }
    if (goal.speed == null && speed != null) {
      speed = null;
    }
    if (goal.distance == null && distance != null) {
      distance = null;
    }
    if (goal.intensity == null && intensity != null) {
      intensity = null;
    }
    if (goal.level == null && level != null) {
      level = null;
    }
    if (goal.incline == null && incline != null) {
      incline = null;
    }
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__type': __type,
      ...super.toJson(),
      'duration': duration?.inSeconds,
      'heartRate': heartRate,
      'speed': speed,
      'distance': distance,
      'intensity': intensity,
      'level': level,
      'incline': incline,
    };
  }

  @override
  CardioGoal clone() {
    return CardioGoal(
      id: id,
      duration: duration,
      heartRate: heartRate,
      speed: speed,
      distance: distance,
      intensity: intensity,
      level: level,
      incline: incline,
    );
  }

  @override
  String generateReport(int index) {
    final data = [
      if (duration != null) 'Duration: ${formatDuration(duration!)}',
      if (heartRate != null) 'Heart rate: $heartRate',
      if (speed != null) 'Speed: ${speed!.toStringAsFixed(1)}',
      if (distance != null) 'Distance: ${distance!.toStringAsFixed(1)}',
      if (intensity != null) 'Intensity: ${intensity!.toStringAsFixed(1)}',
      if (level != null) 'Level: ${level!.toStringAsFixed(1)}',
      if (incline != null) 'Incline: ${incline!.toStringAsFixed(1)}',
    ];

    return '$index. ${data.join(', ')}';
  }

  clear() {
    if (duration != null) {
      duration = Duration.zero;
    }
    if (heartRate != null) {
      heartRate = 0;
    }
    if (speed != null) {
      speed = 0;
    }
    if (distance != null) {
      distance = 0;
    }
    if (intensity != null) {
      intensity = 0;
    }
    if (level != null) {
      level = 0;
    }
    if (incline != null) {
      incline = 0;
    }
  }

  @override
  String toString() {
    final parts = <String>[];
    if (duration != null) {
      parts.add('Duration: ${formatDuration(duration!)}');
    }

    if (heartRate != null) {
      parts.add('Heart rate: $heartRate');
    }

    if (speed != null) {
      parts.add('Speed: ${speed!.toStringAsFixed(1)}');
    }

    if (distance != null) {
      parts.add('Distance: ${distance!.toStringAsFixed(1)}');
    }

    if (intensity != null) {
      parts.add('Intensity: ${intensity!.toStringAsFixed(1)}');
    }

    if (level != null) {
      parts.add('Level: ${level!.toStringAsFixed(1)}');
    }

    if (incline != null) {
      parts.add('Incline: ${incline!.toStringAsFixed(1)}');
    }

    return parts.join(', ');
  }

  @override
  List<Object?> get props =>
      [id, duration, heartRate, speed, distance, intensity, level, incline];
}
