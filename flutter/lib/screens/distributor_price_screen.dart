import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:excel/excel.dart' as xl;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import '../providers/nexus_provider.dart';
import '../utils/theme.dart';
import '../utils/master_actions.dart';
import '../models/models.dart';
import '../config/api_config.dart';
import '../widgets/row_detail_panel.dart';

// Static distributor price data (from Excel)
class _DistPrice {
  final String code;
  final String name;
  final String materialNumber;
  final double mrp;
  final String inKg;
  final double gstPct;
  final double retailerMarginOnMrp;
  final double distMarginOnCost;
  final double distMarginOnMrp;
  final double billingRate;

  const _DistPrice({
    required this.code,
    required this.name,
    required this.materialNumber,
    required this.mrp,
    required this.inKg,
    required this.gstPct,
    required this.retailerMarginOnMrp,
    required this.distMarginOnCost,
    required this.distMarginOnMrp,
    required this.billingRate,
  });
}

// Fallback static data (replace/extend from backend later)
final List<_DistPrice> _staticDistPrices = [
  _DistPrice(code: 'SKU-001', name: 'Product Alpha 5Kg', materialNumber: 'MAT-10001', mrp: 850, inKg: '5 Kg', gstPct: 5, retailerMarginOnMrp: 15, distMarginOnCost: 10, distMarginOnMrp: 8.5, billingRate: 720),
  _DistPrice(code: 'SKU-002', name: 'Product Beta 10Kg', materialNumber: 'MAT-10002', mrp: 1500, inKg: '10 Kg', gstPct: 5, retailerMarginOnMrp: 15, distMarginOnCost: 10, distMarginOnMrp: 8.5, billingRate: 1275),
  _DistPrice(code: 'SKU-003', name: 'Product Gamma 25Kg', materialNumber: 'MAT-10003', mrp: 3200, inKg: '25 Kg', gstPct: 5, retailerMarginOnMrp: 18, distMarginOnCost: 12, distMarginOnMrp: 10, billingRate: 2700),
  _DistPrice(code: 'SKU-004', name: 'Product Delta 50Kg', materialNumber: 'MAT-10004', mrp: 5800, inKg: '50 Kg', gstPct: 12, retailerMarginOnMrp: 20, distMarginOnCost: 15, distMarginOnMrp: 12, billingRate: 4800),
  _DistPrice(code: 'SKU-005', name: 'Product Sigma 1Kg', materialNumber: 'MAT-10005', mrp: 200, inKg: '1 Kg', gstPct: 5, retailerMarginOnMrp: 12, distMarginOnCost: 8, distMarginOnMrp: 7, billingRate: 172),
  _DistPrice(code: 'SKU-006', name: 'Product Omega 2Kg', materialNumber: 'MAT-10006', mrp: 380, inKg: '2 Kg', gstPct: 5, retailerMarginOnMrp: 12, distMarginOnCost: 8, distMarginOnMrp: 7, billingRate: 326),
  _DistPrice(code: 'SKU-007', name: 'Product Zeta 500g', materialNumber: 'MAT-10007', mrp: 120, inKg: '500 g', gstPct: 5, retailerMarginOnMrp: 10, distMarginOnCost: 7, distMarginOnMrp: 6, billingRate: 104),
  _DistPrice(code: 'SKU-008', name: 'Product Theta 20Kg', materialNumber: 'MAT-10008', mrp: 2700, inKg: '20 Kg', gstPct: 12, retailerMarginOnMrp: 18, distMarginOnCost: 12, distMarginOnMrp: 10, billingRate: 2250),
];

class DistributorPriceScreen extends StatefulWidget {
  const DistributorPriceScreen({super.key});

  @override
  State<DistributorPriceScreen> createState() => _DistributorPriceScreenState();
}

