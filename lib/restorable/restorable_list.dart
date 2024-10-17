import 'package:flutter/widgets.dart';
import 'package:my_workout/data.dart';
import 'package:my_workout/mixins/jsonable_mixin.dart';

class RestorableList<T extends JsonableMixin<T>>
    extends RestorableValue<List<T>> {
  final T Function(Map<String, dynamic>) fromJsonFactory;
  final List<T> _defaultValue;

  RestorableList(this.fromJsonFactory, this._defaultValue);

  @override
  List<T> createDefaultValue() => _defaultValue;

  @override
  void didUpdateValue(List<T>? oldValue) {
    if (!listEquality.equals(oldValue, value)) {
      notifyListeners();
    }
  }

  @override
  Object toPrimitives() {
    return value.map((item) => item.toJson()).toList();
  }

  @override
  List<T> fromPrimitives(Object? data) {
    return (data as List)
        .map((json) => fromJsonFactory(json as Map<String, dynamic>))
        .toList();
  }

  void notify() {
    super.notifyListeners();
  }

  int get length => value.length;

  T operator [](int index) => value[index];

  void operator []=(int index, T item) {
    value[index] = item;
    notifyListeners();
  }

  void add(T item) {
    value.add(item);
    notifyListeners();
  }

  bool remove(T item) {
    final isRemoved = value.remove(item);
    notifyListeners();
    return isRemoved;
  }

  T removeAt(int index) {
    final item = value.removeAt(index);
    notifyListeners();
    return item;
  }

  void insert(int index, T item) {
    value.insert(index, item);
    notifyListeners();
  }

  void clear() {
    value.clear();
    notifyListeners();
  }

  int indexOf(T item) => value.indexOf(item);
}
