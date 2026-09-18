import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gpa_calculator/models/grade.dart';
import 'package:gpa_calculator/models/module.dart';
import 'package:gpa_calculator/screens/semester_screen.dart';
import 'package:gpa_calculator/state/semester_controller.dart';

Widget wrap(SemesterController controller) {
  return MaterialApp(home: SemesterScreen(controller: controller));
}

const Module maths = Module(
  id: '1',
  code: 'MA301.3',
  title: 'Mathematics for Computing',
  credits: 15,
  grade: Grade.a,
);

const Module crypto = Module(
  id: '2',
  code: 'CS302.3',
  title: 'Cryptography',
  credits: 5,
  grade: Grade.c,
);

void main() {
  testWidgets('an empty semester explains itself instead of showing 0.00',
      (tester) async {
    await tester.pumpWidget(wrap(SemesterController()));

    expect(find.text('No modules yet'), findsOneWidget);
    expect(find.text('0.00'), findsNothing);
  });

  testWidgets('the GPA and the numbers behind it are all on screen',
      (tester) async {
    await tester.pumpWidget(
      wrap(SemesterController(<Module>[maths, crypto])),
    );

    expect(find.text('3.50'), findsOneWidget);
    expect(find.text('20'), findsOneWidget);
    expect(find.text('Mathematics for Computing'), findsOneWidget);
    expect(find.text('MA301.3 · 15 credits'), findsOneWidget);
  });

  testWidgets('the GPA updates when a module is added', (tester) async {
    final controller = SemesterController(<Module>[maths]);
    await tester.pumpWidget(wrap(controller));
    expect(find.text('4.00'), findsOneWidget);

    controller.add(crypto);
    await tester.pump();

    expect(find.text('3.50'), findsOneWidget);
  });

  testWidgets('tapping a module opens the edit form with its values',
      (tester) async {
    await tester.pumpWidget(wrap(SemesterController(<Module>[maths])));

    await tester.tap(find.text('Mathematics for Computing'));
    await tester.pumpAndSettle();

    expect(find.text('Edit module'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'MA301.3'), findsOneWidget);
  });

  testWidgets('the add button opens a blank form', (tester) async {
    await tester.pumpWidget(wrap(SemesterController()));

    await tester.tap(find.text('Add module'));
    await tester.pumpAndSettle();

    expect(find.text('Add module'), findsWidgets);
    expect(find.text('Enter the module code'), findsNothing);
  });

  testWidgets('saving a blank form shows the validation messages',
      (tester) async {
    await tester.pumpWidget(wrap(SemesterController()));
    await tester.tap(find.text('Add module'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Add module'));
    await tester.pump();

    expect(find.text('Enter the module code'), findsOneWidget);
    expect(find.text('Enter the module title'), findsOneWidget);
    expect(find.text('Enter the credit value'), findsOneWidget);
  });

  testWidgets('a completed form adds the module to the semester',
      (tester) async {
    final controller = SemesterController();
    await tester.pumpWidget(wrap(controller));
    await tester.tap(find.text('Add module'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Module code'),
      'se303.3',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Module title'),
      'Mobile Application Development',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Credits'),
      '4',
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Add module'));
    await tester.pumpAndSettle();

    expect(controller.moduleCount, 1);
    // The code is stored upper case whatever the student typed.
    expect(controller.modules.first.code, 'SE303.3');
    expect(find.text('Mobile Application Development'), findsOneWidget);
  });

  testWidgets('credits outside the allowed range are rejected',
      (tester) async {
    await tester.pumpWidget(wrap(SemesterController()));
    await tester.tap(find.text('Add module'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Credits'),
      '99',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Add module'));
    await tester.pump();

    expect(find.text('Credits must be between 1 and 30'), findsOneWidget);
  });

  testWidgets('swiping a module away offers an undo that restores it',
      (tester) async {
    final controller = SemesterController(<Module>[maths, crypto]);
    await tester.pumpWidget(wrap(controller));

    await tester.drag(
      find.text('Mathematics for Computing'),
      const Offset(-500, 0),
    );
    await tester.pumpAndSettle();

    expect(controller.moduleCount, 1);
    expect(find.text('Removed MA301.3'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    expect(controller.moduleCount, 2);
    expect(controller.modules.first.id, maths.id);
  });
}
