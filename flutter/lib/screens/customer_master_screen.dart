import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:excel/excel.dart' as xl;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import '../providers/nexus_provider.dart';
import '../utils/theme.dart';
import '../utils/master_actions.dart';
import '../providers/auth_provider.dart';
import '../models/models.dart';
import '../widgets/row_detail_panel.dart';

class CustomerMasterScreen extends StatefulWidget {
  const CustomerMasterScreen({super.key});

  @override
  State<CustomerMasterScreen> createState() => _CustomerMasterScreenState();
}

class _CustomerMasterScreenState extends State<CustomerMasterScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedStatus = 'ALL';
  int _currentPage = 0;
  static const int _pageSize = 15;
  Customer? _selectedCustomer;

  // Scroll controllers for frozen-column table
  late final ScrollController _vFrozen;   // frozen name column (vertical)
  late final ScrollController _vBody;     // scrollable body (vertical)
  late final ScrollController _hHeader;   // header row (horizontal)
  late final ScrollController _hBody;     // scrollable body (horizontal)
  bool _syncingV = false;
  bool _syncingH = false;

  @override
  void initState() {
    super.initState();
    _vFrozen = ScrollController();
    _vBody   = ScrollController();
    _hHeader = ScrollController();
    _hBody   = ScrollController();

    // Keep frozen + body in vertical sync
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

    // Keep header + body in horizontal sync
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
    final allCustomers = provider.customers;

    final statuses = ['ALL', 'Active', 'Inactive', 'Blocked'];
    final filtered = allCustomers.where((c) {
      final matchSearch = _searchQuery.isEmpty ||
          c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.id.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (c.salesManager?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
          (c.location?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      final matchStatus = _selectedStatus == 'ALL' || c.status == _selectedStatus;
      return matchSearch && matchStatus;
    }).toList();

    final totalPages = filtered.isEmpty ? 1 : (filtered.length / _pageSize).ceil();
    final start = _currentPage * _pageSize;
    final end = (start + _pageSize).clamp(0, filtered.length);
    final pageItems = filtered.isEmpty ? <Customer>[] : filtered.sublist(start, end);

    // Stats
    final activeCount = allCustomers.where((c) => c.status == 'Active').length;
    final totalCreditLimit = allCustomers.fold(0.0, (sum, c) => sum + c.limit);

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
          'CUSTOMER MASTER',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1, color: Color(0xFF1E293B)),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Metric banner ──
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Row(
                  children: [
                    _metricCard('TOTAL', allCustomers.length.toString(), NexusTheme.indigo600, Icons.business_outlined),
                    const SizedBox(width: 10),
                    _metricCard('ACTIVE', activeCount.toString(), NexusTheme.emerald500, Icons.check_circle_outline),
                    const SizedBox(width: 10),
                    _metricCard('CREDIT POOL', '₹${NumberFormat('#,##,###').format(totalCreditLimit)}', Colors.deepOrange, Icons.account_balance_outlined),
                  ],
                ),
                const SizedBox(height: 16),
                // Search
                TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() { _searchQuery = v; _currentPage = 0; }),
                  decoration: InputDecoration(
                    hintText: 'Search by Customer ID, Name, Manager, City...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    filled: true,
                    fillColor: NexusTheme.slate50,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                const SizedBox(height: 12),
                // Status filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: statuses.map((s) {
                      final isSelected = _selectedStatus == s;
                      Color chipColor = const Color(0xFF0F172A);
                      if (s == 'Active') chipColor = NexusTheme.emerald500;
                      if (s == 'Inactive') chipColor = Colors.orange;
                      if (s == 'Blocked') chipColor = Colors.redAccent;
                      return GestureDetector(
                        onTap: () => setState(() { _selectedStatus = s; _currentPage = 0; }),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: isSelected ? chipColor : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: isSelected ? chipColor : const Color(0xFFE2E8F0)),
                          ),
                          child: Text(s, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: isSelected ? Colors.white : const Color(0xFF64748B))),
                        ),
                      );
                    }).toList(),
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
                              Icon(Icons.business_outlined, size: 60, color: Color(0xFFCBD5E1)),
                              SizedBox(height: 16),
                              Text('NO CUSTOMERS FOUND', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF94A3B8), letterSpacing: 1)),
                            ],
                          ),
                        ),
                      )
                    else ...[
                      Expanded(
                        child: AnimatedDetailWrapper(
                          selectedKey: _selectedCustomer?.id,
                          table: _buildTable(pageItems),
                          detailPanel: _selectedCustomer == null ? null : () {
                            final fmt = NumberFormat('#,##,###');
                            final c = _selectedCustomer!;
                            return RowDetailPanel(
                              title: c.name,
                              icon: Icons.person_outline,
                              accentColor: const Color(0xFF6366F1),
                              onClose: () => setState(() => _selectedCustomer = null),
                              fields: [
                                ('Customer Name', c.name),
                                ('Customer ID', c.id),
                                ('Sales Manager', c.salesManager ?? '-'),
                                ('Status', c.status),
                                ('Channel', c.distributionChannel ?? '-'),
                                ('Class', c.customerClass ?? '-'),
                                ('Credit Limit', '₹${fmt.format(c.limit)}'),
                                ('Credit Days', '${c.exposureDays} days'),
                                ('O/S Balance', '₹${fmt.format(c.osBalance)}'),
                                ('OD Amount', '₹${fmt.format(c.odAmt)}'),
                                ('Location', c.location ?? '-'),
                                ('Postal Code', c.postalCode ?? '-'),
                                ('Email', c.customerEmail ?? '-'),
                                ('Address', c.address),
                              ],
                              photos: [
                                if (c.gstPhotoUrl != null) ('GST CERT', c.gstPhotoUrl!),
                                if (c.panPhotoUrl != null) ('PAN CARD', c.panPhotoUrl!),
                                if (c.chequePhotoUrl != null) ('SEC CHEQUE', c.chequePhotoUrl!),
                              ],
                            );
                          }(),
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
              uploadRoute: '/customers/bulk-import',
              token: Provider.of<AuthProvider>(context, listen: false).token,
              onSuccess: provider.fetchCustomers,
            ),
            onExport: () => _exportCustomersToExcel(context, provider),
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
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -0.5), overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _buildTable(List<Customer> items) {
    const headerColor = Color(0xFF64748B);
    const headerBg = Color(0xFFF1F5F9);
    const divider = Color(0xFFE2E8F0);
    const rowDivider = Color(0xFFE8EDF2);

    // Scrollable columns: label, width
    final scrollCols = [
      ('CUST ID', 100.0),
      ('SALES MGR', 130.0),
      ('STATUS', 80.0),
      ('CHANNEL', 95.0),
      ('CLASS', 65.0),
      ('CREDIT LIMIT', 110.0),
      ('CREDIT DAYS', 95.0),
      ('O/S BALANCE', 110.0),
      ('OD AMT', 95.0),
      ('LOCATION', 110.0),
      ('POSTAL CODE', 100.0),
      ('EMAIL ID', 180.0),
      ('ADDRESS', 200.0),
    ];

    Widget frozenCell(String text, {bool isHeader = false}) => Container(
      width: 160,
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
      child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: isHeader ? 9 : 11,
          fontWeight: isHeader ? FontWeight.w700 : FontWeight.w700,
          color: isHeader ? headerColor : const Color(0xFF0F172A),
          letterSpacing: isHeader ? 0.6 : 0,
        ),
      ),
    );

    Widget scrollCell(String text, double width, {bool isHeader = false, Color? textColor, Widget? child}) => Container(
      width: width,
      height: 50,
      decoration: BoxDecoration(
        color: isHeader ? headerBg : Colors.white,
        border: Border(
          right: const BorderSide(color: divider, width: 1),
          bottom: BorderSide(color: rowDivider, width: 1),
        ),
      ),
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: child ?? Text(text, maxLines: 1, overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: isHeader ? 9 : 11,
          fontWeight: isHeader ? FontWeight.w700 : FontWeight.w500,
          color: textColor ?? (isHeader ? headerColor : const Color(0xFF1E293B)),
          letterSpacing: isHeader ? 0.6 : 0,
        ),
      ),
    );

    Widget statusBadge(String status) {
      Color bg = const Color(0xFFDCFCE7);
      Color fg = const Color(0xFF166534);
      if (status == 'Inactive') { bg = const Color(0xFFFEF3C7); fg = const Color(0xFF92400E); }
      if (status == 'Blocked') { bg = const Color(0xFFFFE4E6); fg = const Color(0xFF9F1239); }
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
        child: Text(status, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: fg)),
      );
    }

    // Header row OUTSIDE scroll views (truly sticky)
    final headerRow = Row(
      children: [
        frozenCell('CUSTOMER NAME', isHeader: true),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            controller: _hHeader,
            // Removed NeverScrollableScrollPhysics so user can swipe header too
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
              // Frozen name column (synced vertical scroll)
              SingleChildScrollView(
                controller: _vFrozen,
                child: Column(
                  children: items.map((c) => GestureDetector(
                    onTap: () => setState(() =>
                        _selectedCustomer = (_selectedCustomer?.id == c.id) ? null : c),
                    child: Container(
                      color: _selectedCustomer?.id == c.id ? const Color(0xFFEEF2FF) : Colors.transparent,
                      child: frozenCell(c.name),
                    ),
                  )).toList(),
                ),
              ),
              // Scrollable body (horizontal + synced vertical)
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  controller: _hBody,
                  child: SingleChildScrollView(
                    controller: _vBody,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: items.map((c) => GestureDetector(
                        onTap: () => setState(() =>
                            _selectedCustomer = (_selectedCustomer?.id == c.id) ? null : c),
                        child: Container(
                          color: _selectedCustomer?.id == c.id ? const Color(0xFFEEF2FF) : Colors.transparent,
                          child: Row(
                            children: [
                              scrollCell(c.id, scrollCols[0].$2, textColor: NexusTheme.indigo600),
                              scrollCell(c.salesManager ?? '-', scrollCols[1].$2),
                              scrollCell(c.status, scrollCols[2].$2, child: statusBadge(c.status)),
                              scrollCell(c.distributionChannel ?? '-', scrollCols[3].$2),
                              scrollCell(c.customerClass ?? '-', scrollCols[4].$2),
                              scrollCell('₹${NumberFormat('#,##,###').format(c.limit)}', scrollCols[5].$2, textColor: const Color(0xFF059669)),
                              scrollCell('${c.exposureDays} days', scrollCols[6].$2),
                              scrollCell('₹${NumberFormat('#,##,###').format(c.osBalance)}', scrollCols[7].$2, textColor: c.osBalance > c.limit ? Colors.redAccent : null),
                              scrollCell('₹${NumberFormat('#,##,###').format(c.odAmt)}', scrollCols[8].$2, textColor: c.odAmt > 0 ? Colors.redAccent : null),
                              scrollCell(c.location ?? '-', scrollCols[9].$2),
                              scrollCell(c.postalCode ?? '-', scrollCols[10].$2),
                              scrollCell(c.customerEmail ?? '-', scrollCols[11].$2),
                              scrollCell(c.address, scrollCols[12].$2),
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

  // ───────────────────────── ADD NEW CUSTOMER DIALOG ─────────────────────────
  void _showAddDialog(BuildContext context, NexusProvider provider) {
    final formKey = GlobalKey<FormState>();
    final name    = TextEditingController();
    final id      = TextEditingController();
    final channel = TextEditingController();
    final limit   = TextEditingController(text: '0');
    final address = TextEditingController();
    final email   = TextEditingController();
    final postal  = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Add New Customer', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        content: SizedBox(
          width: 380,
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _field('Customer Name *', name, required: true),
                  _field('Customer ID *', id, required: true),
                  _field('Distribution Channel', channel),
                  _field('Credit Limit (₹)', limit, numeric: true),
                  _field('Address', address),
                  _field('Email', email),
                  _field('Postal Code', postal),
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
                route: '/customers',
                token: Provider.of<AuthProvider>(context, listen: false).token,
                data: {
                  'name': name.text.trim(),
                  'id': id.text.trim(),
                  'distributionChannel': channel.text.trim(),
                  'limit': double.tryParse(limit.text) ?? 0,
                  'address': address.text.trim(),
                  'customerEmail': email.text.trim(),
                  'postalCode': postal.text.trim(),
                  'status': 'Active',
                },
              );
              if (ok && ctx.mounted) {
                Navigator.pop(ctx);
                MasterActions.showSuccess(context, 'Customer created successfully');
                provider.fetchCustomers();
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

  Future<void> _exportCustomersToExcel(BuildContext context, NexusProvider provider) async {
    final customers = provider.customers;
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('📊 Preparing Excel export...'), backgroundColor: NexusTheme.indigo500, behavior: SnackBarBehavior.floating),
    );

    try {
      final excel = xl.Excel.createExcel();
      // Rename default sheet to 'OD Master'
      excel.rename('Sheet1', 'OD Master');
      final sheet = excel['OD Master'];

      final headers = [
        'Customer ID', 'Dist', 'Sales Manager', 'Class', 'Employee respons.', 
        'Customer Names', 'Credit Days', 'Credit Limit', 'Security Chq', 'Dist Channel',
        'O/s Amt', 'OD Amt', 'Diffn btw ydy & tday', '0 to 7', '7 to 15', '15 to 30', 
        '30 to 45', '45 to 90', '90 to 120', '120 to 150', '150 to 180', '>180'
      ];
      sheet.appendRow(headers.map((h) => xl.TextCellValue(h)).toList());

      for (final c in customers) {
        final ag = c.agingData;
        sheet.appendRow([
          xl.TextCellValue(c.id),                             // Customer ID
          xl.TextCellValue(c.location ?? ''),                 // Dist
          xl.TextCellValue(c.salesManager ?? ''),             // Sales Manager
          xl.TextCellValue(c.customerClass ?? ''),            // Class
          xl.TextCellValue(c.employeeResponsible ?? ''),      // Employee respons.
          xl.TextCellValue(c.name),                           // Customer Names
          xl.TextCellValue('${c.exposureDays} days'),         // Credit Days
          xl.DoubleCellValue(c.limit),                        // Credit Limit
          xl.TextCellValue(c.securityChq),                    // Security Chq
          xl.TextCellValue(c.distributionChannel ?? ''),      // Dist Channel
          xl.DoubleCellValue(c.osBalance),                    // O/s Amt
          xl.DoubleCellValue(c.odAmt),                        // OD Amt
          xl.DoubleCellValue(c.diffYesterdayToday),           // Diffn btw ydy & tday
          xl.DoubleCellValue((ag['0to7'] ?? ag['0 to 7'] ?? 0).toDouble()),
          xl.DoubleCellValue((ag['7to15'] ?? ag['7 to 15'] ?? 0).toDouble()),
          xl.DoubleCellValue((ag['15to30'] ?? ag['15 to 30'] ?? 0).toDouble()),
          xl.DoubleCellValue((ag['30to45'] ?? ag['30 to 45'] ?? 0).toDouble()),
          xl.DoubleCellValue((ag['45to90'] ?? ag['45 to 90'] ?? 0).toDouble()),
          xl.DoubleCellValue((ag['90to120'] ?? ag['90 to 120'] ?? 0).toDouble()),
          xl.DoubleCellValue((ag['120to150'] ?? ag['120 to 150'] ?? 0).toDouble()),
          xl.DoubleCellValue((ag['150to180'] ?? ag['150 to 180'] ?? 0).toDouble()),
          xl.DoubleCellValue((ag['>180'] ?? ag['above180'] ?? 0).toDouble()),
        ]);
      }


      final dir = await getExternalStorageDirectory();
      final filePath = '${dir!.path}/OD_Master_Export_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      final fileBytes = excel.encode();
      if (fileBytes != null) {
        await File(filePath).writeAsBytes(fileBytes);
        await OpenFile.open(filePath);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Exported ${customers.length} OD Master records!'),
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
