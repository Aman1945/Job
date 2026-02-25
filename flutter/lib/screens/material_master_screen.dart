import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/nexus_provider.dart';
import '../utils/theme.dart';
import '../models/models.dart';

class MaterialMasterScreen extends StatefulWidget {
  const MaterialMasterScreen({super.key});

  @override
  State<MaterialMasterScreen> createState() => _MaterialMasterScreenState();
}

class _MaterialMasterScreenState extends State<MaterialMasterScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'ALL';
  int _currentPage = 0;
  static const int _pageSize = 15;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NexusProvider>(context);
    final allProducts = provider.products;

    // Filter products
    final categories = ['ALL', ...allProducts.map((p) => p.category).toSet().toList()..sort()];
    final filtered = allProducts.where((p) {
      final matchSearch = _searchQuery.isEmpty ||
          p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.skuCode.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (p.hsnCode?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      final matchCat = _selectedCategory == 'ALL' || p.category == _selectedCategory;
      return matchSearch && matchCat;
    }).toList();

    final totalPages = filtered.isEmpty ? 1 : (filtered.length / _pageSize).ceil();
    final start = _currentPage * _pageSize;
    final end = (start + _pageSize).clamp(0, filtered.length);
    final pageItems = filtered.isEmpty ? <Product>[] : filtered.sublist(start, end);

    return Scaffold(
      backgroundColor: NexusTheme.slate50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'MATERIAL MASTER',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1, color: Color(0xFF1E293B)),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Metric banner ──────────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Row(
                  children: [
                    _metricCard('TOTAL SKUs', allProducts.length.toString(), NexusTheme.indigo600, Icons.inventory_2_outlined),
                    const SizedBox(width: 12),
                    _metricCard('CATEGORIES', (categories.length - 1).toString(), NexusTheme.emerald500, Icons.category_outlined),
                    const SizedBox(width: 12),
                    _metricCard('IN STOCK', allProducts.where((p) => p.stock > 0).length.toString(), Colors.orange, Icons.verified_outlined),
                  ],
                ),
                const SizedBox(height: 16),
                // Search bar
                TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() { _searchQuery = v; _currentPage = 0; }),
                  decoration: InputDecoration(
                    hintText: 'Search by SKU, Name, HSN Code...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    filled: true,
                    fillColor: NexusTheme.slate50,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                const SizedBox(height: 12),
                // Category filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: categories.map((cat) {
                      final isSelected = _selectedCategory == cat;
                      return GestureDetector(
                        onTap: () => setState(() { _selectedCategory = cat; _currentPage = 0; }),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF0F172A) : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Text(
                            cat,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: isSelected ? Colors.white : const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // ── Table ──────────────────────────────────────────────────────
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 6))],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Column(
                  children: [
                    if (filtered.isEmpty)
                      const Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.inventory_2_outlined, size: 60, color: Color(0xFFCBD5E1)),
                              SizedBox(height: 16),
                              Text('NO PRODUCTS FOUND', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF94A3B8), letterSpacing: 1)),
                            ],
                          ),
                        ),
                      )
                    else ...[
                      Expanded(
                        child: _buildTable(pageItems),
                      ),
                      _buildPagination(filtered.length, totalPages, start, end),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricCard(String label, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border(left: BorderSide(color: color, width: 3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 13, color: color),
                const SizedBox(width: 6),
                Flexible(child: Text(label, style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: color, letterSpacing: 0.5), overflow: TextOverflow.ellipsis)),
              ],
            ),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -0.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildTable(List<Product> items) {
    const headerColor = Color(0xFF64748B);
    const headerBg = Color(0xFFF1F5F9);
    const divider = Color(0xFFE2E8F0);
    const rowDivider = Color(0xFFE8EDF2);

    // Columns: (label, width)
    final scrollCols = [
      ('SKU CODE', 110.0),
      ('CATEGORY', 110.0),
      ('SPECIE', 90.0),
      ('PACKING', 90.0),
      ('HSN CODE', 90.0),
      ('GST %', 65.0),
      ('MRP', 80.0),
      ('PRICE', 80.0),
      ('STOCK', 65.0),
      ('ORIGIN', 90.0),
    ];

    Widget frozenCell(String text, {bool isHeader = false}) => Container(
      width: 160,
      height: 46,
      decoration: BoxDecoration(
        color: isHeader ? headerBg : Colors.white,
        border: Border(
          right: const BorderSide(color: divider, width: 1),
          bottom: BorderSide(color: rowDivider, width: 1),
        ),
      ),
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: isHeader ? 9 : 11,
          fontWeight: isHeader ? FontWeight.w700 : FontWeight.w600,
          color: isHeader ? headerColor : const Color(0xFF0F172A),
          letterSpacing: isHeader ? 0.6 : 0,
        ),
      ),
    );

    Widget scrollCell(String text, double width, {bool isHeader = false, Color? textColor}) => Container(
      width: width,
      height: 46,
      decoration: BoxDecoration(
        color: isHeader ? headerBg : Colors.white,
        border: Border(
          right: const BorderSide(color: divider, width: 1),
          bottom: BorderSide(color: rowDivider, width: 1),
        ),
      ),
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: isHeader ? 9 : 11,
          fontWeight: isHeader ? FontWeight.w700 : FontWeight.w500,
          color: textColor ?? (isHeader ? headerColor : const Color(0xFF1E293B)),
          letterSpacing: isHeader ? 0.6 : 0,
        ),
      ),
    );

    final scrollController = ScrollController();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Frozen: Product Name
        SingleChildScrollView(
          child: Column(
            children: [
              frozenCell('PRODUCT NAME', isHeader: true),
              ...items.map((p) => frozenCell(p.shortName ?? p.name)),
            ],
          ),
        ),
        // Scrollable columns
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            controller: scrollController,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: scrollCols.map((c) => scrollCell(c.$1, c.$2, isHeader: true)).toList()),
                  ...items.map((p) => Row(
                    children: [
                      scrollCell(p.skuCode, scrollCols[0].$2, textColor: NexusTheme.indigo600),
                      scrollCell(p.category, scrollCols[1].$2),
                      scrollCell(p.specie ?? '-', scrollCols[2].$2),
                      scrollCell(p.productPacking ?? '-', scrollCols[3].$2),
                      scrollCell(p.hsnCode ?? '-', scrollCols[4].$2),
                      scrollCell(p.gst != null ? '${p.gst!.toStringAsFixed(0)}%' : '-', scrollCols[5].$2),
                      scrollCell(p.mrp != null ? '₹${p.mrp!.toStringAsFixed(0)}' : '-', scrollCols[6].$2, textColor: const Color(0xFF059669)),
                      scrollCell(p.price > 0 ? '₹${p.price.toStringAsFixed(0)}' : '-', scrollCols[7].$2, textColor: const Color(0xFF7C3AED)),
                      scrollCell(p.stock.toString(), scrollCols[8].$2, textColor: p.stock > 0 ? const Color(0xFF059669) : Colors.redAccent),
                      scrollCell(p.countryOfOrigin ?? '-', scrollCols[9].$2),
                    ],
                  )),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPagination(int total, int totalPages, int start, int end) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Showing ${start + 1}–$end of $total records',
            style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600)),
          Row(
            children: [
              _paginationBtn(icon: Icons.chevron_left, enabled: _currentPage > 0, onTap: () => setState(() => _currentPage--)),
              const SizedBox(width: 8),
              Text('${_currentPage + 1} / $totalPages', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF334155))),
              const SizedBox(width: 8),
              _paginationBtn(icon: Icons.chevron_right, enabled: _currentPage < totalPages - 1, onTap: () => setState(() => _currentPage++)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _paginationBtn({required IconData icon, required bool enabled, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          color: enabled ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: enabled ? Colors.white : const Color(0xFFCBD5E1)),
      ),
    );
  }
}
