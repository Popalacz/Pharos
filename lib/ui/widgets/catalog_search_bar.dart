import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/pharos_layout.dart';
import '../../core/theme/app_colors.dart';

/// Search field for the catalog grid. [controller] is owned by the parent so it can be cleared programmatically.
class CatalogSearchBar extends StatelessWidget {
  const CatalogSearchBar({
    super.key,
    required this.controller,
    required this.onTextChanged,
    this.hintText = 'Szukaj produktów…',
  });

  final TextEditingController controller;
  final VoidCallback onTextChanged;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (BuildContext context, Widget? _) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            PharosLayout.spaceSm,
            PharosLayout.spaceSm,
            PharosLayout.spaceSm,
            PharosLayout.spaceXs,
          ),
          child: TextField(
            controller: controller,
            onChanged: (_) => onTextChanged(),
            textInputAction: TextInputAction.search,
            style: const TextStyle(color: AppColors.text),
            cursorColor: AppColors.accent,
            decoration: InputDecoration(
              hintText: hintText,
              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.text),
              suffixIcon: AnimatedSwitcher(
                duration: PharosLayout.motionFast,
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: controller.text.isEmpty
                    ? const SizedBox.shrink(key: ValueKey<String>('empty'))
                    : IconButton(
                        key: const ValueKey<String>('clear'),
                        tooltip: 'Wyczyść',
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          controller.clear();
                          onTextChanged();
                        },
                        icon: const Icon(Icons.close_rounded, color: AppColors.text),
                      ),
              ),
            ),
            onTapOutside: (_) => FocusScope.of(context).unfocus(),
          ),
        );
      },
    );
  }
}
