import 'package:collection/collection.dart';
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
