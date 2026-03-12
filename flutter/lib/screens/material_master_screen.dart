import 'dart:io';
import 'package:excel/excel.dart' as xl;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/nexus_provider.dart';
import '../utils/theme.dart';
import '../utils/master_actions.dart';
import '../models/models.dart';
import '../config/api_config.dart';
import '../providers/auth_provider.dart';
import '../widgets/row_detail_panel.dart';

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
  Product? _selectedProduct;

  late final ScrollController _vFrozen;
  late final ScrollController _vBody;
  late final ScrollController _hHeader;
  late final ScrollController _hBody;
  bool _syncingV = false;
  bool _syncingH = false;

  @override
  void initState() {
    super.initState();
    _vFrozen = ScrollController();
    _vBody   = ScrollController();
    _hHeader = ScrollController();
    _hBody   = ScrollController();

    _vFrozen.addListener(() {
      if (_syncingV) return;
      _syncingV = true;
      if (_vBody.hasClients) _vBody.jumpTo(_vFrozen.offset);
      _syncingV = false;
    });
    _vBody.addListener(() {
      if (_syncingV) return;
      _syncingV = true;
      if (_vFrozen.hasClients) _vFrozen.jumpTo(_vBody.offset);
      _syncingV = false;
    });

    _hHeader.addListener(() {
      if (_syncingH) return;
      _syncingH = true;
      if (_hBody.hasClients) _hBody.jumpTo(_hHeader.offset);
      _syncingH = false;
    });
    _hBody.addListener(() {
      if (_syncingH) return;
      _syncingH = true;
      if (_hHeader.hasClients) _hHeader.jumpTo(_hBody.offset);
      _syncingH = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _vFrozen.dispose();
    _vBody.dispose();
    _hHeader.dispose();
    _hBody.dispose();
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
                        child: AnimatedDetailWrapper(
                          selectedKey: _selectedProduct?.id,
                          table: _buildTable(pageItems),
                          detailPanel: _selectedProduct == null ? null : RowDetailPanel(
                            title: _selectedProduct!.shortName ?? _selectedProduct!.name,
                            icon: Icons.inventory_2_outlined,
                            accentColor: const Color(0xFF059669),
                            onClose: () => setState(() => _selectedProduct = null),
                            fields: [
                              ('Product Name', _selectedProduct!.name),
                              ('Short Name', _selectedProduct!.shortName ?? '-'),
                              ('SKU Code', _selectedProduct!.skuCode),
                              ('Category', _selectedProduct!.category),
                              ('Specie', _selectedProduct!.specie ?? '-'),
                              ('Packing', _selectedProduct!.productPacking ?? '-'),
                              ('HSN Code', _selectedProduct!.hsnCode ?? '-'),
                              ('GST %', _selectedProduct!.gst != null ? '${_selectedProduct!.gst!.toStringAsFixed(1)}%' : '-'),
                              ('MRP', _selectedProduct!.mrp != null ? '₹${_selectedProduct!.mrp!.toStringAsFixed(2)}' : '-'),
                              ('Price', _selectedProduct!.price > 0 ? '₹${_selectedProduct!.price.toStringAsFixed(2)}' : '-'),
                              ('Stock', _selectedProduct!.stock.toString()),
                              ('Origin', _selectedProduct!.countryOfOrigin ?? '-'),
                            ],
                          ),
                        ),
                      ),
                      _buildPagination(filtered.length, totalPages, start, end),
                    ],
                  ],
                ),
              ),
            ),
          ),
          // ── Action bar (Add / Import / Export) ──────────────────────────────
          MasterActions.actionBar(
            context: context,
            onAdd: () => _showAddDialog(context, provider),
            onImport: () => MasterActions.importExcel(
              context: context,
              uploadRoute: '/products/bulk-import',
              token: Provider.of<AuthProvider>(context, listen: false).token,
              onSuccess: provider.fetchProducts,
            ),
            onExport: () => _exportProductsToExcel(context, allProducts),
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

    final headerRow = Row(
      children: [
        frozenCell('PRODUCT NAME', isHeader: true),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            controller: _hHeader,
            child: Row(
              children: scrollCols.map((c) => scrollCell(c.$1, c.$2, isHeader: true)).toList(),
            ),
          ),
        ),
      ],
    );

    return Column(
      children: [
        headerRow,
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Frozen name column
              SingleChildScrollView(
                controller: _vFrozen,
                child: Column(
                  children: items.map((p) => GestureDetector(
                    onTap: () => setState(() =>
                        _selectedProduct = (_selectedProduct?.id == p.id) ? null : p),
                    child: Container(
                      color: _selectedProduct?.id == p.id ? const Color(0xFFEEF2FF) : Colors.transparent,
                      child: frozenCell(p.shortName ?? p.name),
                    ),
                  )).toList(),
                ),
              ),
              // Scrollable body
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  controller: _hBody,
                  child: SingleChildScrollView(
                    controller: _vBody,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: items.map((p) => GestureDetector(
                        onTap: () => setState(() =>
                            _selectedProduct = (_selectedProduct?.id == p.id) ? null : p),
                        child: Container(
                          color: _selectedProduct?.id == p.id ? const Color(0xFFEEF2FF) : Colors.transparent,
                          child: Row(
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
                          ),
                        ),
                      )).toList(),
                    ),
                  ),
                ),
              ),
            ],
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

  // ───────────────────────── ADD NEW PRODUCT DIALOG ──────────────────────────
  void _showAddDialog(BuildContext context, NexusProvider provider) {
    final formKey = GlobalKey<FormState>();
    final name = TextEditingController();
    final sku  = TextEditingController();
    final cat  = TextEditingController();
    final mrp  = TextEditingController();
    final price = TextEditingController();
    final gst  = TextEditingController(text: '5');
    final hsn  = TextEditingController();
    final stock = TextEditingController(text: '0');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Add New Product', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        content: SizedBox(
          width: 380,
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _field('Product Name *', name, required: true),
                  _field('SKU Code *', sku, required: true),
                  _field('Category *', cat, required: true),
                  _field('HSN Code', hsn),
                  _field('MRP (₹)', mrp, numeric: true),
                  _field('Price (₹)', price, numeric: true),
                  _field('GST %', gst, numeric: true),
                  _field('Stock (units)', stock, numeric: true),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final ok = await MasterActions.postRecord(
                context: context,
                route: '/products',
                token: Provider.of<AuthProvider>(context, listen: false).token,
                data: {
                  'name': name.text.trim(),
                  'skuCode': sku.text.trim(),
                  'category': cat.text.trim(),
                  'hsnCode': hsn.text.trim(),
                  'mrp': double.tryParse(mrp.text) ?? 0,
                  'price': double.tryParse(price.text) ?? 0,
                  'gst': double.tryParse(gst.text) ?? 5,
                  'stock': int.tryParse(stock.text) ?? 0,
                },
              );
              if (ok && ctx.mounted) {
                Navigator.pop(ctx);
                MasterActions.showSuccess(context, 'Product created successfully');
                provider.fetchProducts();
              }
            },
            child: const Text('SAVE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, {bool required = false, bool numeric = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        keyboardType: numeric ? TextInputType.number : TextInputType.text,
        validator: required ? (v) => (v == null || v.isEmpty) ? 'Required' : null : null,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }

  Future<void> _exportProductsToExcel(BuildContext context, List<Product> products) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('📊 Preparing Excel export...'), backgroundColor: NexusTheme.indigo500, behavior: SnackBarBehavior.floating),
    );

    try {
      final excel = xl.Excel.createExcel();
      final sheet = excel['SKU Master'];

      // Headers matching the user's provided Excel Template Image
      final headers = [
        'ProductCode', 'Product Name', 'ProductShortName', 'DistributionChannel', 
        'Specie', 'Packing', 'MRP', 'GST%', 'HSNCODE', 'COUNTRY OF ORIGIN'
      ];
      sheet.appendRow(headers.map((h) => xl.TextCellValue(h)).toList());

      // Data rows
      for (final p in products) {
        sheet.appendRow([
          xl.TextCellValue(p.skuCode),                             // ProductCode
          xl.TextCellValue(p.name),                                // Product Name
          xl.TextCellValue(p.shortName ?? ''),                     // ProductShortName
          xl.TextCellValue(p.distributionChannel ?? ''),           // DistributionChannel
          xl.TextCellValue(p.specie ?? ''),                        // Specie
          xl.TextCellValue(p.productPacking ?? ''),                // Packing
          xl.DoubleCellValue(p.mrp ?? 0),                          // MRP
          xl.TextCellValue(p.gst != null ? '${p.gst!.toStringAsFixed(0)}%' : ''), // GST%
          xl.TextCellValue(p.hsnCode ?? ''),                       // HSNCODE
          xl.TextCellValue(p.countryOfOrigin ?? ''),               // COUNTRY OF ORIGIN
        ]);
      }

      final dir = await getExternalStorageDirectory();
      final filePath = '${dir!.path}/SKU_Master_Export_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      
      final fileBytes = excel.save();
      if (fileBytes != null) {
        await File(filePath).writeAsBytes(fileBytes);
        await OpenFile.open(filePath);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Exported ${products.length} SKU Master records!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Export failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
