import 'package:flutter/material.dart';

abstract class JsonStorageNotifier<T, TKey> extends ChangeNotifier {
  final List<T> _items;
  List<T> get items => _items;

  JsonStorageNotifier(this._items);

  void add(T exercise) {
    _items.add(exercise);
    notifyListeners();
  }

  T? getByKey(TKey itemKey) {
    if (!contains(itemKey)) {
      return null;
    }

    return _items.firstWhere((e) => equalByKey(e, itemKey));
  }

  void insertAt(int index, T exercise) {
    _items.insert(index, exercise);
    notifyListeners();
  }

  void moveTo(int oldIndex, int newIndex) {
    final exercise = _items.removeAt(oldIndex);
    if (newIndex >= _items.length) {
      _items.add(exercise);
    } else {
      _items.insert(newIndex, exercise);
    }
    notifyListeners();
  }

  bool contains(TKey itemKey) {
    return _items.any((e) => equalByKey(e, itemKey));
  }

  void update(T item) {
    final index = _items.indexWhere((e) => isEqual(e, item));
    if (index == -1) {
      add(item);
      return;
    }

    _items[index] = item;
    notifyListeners();
  }

  void remove(TKey itemKey) {
    _items.removeWhere((e) => equalByKey(e, itemKey));
    notifyListeners();
  }

  bool equalByKey(T item, TKey key);
  bool isEqual(T item1, T item2);
}
