import 'package:my_workout/models/program.dart';
import 'package:my_workout/storage/json_storage_notifier.dart';

class ProgramStorage extends JsonStorageNotifier<Program, String> {
  ProgramStorage(super.items);

  @override
  bool equalByKey(Program item, String key) {
    return item.id == key;
  }

  @override
  bool isEqual(Program item1, Program item2) {
    return item1.id == item2.id;
  }
}
