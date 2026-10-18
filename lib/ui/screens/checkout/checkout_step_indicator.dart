import 'package:flutter/material.dart';
import 'package:pharos/core/theme/app_colors.dart';
import 'package:pharos/core/theme/app_spacing.dart';
import 'package:pharos/l10n/app_localizations.dart';

/// Pasek kroków z podpisami. Kroki ukończone pokazują ptaszek, bieżący jest wyróżniony.
class CheckoutStepIndicator extends StatelessWidget {
  const CheckoutStepIndicator({
    super.key,
    required this.labels,
    required this.completed,
    this.currentIndex,
  });

  final List<String> labels;
  final List<bool> completed;

  /// Indeks bieżącego kroku (wariant krokowy); null, gdy wszystkie sekcje są na jednej stronie.
  final int? currentIndex;

  static const double _nodeWidth = 72;

  @override
  Widget build(BuildContext context) {
    assert(labels.length == completed.length);
    final children = <Widget>[];
    for (var i = 0; i < labels.length; i++) {
      if (i > 0) children.add(_line(completed[i - 1]));
      children.add(_node(context, i));
    }
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: children);
  }

  Widget _line(bool active) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(top: 17),
        child: Container(
          height: 2,
          color: active ? AppColors.accent.withOpacity(0.5) : Colors.white.withOpacity(0.12),
        ),
      ),
    );
  }

  Widget _node(BuildContext context, int index) {
    final l10n = AppLocalizations.of(context)!;
    final done = completed[index];
    final current = currentIndex == index;
    final highlighted = done || current;

    return Semantics(
      label: l10n.stepSemanticsLabel(
        index + 1,
        labels.length,
        labels[index],
        done ? l10n.stepDone : current ? l10n.stepCurrent : l10n.stepTodo,
      ),
      excludeSemantics: true,
      child: SizedBox(
        width: _nodeWidth,
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: done ? AppColors.accent : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: highlighted ? AppColors.accent : Colors.white.withOpacity(0.24),
                  width: 2,
                ),
              ),
              alignment: Alignment.center,
              child: done
                  ? const Icon(Icons.check_rounded, size: 18, color: Colors.white)
                  : Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: current ? AppColors.accentText : Colors.white54,
                      ),
                    ),
            ),
            const SizedBox(height: AppSpacing.s4),
            Text(
              labels[index],
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: highlighted ? FontWeight.bold : FontWeight.normal,
                color: highlighted ? Colors.white : Colors.white60,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
