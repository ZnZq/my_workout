import 'package:my_workout/models/activity.dart';
import 'package:my_workout/storage/json_storage_notifier.dart';

class ActivityStorage extends JsonStorageNotifier<Activity, String> {
  ActivityStorage(super.items);

  @override
  bool equalByKey(Activity item, String key) {
    return item.id == key;
  }

  @override
  bool isEqual(Activity item1, Activity item2) {
    return item1.id == item2.id;
  }
}
