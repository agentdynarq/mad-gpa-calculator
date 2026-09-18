import 'package:flutter/foundation.dart';

import '../models/module.dart';

/// Holds the modules for one semester and the GPA derived from them.
///
/// A [ChangeNotifier] rather than `setState` for two reasons: the GPA rules can
/// be unit tested without building a single widget, and only the parts of the
/// screen that listen are rebuilt when one module changes.
class SemesterController extends ChangeNotifier {
  SemesterController([List<Module> initial = const <Module>[]])
      : _modules = List<Module>.of(initial);

  final List<Module> _modules;

  /// Read only on purpose. Callers change the semester through the methods
  /// below so that every change goes past [notifyListeners].
  List<Module> get modules => List<Module>.unmodifiable(_modules);

  bool get isEmpty => _modules.isEmpty;

  int get moduleCount => _modules.length;

  int get totalCredits =>
      _modules.fold(0, (sum, module) => sum + module.credits);

  double get totalQualityPoints =>
      _modules.fold(0.0, (sum, module) => sum + module.qualityPoints);

  /// Credit weighted GPA.
  ///
  /// An empty semester has no average at all, so this returns zero rather than
  /// dividing by zero. The screen checks [isEmpty] and shows the empty state
  /// instead of printing a misleading 0.00.
  double get gpa =>
      totalCredits == 0 ? 0 : totalQualityPoints / totalCredits;

  void add(Module module) {
    _modules.add(module);
    notifyListeners();
  }

  /// Replaces the module carrying the same id. Does nothing if it has already
  /// been removed, which can happen if the form was left open over a delete.
  void update(Module module) {
    final index = _modules.indexWhere((existing) => existing.id == module.id);
    if (index == -1) {
      return;
    }
    _modules[index] = module;
    notifyListeners();
  }

  /// Removes a module and reports the position it held, so that an undo can
  /// put it back where the student expects rather than at the bottom.
  int remove(String id) {
    final index = _modules.indexWhere((module) => module.id == id);
    if (index == -1) {
      return -1;
    }
    _modules.removeAt(index);
    notifyListeners();
    return index;
  }

  /// Puts a module back at a known position. The index is bounded here rather
  /// than trusted, because an undo can arrive after the list has moved on.
  void insertAt(int index, Module module) {
    var position = index;
    if (position < 0) {
      position = 0;
    } else if (position > _modules.length) {
      position = _modules.length;
    }
    _modules.insert(position, module);
    notifyListeners();
  }

  void clear() {
    if (_modules.isEmpty) {
      return;
    }
    _modules.clear();
    notifyListeners();
  }
}
