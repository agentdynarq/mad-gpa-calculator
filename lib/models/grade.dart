/// A letter grade and the points it carries.
///
/// The scale lives here and nowhere else. Swapping in a different faculty
/// scale is a one file change instead of a hunt through the widgets.
enum Grade {
  aPlus('A+', 4.0),
  a('A', 4.0),
  aMinus('A-', 3.7),
  bPlus('B+', 3.3),
  b('B', 3.0),
  bMinus('B-', 2.7),
  cPlus('C+', 2.3),
  c('C', 2.0),
  cMinus('C-', 1.7),
  dPlus('D+', 1.3),
  d('D', 1.0),
  e('E', 0.0);

  const Grade(this.label, this.points);

  /// How the grade is written on a transcript, for example `B+`.
  final String label;

  /// Points per credit that this grade contributes to the GPA.
  final double points;

  /// The default selection on a blank form: the middle of the scale, so the
  /// student is nudged to choose rather than accepting a flattering default.
  static Grade get unset => Grade.c;

  static Grade fromLabel(String label) =>
      Grade.values.firstWhere((grade) => grade.label == label);
}
