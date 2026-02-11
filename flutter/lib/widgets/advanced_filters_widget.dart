import 'package:flutter/material.dart';
import '../utils/theme.dart';

class AdvancedFiltersWidget extends StatelessWidget {
  final List<String> selectedCategories;
  final List<String> selectedRegions;
  final List<String> selectedSalespersons;
  final List<String> selectedStatuses;
  final Function(List<String>) onCategoriesChanged;
  final Function(List<String>) onRegionsChanged;
  final Function(List<String>) onSalespersonsChanged;
  final Function(List<String>) onStatusesChanged;
  final VoidCallback onClearAll;

  const AdvancedFiltersWidget({
    super.key,
    required this.selectedCategories,
    required this.selectedRegions,
    required this.selectedSalespersons,
    required this.selectedStatuses,
    required this.onCategoriesChanged,
    required this.onRegionsChanged,
    required this.onSalespersonsChanged,
    required this.onStatusesChanged,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    final totalFilters = selectedCategories.length + 
                        selectedRegions.length + 
                        selectedSalespersons.length + 
                        selectedStatuses.length;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: NexusTheme.slate200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.filter_list, color: NexusTheme.emerald500, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'FILTERS',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 0.5),
                  ),
                  if (totalFilters > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: NexusTheme.emerald500,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$totalFilters',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              if (totalFilters > 0)
                TextButton.icon(
                  onPressed: onClearAll,
                  icon: const Icon(Icons.clear_all, size: 14),
                  label: const Text('CLEAR', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900)),
                  style: TextButton.styleFrom(
                    foregroundColor: NexusTheme.slate600,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Horizontal Scrollable Filter Chips
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildDropdownFilterChip(
                  context,
                  'Category',
                  Icons.category,
                  ['Electronics', 'Grocery', 'Fashion', 'Home & Kitchen', 'Sports'],
                  selectedCategories,
                  onCategoriesChanged,
                  NexusTheme.indigo600,
                ),
                const SizedBox(width: 8),
                _buildDropdownFilterChip(
                  context,
                  'Region',
                  Icons.location_on,
                  ['North', 'South', 'East', 'West', 'Central'],
                  selectedRegions,
                  onRegionsChanged,
                  NexusTheme.emerald600,
                ),
                const SizedBox(width: 8),
                _buildDropdownFilterChip(
                  context,
                  'Salesperson',
                  Icons.person,
                  ['Animesh Jamuar', 'Rahul Sharma', 'Priya Singh', 'Amit Kumar'],
                  selectedSalespersons,
                  onSalespersonsChanged,
                  NexusTheme.blue600,
                ),
                const SizedBox(width: 8),
                _buildDropdownFilterChip(
                  context,
                  'Status',
                  Icons.check_circle,
                  ['Pending', 'Approved', 'In Transit', 'Delivered', 'Cancelled'],
                  selectedStatuses,
                  onStatusesChanged,
                  NexusTheme.purple600,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownFilterChip(
    BuildContext context,
    String label,
    IconData icon,
    List<String> options,
    List<String> selectedValues,
    Function(List<String>) onChanged,
    Color color,
  ) {
    final hasSelection = selectedValues.isNotEmpty;
    
    return InkWell(
      onTap: () => _showFilterDialog(context, label, icon, options, selectedValues, onChanged, color),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: hasSelection ? color.withOpacity(0.1) : NexusTheme.slate50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasSelection ? color : NexusTheme.slate200,
            width: hasSelection ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: hasSelection ? color : NexusTheme.slate400),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: hasSelection ? color : NexusTheme.slate600,
              ),
            ),
            if (hasSelection) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${selectedValues.length}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              size: 18,
              color: hasSelection ? color : NexusTheme.slate400,
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog(
    BuildContext context,
    String title,
    IconData icon,
    List<String> options,
    List<String> selectedValues,
    Function(List<String>) onChanged,
    Color color,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Text(
              'Select $title',
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
            ),
          ],
        ),
        content: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: options.map((option) {
              final isSelected = selectedValues.contains(option);
              return CheckboxListTile(
                value: isSelected,
                onChanged: (bool? value) {
                  final newList = List<String>.from(selectedValues);
                  if (value == true) {
                    newList.add(option);
                  } else {
                    newList.remove(option);
                  }
                  onChanged(newList);
                  Navigator.pop(context);
                  // Reopen dialog to show updated selection
                  Future.delayed(const Duration(milliseconds: 100), () {
                    _showFilterDialog(context, title, icon, options, newList, onChanged, color);
                  });
                },
                title: Text(option, style: const TextStyle(fontSize: 14)),
                activeColor: color,
                dense: true,
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('DONE'),
          ),
        ],
      ),
    );
  }
}
