import 'package:my_workout/models/progress_status.dart';
import 'package:my_workout/utils.dart';

class WeightGoalProgressSet {
  int reps = 0;
  double weight = 0;
  ProgressStatus status = ProgressStatus.planned;
  DateTime? endRestAt;
  bool isDone = false;

  WeightGoalProgressSet({
    this.reps = 0,
    this.weight = 0,
    this.status = ProgressStatus.planned,
  });

  WeightGoalProgressSet.fromJson(Map json) {
    reps = json['reps'];
    weight = json['weight'];
    status = ProgressStatus
        .values[json.getOrDefault('status', ProgressStatus.planned.index)];
    final endRestAtValue = json.getOrDefault('endRestAt', null);
    if (endRestAtValue != null) {
      endRestAt = DateTime.fromMillisecondsSinceEpoch(endRestAtValue);
    }
    isDone = json.getOrDefault('isDone', false);
  }

  Map<String, dynamic> toJson() {
    return {
      'reps': reps,
      'weight': weight,
      'status': status.index,
      'endRestAt': endRestAt?.millisecondsSinceEpoch,
      'isDone': isDone,
    };
  }
}
