import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pharos/core/providers/search_provider.dart';
import 'package:pharos/data/models/filter_model.dart';

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
                  const Text('FILTROWANIE', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 2)),
                  TextButton(
                    onPressed: () => searchProvider.clearFilters(),
                    child: const Text('WYCZYŚĆ', style: TextStyle(color: Colors.orange)),
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
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('POKAŻ WYNIKI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
        const SizedBox(height: 24),
        Text(group.name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1, color: Colors.grey)),
        const SizedBox(height: 12),
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
                border: Border.all(color: Colors.grey[300]!, width: 1),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Text(value.name),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) => provider.toggleFilter(groupId, value.id),
      selectedColor: Colors.orange.withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected ? Colors.orange : Colors.black,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: isSelected ? Colors.orange : Colors.grey[300]!),
      ),
      backgroundColor: Colors.white,
    );
  }
}
