import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/grade.dart';
import '../models/module.dart';

/// The add and edit screen.
///
/// One screen serves both jobs. Passing a [module] puts it in edit mode, which
/// keeps the validation rules in a single place instead of two screens that
/// drift apart. It returns the saved [Module] through `Navigator.pop`, so the
/// list screen never reaches into this screen's state.
class ModuleFormScreen extends StatefulWidget {
  const ModuleFormScreen({super.key, this.module});

  /// The module being edited, or null when adding a new one.
  final Module? module;

  bool get isEditing => module != null;

  @override
  State<ModuleFormScreen> createState() => _ModuleFormScreenState();
}

class _ModuleFormScreenState extends State<ModuleFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _code;
  late final TextEditingController _title;
  late final TextEditingController _credits;
  late Grade _grade;

  @override
  void initState() {
    super.initState();
    final module = widget.module;
    _code = TextEditingController(text: module?.code ?? '');
    _title = TextEditingController(text: module?.title ?? '');
    _credits = TextEditingController(
      text: module == null ? '' : module.credits.toString(),
    );
    _grade = module?.grade ?? Grade.unset;
  }

  @override
  void dispose() {
    _code.dispose();
    _title.dispose();
    _credits.dispose();
    super.dispose();
  }

  String? _validateCode(String? value) {
    final code = value?.trim() ?? '';
    if (code.isEmpty) {
      return 'Enter the module code';
    }
    if (code.length < 3) {
      return 'A module code is at least 3 characters';
    }
    return null;
  }

  String? _validateTitle(String? value) {
    if ((value?.trim() ?? '').isEmpty) {
      return 'Enter the module title';
    }
    return null;
  }

  /// Credits drive the weighting, so a bad value here quietly corrupts the
  /// GPA rather than throwing. It is worth validating properly.
  String? _validateCredits(String? value) {
    final raw = value?.trim() ?? '';
    if (raw.isEmpty) {
      return 'Enter the credit value';
    }
    final credits = int.tryParse(raw);
    if (credits == null) {
      return 'Credits must be a whole number';
    }
    if (credits < 1 || credits > 30) {
      return 'Credits must be between 1 and 30';
    }
    return null;
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final code = _code.text.trim().toUpperCase();
    final title = _title.text.trim();
    final credits = int.parse(_credits.text.trim());
    final existing = widget.module;

    final saved = existing == null
        ? Module.create(
            code: code,
            title: title,
            credits: credits,
            grade: _grade,
          )
        : existing.copyWith(
            code: code,
            title: title,
            credits: credits,
            grade: _grade,
          );

    Navigator.of(context).pop(saved);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit module' : 'Add module'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            TextFormField(
              controller: _code,
              textCapitalization: TextCapitalization.characters,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Module code',
                hintText: 'SE303.3',
                border: OutlineInputBorder(),
              ),
              validator: _validateCode,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _title,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Module title',
                hintText: 'Mobile Application Development',
                border: OutlineInputBorder(),
              ),
              validator: _validateTitle,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _credits,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: const InputDecoration(
                labelText: 'Credits',
                hintText: '4',
                border: OutlineInputBorder(),
              ),
              validator: _validateCredits,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Grade>(
              value: _grade,
              decoration: const InputDecoration(
                labelText: 'Grade',
                border: OutlineInputBorder(),
              ),
              items: Grade.values.map((grade) {
                return DropdownMenuItem<Grade>(
                  value: grade,
                  child: Text(
                    '${grade.label}  (${grade.points.toStringAsFixed(1)} points)',
                  ),
                );
              }).toList(),
              onChanged: (grade) {
                if (grade != null) {
                  setState(() => _grade = grade);
                }
              },
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _save,
              child: Text(widget.isEditing ? 'Save changes' : 'Add module'),
            ),
          ],
        ),
      ),
    );
  }
}
