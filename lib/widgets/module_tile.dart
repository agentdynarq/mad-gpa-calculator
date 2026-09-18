import 'package:flutter/material.dart';

import '../models/module.dart';

/// One row of the semester list.
///
/// The grade sits in the leading circle rather than the trailing text because
/// it is the thing the eye is looking for when scanning the list.
class ModuleTile extends StatelessWidget {
  const ModuleTile({
    super.key,
    required this.module,
    required this.onTap,
  });

  final Module module;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final scheme = theme.colorScheme;
    final background = _background(scheme);

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: background,
        foregroundColor: _foreground(scheme, background),
        child: Text(
          module.grade.label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
      ),
      title: Text(module.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text('${module.code} · ${module.credits} credits'),
      trailing: Text(
        module.qualityPoints.toStringAsFixed(1),
        style: theme.textTheme.titleMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  /// Stronger colour for a stronger grade. Presentation only: nothing in the
  /// GPA calculation reads this.
  Color _background(ColorScheme scheme) {
    if (module.grade.points >= 3.3) {
      return scheme.primary;
    }
    if (module.grade.points >= 2.0) {
      return scheme.secondary;
    }
    return scheme.error;
  }

  /// Each of the three backgrounds above has its own matching "on" colour, so
  /// the label stays readable instead of assuming white works everywhere.
  Color _foreground(ColorScheme scheme, Color background) {
    if (background == scheme.primary) {
      return scheme.onPrimary;
    }
    if (background == scheme.secondary) {
      return scheme.onSecondary;
    }
    return scheme.onError;
  }
}
