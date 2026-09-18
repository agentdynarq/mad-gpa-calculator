import 'package:flutter/material.dart';

import '../models/module.dart';
import '../state/semester_controller.dart';
import '../widgets/gpa_summary.dart';
import '../widgets/module_tile.dart';
import 'module_form_screen.dart';

/// The list screen: every module in the semester, with the running GPA above.
class SemesterScreen extends StatefulWidget {
  const SemesterScreen({super.key, required this.controller});

  final SemesterController controller;

  @override
  State<SemesterScreen> createState() => _SemesterScreenState();
}

class _SemesterScreenState extends State<SemesterScreen> {
  SemesterController get _controller => widget.controller;

  /// Opens the form and waits for the module it returns.
  ///
  /// The screen is pushed with a result type so a cancel, which pops with null,
  /// is handled by the same code path as a save.
  Future<Module?> _openForm({Module? module}) {
    return Navigator.of(context).push<Module>(
      MaterialPageRoute<Module>(
        builder: (context) => ModuleFormScreen(module: module),
      ),
    );
  }

  Future<void> _addModule() async {
    final module = await _openForm();
    if (module != null) {
      _controller.add(module);
    }
  }

  Future<void> _editModule(Module module) async {
    final edited = await _openForm(module: module);
    if (edited != null) {
      _controller.update(edited);
    }
  }

  /// Deleting is one swipe, so it needs an undo. The controller hands back the
  /// index the module held, which is what puts it back in the right place.
  void _deleteModule(Module module) {
    final messenger = ScaffoldMessenger.of(context);
    final index = _controller.remove(module.id);
    if (index == -1) {
      return;
    }

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text('Removed ${module.code}'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => _controller.insertAt(index, module),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Semester GPA'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Clear semester',
            onPressed: _controller.isEmpty ? null : _controller.clear,
            icon: const Icon(Icons.delete_sweep_outlined),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addModule,
        icon: const Icon(Icons.add),
        label: const Text('Add module'),
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          if (_controller.isEmpty) {
            return const _EmptySemester();
          }

          final modules = _controller.modules;

          return Column(
            children: <Widget>[
              GpaSummary(
                gpa: _controller.gpa,
                totalCredits: _controller.totalCredits,
                moduleCount: _controller.moduleCount,
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.only(bottom: 88),
                  itemCount: modules.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1, indent: 72),
                  itemBuilder: (context, index) {
                    final module = modules[index];
                    return Dismissible(
                      key: ValueKey<String>(module.id),
                      direction: DismissDirection.endToStart,
                      background: const _DeleteBackground(),
                      onDismissed: (_) => _deleteModule(module),
                      child: ModuleTile(
                        module: module,
                        onTap: () => _editModule(module),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _EmptySemester extends StatelessWidget {
  const _EmptySemester();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.school_outlined,
              size: 56,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text('No modules yet', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Add the modules you are taking this semester and the GPA is '
              'calculated as you go.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      color: scheme.errorContainer,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 24),
      child: Icon(Icons.delete_outline, color: scheme.onErrorContainer),
    );
  }
}
