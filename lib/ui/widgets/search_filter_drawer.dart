import 'package:pharos/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:pharos/core/theme/app_spacing.dart';
import 'package:provider/provider.dart';
import 'package:pharos/core/providers/search_provider.dart';
import 'package:pharos/data/models/filter_model.dart';
import 'package:pharos/l10n/app_localizations.dart';

class SearchFilterDrawer extends StatelessWidget {
  const SearchFilterDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final searchProvider = context.watch<SearchProvider>();
    
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.85,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppLocalizations.of(context)!.filtering, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 2)),
                  TextButton(
                    onPressed: () => searchProvider.clearFilters(),
                    child: Text(AppLocalizations.of(context)!.clearUpper, style: TextStyle(color: AppColors.accentText)),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: searchProvider.availableFilters.length,
                itemBuilder: (context, index) {
                  final group = searchProvider.availableFilters[index];
                  if (group.values.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return _buildFilterGroup(context, group, searchProvider);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(AppLocalizations.of(context)!.showResults, style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildFilterGroup(BuildContext context, FilterGroup group, SearchProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.s24),
        Text(group.name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1, color: AppColors.textMuted)),
        const SizedBox(height: AppSpacing.s12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: group.values.map((value) => _buildFilterChip(group.id, value, provider)).toList(),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String groupId, FilterValue value, SearchProvider provider) {
    final isSelected = value.isSelected;
    
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (value.colorHex != null) ...[
            Container(
              width: 16, height: 16,
              decoration: BoxDecoration(
                color: Color(int.parse(value.colorHex!.replaceFirst('#', '0xFF'))),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border, width: 1),
              ),
            ),
            const SizedBox(width: AppSpacing.s8),
          ],
          Text(value.name),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) => provider.toggleFilter(groupId, value.id),
      selectedColor: AppColors.accentText.withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.accentText : AppColors.black,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: isSelected ? AppColors.accentText : AppColors.border),
      ),
      backgroundColor: AppColors.text,
    );
  }
}
