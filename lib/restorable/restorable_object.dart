import 'package:flutter/widgets.dart';
import 'package:my_workout/mixins/jsonable_mixin.dart';

class RestorableObject<T extends JsonableMixin<T>> extends RestorableValue<T> {
  final T Function(Map<String, dynamic>) fromJsonFactory;
  final T _defaultValue;

  RestorableObject(this.fromJsonFactory, this._defaultValue);

  @override
  T createDefaultValue() => _defaultValue;

  @override
  void didUpdateValue(T? oldValue) {
    if (oldValue != value) {
      notifyListeners();
    }
  }

  @override
  Object toPrimitives() {
    return value.toJson();
  }

  @override
  T fromPrimitives(Object? data) {
    return fromJsonFactory(data as Map<String, dynamic>);
  }

  void notify() {
    super.notifyListeners();
  }
}
