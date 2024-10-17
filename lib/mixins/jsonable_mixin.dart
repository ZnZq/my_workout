mixin JsonableMixin<T> {
  static T fromJson<T>(Map<String, dynamic> json) {
    throw UnimplementedError('fromJson must be implemented in subclasses');
  }

  Map<String, dynamic> toJson();
}
