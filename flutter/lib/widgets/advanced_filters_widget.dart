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
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Select $title',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                  ),
                ),
                if (selectedValues.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        onChanged([]);
                      });
                    },
                    child: const Text('CLEAR ALL', style: TextStyle(fontSize: 11)),
                  ),
              ],
            ),
            content: SizedBox(
              width: 350,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Selected values as removable chips
                  if (selectedValues.isNotEmpty) ...[
                    const Text(
                      'SELECTED:',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: NexusTheme.slate400),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: selectedValues.map((value) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: color, width: 1.5),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                value,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                ),
                              ),
                              const SizedBox(width: 6),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    final newList = List<String>.from(selectedValues);
                                    newList.remove(value);
                                    onChanged(newList);
                                  });
                                },
                                child: Icon(
                                  Icons.close,
                                  size: 16,
                                  color: color,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 12),
                  ],
                  
                  // Dropdown list of options
                  const Text(
                    'SELECT OPTIONS:',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: NexusTheme.slate400),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 250),
                    child: SingleChildScrollView(
                      child: Column(
                        children: options.map((option) {
                          final isSelected = selectedValues.contains(option);
                          return InkWell(
                            onTap: () {
                              setState(() {
                                final newList = List<String>.from(selectedValues);
                                if (isSelected) {
                                  newList.remove(option);
                                } else {
                                  newList.add(option);
                                }
                                onChanged(newList);
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              margin: const EdgeInsets.only(bottom: 4),
                              decoration: BoxDecoration(
                                color: isSelected ? color.withOpacity(0.05) : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected ? color.withOpacity(0.3) : NexusTheme.slate200,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                                    color: isSelected ? color : NexusTheme.slate400,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      option,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                        color: isSelected ? color : NexusTheme.slate700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('DONE'),
              ),
            ],
          );
        },
      ),
    );
  }
}
