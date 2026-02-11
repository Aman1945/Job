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
    return Container(
      padding: const EdgeInsets.all(20),
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
              const Row(
                children: [
                  Icon(Icons.filter_list, color: NexusTheme.emerald500, size: 24),
                  SizedBox(width: 12),
                  Text(
                    'ADVANCED FILTERS',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 0.5),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: onClearAll,
                icon: const Icon(Icons.clear_all, size: 16),
                label: const Text('CLEAR ALL'),
                style: TextButton.styleFrom(
                  foregroundColor: NexusTheme.slate600,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Category Filter
          _buildMultiSelectFilter(
            'Category',
            ['Electronics', 'Grocery', 'Fashion', 'Home & Kitchen', 'Sports'],
            selectedCategories,
            onCategoriesChanged,
            Icons.category,
          ),
          const SizedBox(height: 16),
          
          // Region Filter
          _buildMultiSelectFilter(
            'Region',
            ['North', 'South', 'East', 'West', 'Central'],
            selectedRegions,
            onRegionsChanged,
            Icons.location_on,
          ),
          const SizedBox(height: 16),
          
          // Salesperson Filter
          _buildMultiSelectFilter(
            'Salesperson',
            ['Animesh Jamuar', 'Rahul Sharma', 'Priya Singh', 'Amit Kumar'],
            selectedSalespersons,
            onSalespersonsChanged,
            Icons.person,
          ),
          const SizedBox(height: 16),
          
          // Status Filter
          _buildMultiSelectFilter(
            'Order Status',
            ['Pending', 'Approved', 'In Transit', 'Delivered', 'Cancelled'],
            selectedStatuses,
            onStatusesChanged,
            Icons.check_circle,
          ),
        ],
      ),
    );
  }

  Widget _buildMultiSelectFilter(
    String label,
    List<String> options,
    List<String> selectedValues,
    Function(List<String>) onChanged,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: NexusTheme.slate400),
            const SizedBox(width: 8),
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: NexusTheme.slate400,
                letterSpacing: 0.5,
              ),
            ),
            if (selectedValues.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: NexusTheme.emerald50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${selectedValues.length}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: NexusTheme.emerald600,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = selectedValues.contains(option);
            return InkWell(
              onTap: () {
                final newList = List<String>.from(selectedValues);
                if (isSelected) {
                  newList.remove(option);
                } else {
                  newList.add(option);
                }
                onChanged(newList);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? NexusTheme.emerald500 : NexusTheme.slate50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? NexusTheme.emerald600 : NexusTheme.slate200,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSelected)
                      const Icon(Icons.check, size: 14, color: Colors.white),
                    if (isSelected) const SizedBox(width: 6),
                    Text(
                      option,
                      style: TextStyle(
                        color: isSelected ? Colors.white : NexusTheme.slate700,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
