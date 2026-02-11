import 'package:flutter/material.dart';
import '../utils/theme.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

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
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 10)],
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
          
          // Horizontal Scrollable Filter Dropdowns
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildLibraryDropdown(
                  'Category',
                  Icons.category,
                  ['Electronics', 'Grocery', 'Fashion', 'Home & Kitchen', 'Sports'],
                  selectedCategories,
                  onCategoriesChanged,
                  NexusTheme.indigo600,
                ),
                const SizedBox(width: 8),
                _buildLibraryDropdown(
                  'Region',
                  Icons.location_on,
                  ['North', 'South', 'East', 'West', 'Central'],
                  selectedRegions,
                  onRegionsChanged,
                  NexusTheme.emerald600,
                ),
                const SizedBox(width: 8),
                _buildLibraryDropdown(
                  'Salesperson',
                  Icons.person,
                  ['Animesh Jamuar', 'Rahul Sharma', 'Priya Singh', 'Amit Kumar'],
                  selectedSalespersons,
                  onSalespersonsChanged,
                  NexusTheme.blue600,
                ),
                const SizedBox(width: 8),
                _buildLibraryDropdown(
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
          
          // Selected Filter Tags with Individual Removal (Side "Cut" buttons)
          if (totalFilters > 0) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ..._buildFilterTags(selectedCategories, onCategoriesChanged, NexusTheme.indigo600),
                ..._buildFilterTags(selectedRegions, onRegionsChanged, NexusTheme.emerald600),
                ..._buildFilterTags(selectedSalespersons, onSalespersonsChanged, NexusTheme.blue600),
                ..._buildFilterTags(selectedStatuses, onStatusesChanged, NexusTheme.purple600),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLibraryDropdown(
    String label,
    IconData icon,
    List<String> options,
    List<String> selectedValues,
    Function(List<String>) onChanged,
    Color color,
  ) {
    final hasSelection = selectedValues.isNotEmpty;

    return DropdownButtonHideUnderline(
      child: DropdownButton2<String>(
        isExpanded: true,
        customButton: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: hasSelection ? color.withAlpha(25) : NexusTheme.slate50,
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
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_drop_down,
                size: 18,
                color: hasSelection ? color : NexusTheme.slate400,
              ),
            ],
          ),
        ),
        items: options.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            // Disable default onTap to handle multi-select logic manually
            enabled: false,
            child: StatefulBuilder(
              builder: (context, menuSetState) {
                final isSelected = selectedValues.contains(item);
                return InkWell(
                  onTap: () {
                    final newList = List<String>.from(selectedValues);
                    if (isSelected) {
                      newList.remove(item);
                    } else {
                      newList.add(item);
                    }
                    onChanged(newList);
                    menuSetState(() {});
                  },
                  child: Container(
                    height: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        if (isSelected)
                          Icon(Icons.check_box_rounded, color: color)
                        else
                          const Icon(Icons.check_box_outline_blank_rounded),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            item,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? color : NexusTheme.slate800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }).toList(),
        onChanged: (value) {}, // Handled by inner InkWell
        dropdownStyleData: DropdownStyleData(
          maxHeight: 300,
          width: 250,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          offset: const Offset(0, -8),
          scrollbarTheme: ScrollbarThemeData(
            radius: const Radius.circular(40),
            thickness: WidgetStateProperty.all(6),
            thumbVisibility: WidgetStateProperty.all(true),
          ),
        ),
        menuItemStyleData: const MenuItemStyleData(
          height: 48,
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }

  List<Widget> _buildFilterTags(List<String> selections, Function(List<String>) onChanged, Color color) {
    return selections.map((value) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withAlpha(25),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(width: 6),
            InkWell(
              onTap: () {
                final newList = List<String>.from(selections);
                newList.remove(value);
                onChanged(newList);
              },
              child: Icon(Icons.close, size: 14, color: color),
            ),
          ],
        ),
      );
    }).toList();
  }
}
