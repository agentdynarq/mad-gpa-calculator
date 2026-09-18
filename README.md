# Semester GPA Calculator (MAD In Class Activity 04)

A two screen Flutter app that works out a credit weighted GPA for one semester.
Add the modules you are taking, give each one its credits and grade, and the
average updates as you go.

Module: Mobile Application Development, NSBM, Semester 5.

## What it does

- Lists the modules in the semester, with the running GPA above them
- Add and edit a module through a validated form on a second screen
- Swipe a module away to delete it, with an undo that puts it back in place
- Weights the average by credits, so a 15 credit module counts for more than a
  5 credit one

The GPA is `sum(credits * grade points) / sum(credits)`. A plain mean of the
grades is the usual mistake, and the test suite pins the difference: 15 credits
at 4.0 with 5 credits at 2.0 is 3.50, not 3.00.

## Layout of the code

| Path | Purpose |
| --- | --- |
| `lib/main.dart` | App entry point, theme, and the controller that lives for the life of the app |
| `lib/models/grade.dart` | The grade scale, as an enum carrying its own points |
| `lib/models/module.dart` | Immutable module value object with `copyWith` and equality |
| `lib/state/semester_controller.dart` | `ChangeNotifier` holding the modules and the GPA rules |
| `lib/screens/semester_screen.dart` | The list screen, navigation, and delete with undo |
| `lib/screens/module_form_screen.dart` | The add and edit form, and every validation rule |
| `lib/widgets/gpa_summary.dart` | The GPA banner and the two numbers behind it |
| `lib/widgets/module_tile.dart` | One row of the list |
| `test/` | Unit tests for the GPA rules, widget tests for both screens |

Three decisions worth pointing at:

**One form screen, not two.** Passing a module to `ModuleFormScreen` puts it in
edit mode. Add and edit share every validator, so the rules cannot drift apart.
The screen hands the saved module back through `Navigator.pop`, so the list
screen never reaches into the form's state.

**A `ChangeNotifier` rather than `setState`.** The GPA rules are then testable
without building a widget, which is why `test/semester_controller_test.dart`
runs with no `pumpWidget` in it at all.

**Delete returns the index.** `remove` reports the position the module held so
the undo action can put it back where the student expects rather than at the
bottom of the list.

The grade scale is in one file. A different faculty scale is an edit to
`lib/models/grade.dart` and nothing else.

## Running it

Requires Flutter 3.19 or newer (Dart SDK 3.3).

The platform folders are not committed, since they are generated. Recreate them
once after cloning:

```bash
flutter create .
flutter pub get
flutter run
```

## Tests

```bash
flutter test
```

Unit tests cover the weighting, the empty semester, update and remove by id,
the undo ordering, and that the exposed module list cannot be edited from
outside. Widget tests cover the empty state, the GPA rendering, navigation into
the form, the validation messages, the upper casing of a module code on save,
and the swipe to delete with undo.
