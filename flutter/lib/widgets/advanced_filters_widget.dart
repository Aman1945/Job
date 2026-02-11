import 'package:flutter/material.dart';
import '../utils/theme.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class AdvancedFiltersWidget extends StatefulWidget {
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
  State<AdvancedFiltersWidget> createState() => _AdvancedFiltersWidgetState();
}

class _AdvancedFiltersWidgetState extends State<AdvancedFiltersWidget> {
  @override
  Widget build(BuildContext context) {
    final totalFilters = widget.selectedCategories.length + 
                        widget.selectedRegions.length + 
                        widget.selectedSalespersons.length + 
                        widget.selectedStatuses.length;

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
                  onPressed: widget.onClearAll,
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
          
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildLibraryDropdown(
                  'Category',
                  Icons.category,
                  ['Electronics', 'Grocery', 'Fashion', 'Home & Kitchen', 'Sports'],
                  widget.selectedCategories,
                  widget.onCategoriesChanged,
                  NexusTheme.indigo600,
                ),
                const SizedBox(width: 8),
                _buildLibraryDropdown(
                  'Region',
                  Icons.location_on,
                  ['North', 'South', 'East', 'West', 'Central'],
                  widget.selectedRegions,
                  widget.onRegionsChanged,
                  NexusTheme.emerald600,
                ),
                const SizedBox(width: 8),
                _buildLibraryDropdown(
                  'Salesperson',
                  Icons.person,
                  ['Animesh Jamuar', 'Rahul Sharma', 'Priya Singh', 'Amit Kumar'],
                  widget.selectedSalespersons,
                  widget.onSalespersonsChanged,
                  NexusTheme.blue600,
                ),
                const SizedBox(width: 8),
                _buildLibraryDropdown(
                  'Status',
                  Icons.check_circle,
                  ['Pending', 'Approved', 'In Transit', 'Delivered', 'Cancelled'],
                  widget.selectedStatuses,
                  widget.onStatusesChanged,
                  NexusTheme.purple600,
                ),
              ],
            ),
          ),
          
          if (totalFilters > 0) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ..._buildFilterTags(widget.selectedCategories, widget.onCategoriesChanged, NexusTheme.indigo600),
                ..._buildFilterTags(widget.selectedRegions, widget.onRegionsChanged, NexusTheme.emerald600),
                ..._buildFilterTags(widget.selectedSalespersons, widget.onSalespersonsChanged, NexusTheme.blue600),
                ..._buildFilterTags(widget.selectedStatuses, widget.onStatusesChanged, NexusTheme.purple600),
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
            enabled: false,
            child: StatefulBuilder(
              builder: (context, menuSetState) {
                // IMPORTANT: We use the local list to track state while the menu is open
                final bool isSelected = selectedValues.contains(item);
                
                return InkWell(
                  onTap: () {
                    if (isSelected) {
                      selectedValues.remove(item);
                    } else {
                      selectedValues.add(item);
                    }
                    
                    // Notify parent with a copy to ensure it triggers its own logic
                    onChanged(List<String>.from(selectedValues));
                    
                    // Immediate UI update for the menu item
                    menuSetState(() {});
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Icon(
                          isSelected ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                          color: isSelected ? color : NexusTheme.slate400,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
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
        onChanged: (value) {},
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
