import 'package:flutter/foundation.dart';

import 'grade.dart';

/// One module in a semester: what it is called, what it is worth, how it went.
///
/// Immutable, so a screen can never edit a module that the controller still
/// holds a reference to. Edits go back through the controller as a new value.
@immutable
class Module {
  const Module({
    required this.id,
    required this.code,
    required this.title,
    required this.credits,
    required this.grade,
  });

  /// Builds a module with a fresh identity. Used when the form is saving a
  /// module that did not exist before.
  factory Module.create({
    required String code,
    required String title,
    required int credits,
    required Grade grade,
  }) {
    return Module(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      code: code,
      title: title,
      credits: credits,
      grade: grade,
    );
  }

  /// Stable across edits, so the list can find the module being replaced even
  /// after its code and title have both changed.
  final String id;

  final String code;
  final String title;
  final int credits;
  final Grade grade;

  /// Credits multiplied by grade points. This is the numerator of a credit
  /// weighted GPA, and the reason a 15 credit C hurts more than a 5 credit one.
  double get qualityPoints => credits * grade.points;

  Module copyWith({
    String? code,
    String? title,
    int? credits,
    Grade? grade,
  }) {
    return Module(
      id: id,
      code: code ?? this.code,
      title: title ?? this.title,
      credits: credits ?? this.credits,
      grade: grade ?? this.grade,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is Module &&
        other.id == id &&
        other.code == code &&
        other.title == title &&
        other.credits == credits &&
        other.grade == grade;
  }

  @override
  int get hashCode => Object.hash(id, code, title, credits, grade);

  @override
  String toString() => 'Module($code, $credits credits, ${grade.label})';
}