class _DistributorPriceScreenState extends State<DistributorPriceScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _currentPage = 0;
  static const int _pageSize = 15;
  _DistPrice? _selectedPrice;

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

  List<_DistPrice> _buildMergedList(List<Product> products, List<DistributorPrice> liveData) {
    // Prefer live backend data if available
    if (liveData.isNotEmpty) {
      return liveData.map((d) => _DistPrice(
        code: d.code,
        name: d.name,
        materialNumber: d.materialNumber ?? '-',
        mrp: d.mrp,
        inKg: d.inKg ?? '-',
        gstPct: d.gstPct,
        retailerMarginOnMrp: d.retailerMarginOnMrp,
        distMarginOnCost: d.distMarginOnCost,
        distMarginOnMrp: d.distMarginOnMrp,
        billingRate: d.billingRate,
      )).toList();
    }

    // Fallback: derive from products with mrp data
    final dynamic = products.where((p) => p.mrp != null && p.mrp! > 0).map((p) => _DistPrice(
      code: p.skuCode,
      name: p.name,
      materialNumber: p.id,
      mrp: p.mrp!,
      inKg: p.productPacking ?? '-',
      gstPct: p.gst ?? 0,
      retailerMarginOnMrp: 0,
      distMarginOnCost: 0,
      distMarginOnMrp: 0,
      billingRate: p.price,
    )).toList();

    return dynamic.isNotEmpty ? dynamic : _staticDistPrices;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NexusProvider>(context);
    final allItems = _buildMergedList(provider.products, provider.distributorPrices);

    final filtered = allItems.where((item) {
      return _searchQuery.isEmpty ||
          item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.code.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.materialNumber.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    final totalPages = filtered.isEmpty ? 1 : (filtered.length / _pageSize).ceil();
    final start = _currentPage * _pageSize;
    final end = (start + _pageSize).clamp(0, filtered.length);
    final pageItems = filtered.isEmpty ? <_DistPrice>[] : filtered.sublist(start, end);

    // Summary stats
    final avgMrp = allItems.isEmpty ? 0.0 : allItems.fold(0.0, (s, i) => s + i.mrp) / allItems.length;
    final avgBilling = allItems.isEmpty ? 0.0 : allItems.fold(0.0, (s, i) => s + i.billingRate) / allItems.length;

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
          'DISTRIBUTOR PRICE LIST',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1, color: Color(0xFF1E293B)),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header metrics ──
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Row(
                  children: [
                    _metricCard('TOTAL SKUs', allItems.length.toString(), NexusTheme.indigo600, Icons.price_change_outlined),
                    const SizedBox(width: 12),
                    _metricCard('AVG MRP', '₹${avgMrp.toStringAsFixed(0)}', NexusTheme.emerald500, Icons.monetization_on_outlined),
                    const SizedBox(width: 12),
                    _metricCard('AVG BILLING', '₹${avgBilling.toStringAsFixed(0)}', Colors.deepOrange, Icons.receipt_long_outlined),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() { _searchQuery = v; _currentPage = 0; }),
                  decoration: InputDecoration(
                    hintText: 'Search by code, name or material number...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    filled: true,
                    fillColor: NexusTheme.slate50,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ],
            ),
          ),

          // ── Table ──
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
                              Icon(Icons.price_change_outlined, size: 60, color: Color(0xFFCBD5E1)),
                              SizedBox(height: 16),
                              Text('NO RECORDS FOUND', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF94A3B8), letterSpacing: 1)),
                            ],
                          ),
                        ),
                      )
                    else ...[
                      Expanded(
                        child: AnimatedDetailWrapper(
                          selectedKey: _selectedPrice?.code,
                          table: _buildTable(pageItems),
                          detailPanel: _selectedPrice == null ? null : RowDetailPanel(
                            title: _selectedPrice!.name,
                            icon: Icons.price_change_outlined,
                            accentColor: const Color(0xFF0369A1),
                            onClose: () => setState(() => _selectedPrice = null),
                            fields: [
                              ('Material Name', _selectedPrice!.name),
                              ('SKU Code', _selectedPrice!.code),
                              ('Material Number', _selectedPrice!.materialNumber),
                              ('In Kg', _selectedPrice!.inKg),
                              ('MRP', '₹${_selectedPrice!.mrp.toStringAsFixed(2)}'),
                              ('GST %', '${_selectedPrice!.gstPct.toStringAsFixed(0)}%'),
                              ('Retailer Margin on MRP', '${_selectedPrice!.retailerMarginOnMrp.toStringAsFixed(1)}%'),
                              ('Dist Margin on Cost', '${_selectedPrice!.distMarginOnCost.toStringAsFixed(1)}%'),
                              ('Dist Margin on MRP', '${_selectedPrice!.distMarginOnMrp.toStringAsFixed(1)}%'),
                              ('Billing Rate', '₹${_selectedPrice!.billingRate.toStringAsFixed(2)}'),
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
          // ── Action bar (Add / Import / Export) ──
          MasterActions.actionBar(
            context: context,
            onAdd: () => _showAddDialog(context, provider),
            onImport: () => MasterActions.importExcel(
              context: context,
              uploadRoute: '/distributor-prices/bulk-import',
              onSuccess: provider.fetchDistributorPrices,
            ),
            onExport: () => _exportDistPricesToExcel(context, allItems),
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
            Row(children: [
              Icon(icon, size: 13, color: color),
              const SizedBox(width: 6),
              Flexible(child: Text(label, style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: color, letterSpacing: 0.5), overflow: TextOverflow.ellipsis)),
            ]),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -0.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildTable(List<_DistPrice> items) {
    const headerColor = Color(0xFF64748B);
    const headerBg = Color(0xFFF1F5F9);
    const divider = Color(0xFFE2E8F0);
    const rowDivider = Color(0xFFE8EDF2);

    // Scrollable columns
    final scrollCols = [
      ('CODE', 90.0),
      ('MAT. NUMBER', 110.0),
      ('IN KG', 72.0),
      ('MRP', 90.0),
      ('GST %', 65.0),
      ('RET. MARGIN\nON MRP', 95.0),
      ('DIST MARGIN\nON COST', 95.0),
      ('DIST MARGIN\nON MRP', 90.0),
      ('BILLING RATE', 100.0),
    ];

    Widget frozenCell(String text, {bool isHeader = false}) => Container(
      width: 170,
      height: 50,
      decoration: BoxDecoration(
        color: isHeader ? headerBg : Colors.white,
        border: Border(
          right: const BorderSide(color: divider, width: 1),
          bottom: BorderSide(color: rowDivider, width: 1),
        ),
      ),
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Text(text, maxLines: 2, overflow: TextOverflow.ellipsis,
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
      height: 50,
      decoration: BoxDecoration(
        color: isHeader ? headerBg : Colors.white,
        border: Border(
          right: const BorderSide(color: divider, width: 1),
          bottom: BorderSide(color: rowDivider, width: 1),
        ),
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(text, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: isHeader ? 8 : 11,
          fontWeight: isHeader ? FontWeight.w700 : FontWeight.w500,
          color: textColor ?? (isHeader ? headerColor : const Color(0xFF1E293B)),
          letterSpacing: isHeader ? 0.5 : 0,
        ),
      ),
    );

    final headerRow = Row(
      children: [
        frozenCell('MATERIAL NAME', isHeader: true),
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
                        _selectedPrice = (_selectedPrice?.code == p.code) ? null : p),
                    child: Container(
                      color: _selectedPrice?.code == p.code ? const Color(0xFFEEF2FF) : Colors.transparent,
                      child: frozenCell(p.name),
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
                            _selectedPrice = (_selectedPrice?.code == p.code) ? null : p),
                        child: Container(
                          color: _selectedPrice?.code == p.code ? const Color(0xFFEEF2FF) : Colors.transparent,
                          child: Row(
                            children: [
                              scrollCell(p.code, scrollCols[0].$2, textColor: NexusTheme.indigo600),
                              scrollCell(p.materialNumber, scrollCols[1].$2),
                              scrollCell(p.inKg, scrollCols[2].$2),
                              scrollCell('₹${p.mrp.toStringAsFixed(0)}', scrollCols[3].$2, textColor: const Color(0xFF059669)),
                              scrollCell('${p.gstPct.toStringAsFixed(0)}%', scrollCols[4].$2),
                              scrollCell('${p.retailerMarginOnMrp.toStringAsFixed(1)}%', scrollCols[5].$2, textColor: Colors.orange.shade700),
                              scrollCell('${p.distMarginOnCost.toStringAsFixed(1)}%', scrollCols[6].$2, textColor: Colors.orange.shade700),
                              scrollCell('${p.distMarginOnMrp.toStringAsFixed(1)}%', scrollCols[7].$2, textColor: Colors.orange.shade700),
                              scrollCell('₹${p.billingRate.toStringAsFixed(0)}', scrollCols[8].$2, textColor: const Color(0xFF7C3AED)),
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

  // ─────────────────────── ADD NEW DISTRIBUTOR PRICE DIALOG ─────────────────────
  void _showAddDialog(BuildContext context, NexusProvider provider) {
    final formKey = GlobalKey<FormState>();
    final code     = TextEditingController();
    final name     = TextEditingController();
    final matNum   = TextEditingController();
    final inKg     = TextEditingController();
    final mrp      = TextEditingController();
    final gst      = TextEditingController(text: '5');
    final retMargin  = TextEditingController();
    final distCost   = TextEditingController();
    final distMrp    = TextEditingController();
    final billing    = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Add Distributor Price Entry', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        content: SizedBox(
          width: 380,
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _field('Code / SKU *', code, required: true),
                  _field('Material Name *', name, required: true),
                  _field('Material Number', matNum),
                  _field('Pack Size (e.g. 5 Kg)', inKg),
                  _field('MRP (₹) *', mrp, required: true, numeric: true),
                  _field('GST %', gst, numeric: true),
                  _field('Retailer Margin on MRP %', retMargin, numeric: true),
                  _field('Dist Margin on Cost %', distCost, numeric: true),
                  _field('Dist Margin on MRP %', distMrp, numeric: true),
                  _field('Billing Rate (₹) *', billing, required: true, numeric: true),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0369A1), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final ok = await MasterActions.postRecord(
                context: context,
                route: '/distributor-prices',
                data: {
                  'code': code.text.trim(),
                  'name': name.text.trim(),
                  'materialNumber': matNum.text.trim(),
                  'inKg': inKg.text.trim(),
                  'mrp': double.tryParse(mrp.text) ?? 0,
                  'gstPct': double.tryParse(gst.text) ?? 5,
                  'retailerMarginOnMrp': double.tryParse(retMargin.text) ?? 0,
                  'distMarginOnCost': double.tryParse(distCost.text) ?? 0,
                  'distMarginOnMrp': double.tryParse(distMrp.text) ?? 0,
                  'billingRate': double.tryParse(billing.text) ?? 0,
                },
              );
              if (ok && ctx.mounted) {
                Navigator.pop(ctx);
                MasterActions.showSuccess(context, 'Entry created successfully');
                provider.fetchDistributorPrices();
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

  Future<void> _exportDistPricesToExcel(BuildContext context, List<_DistPrice> items) async {
    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No distributor price data to export'), backgroundColor: Colors.orange),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('📊 Preparing Excel export...'), backgroundColor: NexusTheme.indigo500, behavior: SnackBarBehavior.floating),
    );

    try {
      final excel = xl.Excel.createExcel();
      final sheet = excel['Distributor Price List'];

      // Headers from User Template
      final headers = [
        'Material', 'Material Number', 'MRP', 'in Kg', '% GST',
        'Retailer Margin On MRP', 'Dist Margin On Cost', 'Dist Margin On MRP', 'Billing Rate'
      ];
      sheet.appendRow(headers.map((h) => xl.TextCellValue(h)).toList());

      // Data rows
      for (final p in items) {
        sheet.appendRow([
          xl.TextCellValue(p.code),                                // Material (SKU/Code)
          xl.TextCellValue(p.materialNumber),                        // Material Number
          xl.DoubleCellValue(p.mrp),                                 // MRP
          xl.TextCellValue(p.inKg),                                  // in Kg
          xl.TextCellValue('${p.gstPct.toStringAsFixed(0)}%'),       // % GST
          xl.TextCellValue('${p.retailerMarginOnMrp.toStringAsFixed(1)}%'), // Retailer Margin On MRP
          xl.TextCellValue('${p.distMarginOnCost.toStringAsFixed(1)}%'),    // Dist Margin On Cost
          xl.TextCellValue('${p.distMarginOnMrp.toStringAsFixed(1)}%'),     // Dist Margin On MRP
          xl.DoubleCellValue(p.billingRate),                         // Billing Rate
        ]);
      }

      final dir = await getExternalStorageDirectory();
      final filePath = '${dir!.path}/DistributorPrice_Export_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      final fileBytes = excel.encode();
      if (fileBytes != null) {
        await File(filePath).writeAsBytes(fileBytes);
        await OpenFile.open(filePath);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Exported ${items.length} records!'),
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
