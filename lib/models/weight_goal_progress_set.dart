import 'package:equatable/equatable.dart';
import 'package:my_workout/data.dart';
import 'package:my_workout/models/progress_status.dart';
import 'package:my_workout/utils.dart';

class WeightGoalProgressSet with EquatableMixin {
  late final String id;

  int reps = 0;
  double weight = 0;
  ProgressStatus status = ProgressStatus.planned;
  DateTime? endRestAt;
  bool isDone = false;

  WeightGoalProgressSet({
    this.reps = 0,
    this.weight = 0,
    this.status = ProgressStatus.planned,
    this.endRestAt,
    this.isDone = false,
    String? id,
  }) {
    this.id = id ?? uuid.v4();
  }

  WeightGoalProgressSet clone() {
    return WeightGoalProgressSet(
      reps: reps,
      weight: weight,
      status: status,
      endRestAt: endRestAt,
      isDone: isDone,
      id: id,
    );
  }

  WeightGoalProgressSet.fromJson(Map json) {
    id = json['id'] ?? uuid.v4();
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
      'id': id,
      'reps': reps,
      'weight': weight,
      'status': status.index,
      'endRestAt': endRestAt?.millisecondsSinceEpoch,
      'isDone': isDone,
    };
  }

  @override
  List<Object?> get props => [id, reps, weight, status, endRestAt, isDone];
}
