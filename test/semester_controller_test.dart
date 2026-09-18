import 'package:flutter_test/flutter_test.dart';
import 'package:gpa_calculator/models/grade.dart';
import 'package:gpa_calculator/models/module.dart';
import 'package:gpa_calculator/state/semester_controller.dart';

Module module({
  required String id,
  int credits = 4,
  Grade grade = Grade.a,
}) {
  return Module(
    id: id,
    code: 'SE$id',
    title: 'Module $id',
    credits: credits,
    grade: grade,
  );
}

void main() {
  group('GPA', () {
    test('an empty semester has no GPA and no credits', () {
      final controller = SemesterController();

      expect(controller.isEmpty, isTrue);
      expect(controller.totalCredits, 0);
      expect(controller.gpa, 0);
    });

    test('a single module scores its own grade', () {
      final controller = SemesterController(<Module>[
        module(id: '1', credits: 4, grade: Grade.b),
      ]);

      expect(controller.gpa, closeTo(3.0, 0.001));
    });

    test('the average is weighted by credits, not a plain mean', () {
      // 15 credits at 4.0 and 5 credits at 2.0. A plain mean would be 3.0.
      final controller = SemesterController(<Module>[
        module(id: '1', credits: 15, grade: Grade.a),
        module(id: '2', credits: 5, grade: Grade.c),
      ]);

      expect(controller.totalCredits, 20);
      expect(controller.totalQualityPoints, closeTo(70.0, 0.001));
      expect(controller.gpa, closeTo(3.5, 0.001));
    });

    test('quality points are credits times grade points', () {
      expect(module(id: '1', credits: 3, grade: Grade.bPlus).qualityPoints,
          closeTo(9.9, 0.001));
    });
  });

  group('editing the semester', () {
    test('adding a module notifies listeners', () {
      final controller = SemesterController();
      var notifications = 0;
      controller.addListener(() => notifications++);

      controller.add(module(id: '1'));

      expect(controller.moduleCount, 1);
      expect(notifications, 1);
    });

    test('updating replaces the module with the same id', () {
      final controller = SemesterController(<Module>[
        module(id: '1', credits: 4, grade: Grade.e),
      ]);

      controller.update(
        controller.modules.first.copyWith(grade: Grade.a),
      );

      expect(controller.moduleCount, 1);
      expect(controller.gpa, closeTo(4.0, 0.001));
    });

    test('updating a module that is gone changes nothing', () {
      final controller = SemesterController(<Module>[module(id: '1')]);

      controller.update(module(id: 'missing'));

      expect(controller.moduleCount, 1);
      expect(controller.modules.first.id, '1');
    });

    test('remove reports the index so an undo can restore the order', () {
      final controller = SemesterController(<Module>[
        module(id: '1'),
        module(id: '2'),
        module(id: '3'),
      ]);
      final removed = controller.modules[1];

      final index = controller.remove('2');
      expect(index, 1);
      expect(controller.modules.map((m) => m.id), <String>['1', '3']);

      controller.insertAt(index, removed);
      expect(controller.modules.map((m) => m.id), <String>['1', '2', '3']);
    });

    test('removing an unknown id returns -1', () {
      final controller = SemesterController(<Module>[module(id: '1')]);

      expect(controller.remove('nope'), -1);
      expect(controller.moduleCount, 1);
    });

    test('insertAt clamps an index past the end', () {
      final controller = SemesterController(<Module>[module(id: '1')]);

      controller.insertAt(99, module(id: '2'));

      expect(controller.modules.map((m) => m.id), <String>['1', '2']);
    });

    test('clear empties the semester once', () {
      final controller = SemesterController(<Module>[module(id: '1')]);
      var notifications = 0;
      controller.addListener(() => notifications++);

      controller.clear();
      controller.clear();

      expect(controller.isEmpty, isTrue);
      expect(notifications, 1);
    });

    test('the exposed list cannot be edited from outside', () {
      final controller = SemesterController(<Module>[module(id: '1')]);

      expect(
        () => controller.modules.add(module(id: '2')),
        throwsUnsupportedError,
      );
    });
  });

  group('Grade', () {
    test('the scale runs from A+ down to E', () {
      expect(Grade.aPlus.points, 4.0);
      expect(Grade.e.points, 0.0);
    });

    test('a label maps back to its grade', () {
      expect(Grade.fromLabel('B+'), Grade.bPlus);
    });
  });
}
