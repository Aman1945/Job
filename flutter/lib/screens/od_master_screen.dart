import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:excel/excel.dart' as xl;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import '../providers/nexus_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/theme.dart';
import '../utils/master_actions.dart';
import '../models/models.dart';
import '../widgets/row_detail_panel.dart';

class OdMasterScreen extends StatefulWidget {
  const OdMasterScreen({super.key});

  @override
  State<OdMasterScreen> createState() => _OdMasterScreenState();
}

class _OdMasterScreenState extends State<OdMasterScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'ALL';
  int _currentPage = 0;
  static const int _pageSize = 15;
  String _lastRefreshed = "-";
  Customer? _selectedCustomer;

  // Scroll controllers — frozen column + horizontal sync
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

  // Show ALL customers in OD Master (like Customer Master shows all)
  // Use filter chips to narrow by risk level
  List<Customer> _getOdCustomers(List<Customer> all) => all;
  // For export/print: only customers with actual OD/OS exposure
  List<Customer> _getOdOnly(List<Customer> all) =>
      all.where((c) => c.odAmt > 0 || c.osBalance > 0).toList();

  @override
  Widget build(BuildContext context) {
    final provider   = Provider.of<NexusProvider>(context);
    final authProv   = Provider.of<AuthProvider>(context, listen: false);
    final allCustomers = provider.customers;
    final allOd = allCustomers; // all customers shown in table
    final fmt        = NumberFormat('#,##,###');

    // Filter chips — risk levels based on OD amount
    final filters = ['ALL', 'HIGH RISK', 'MEDIUM', 'LOW', 'NO OD'];

    final filtered = allOd.where((c) {
      final matchSearch = _searchQuery.isEmpty ||
          c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.id.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (c.location?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      final matchFilter = _selectedFilter == 'ALL' ||
          (_selectedFilter == 'HIGH RISK'  && c.odAmt > 100000) ||
          (_selectedFilter == 'MEDIUM'     && c.odAmt > 30000 && c.odAmt <= 100000) ||
          (_selectedFilter == 'LOW'        && c.odAmt > 0 && c.odAmt <= 30000) ||
          (_selectedFilter == 'NO OD'      && c.odAmt == 0 && c.osBalance == 0);
      return matchSearch && matchFilter;
    }).toList();

    final totalPages = filtered.isEmpty ? 1 : (filtered.length / _pageSize).ceil();
    final start      = _currentPage * _pageSize;
    final end        = (start + _pageSize).clamp(0, filtered.length);
    final pageItems  = filtered.isEmpty ? <Customer>[] : filtered.sublist(start, end);

    // Stats — sum across all customers
    final totalOsAmt  = allCustomers.fold(0.0, (s, c) => s + c.osBalance);
    final totalOdAmt  = allCustomers.fold(0.0, (s, c) => s + c.odAmt);
    final odCount     = allCustomers.where((c) => c.odAmt > 0 || c.osBalance > 0).length;

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
          'OD MASTER',
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
                    _metricCard('OD ACCOUNTS', odCount.toString(), const Color(0xFF6366F1), Icons.account_balance_outlined),
                    const SizedBox(width: 10),
                    _metricCard('O/S AMOUNT', '₹${fmt.format(totalOsAmt.toInt())}', Colors.orange, Icons.receipt_long_outlined),
                    const SizedBox(width: 10),
                    _metricCard('OD EXPOSURE', '₹${fmt.format(totalOdAmt.toInt())}', Colors.redAccent, Icons.warning_amber_outlined),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Showing ${allOd.length} total customers · Updated: $_lastRefreshed',
                      style: TextStyle(color: Colors.slate.shade500, fontSize: 11, fontWeight: FontWeight.w500),
                    ),
                    InkWell(
                      onTap: () async {
                        setState(() => _lastRefreshed = "Updating...");
                        await provider.fetchCustomers();
                        if (mounted) {
                          setState(() => _lastRefreshed = DateFormat('HH:mm:ss').format(DateTime.now()));
                        }
                      },
                      child: const Row(children: [
                        Icon(Icons.refresh, size: 14, color: NexusTheme.indigo600),
                        SizedBox(width: 4),
                        Text('REFRESH DATA', style: TextStyle(color: NexusTheme.indigo600, fontSize: 11, fontWeight: FontWeight.w800)),
                      ]),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Showing ${allOd.length} total customers · Updated: $_lastRefreshed',
                      style: TextStyle(color: Colors.slate.shade500, fontSize: 11, fontWeight: FontWeight.w500),
                    ),
                    InkWell(
                      onTap: () async {
                        setState(() => _lastRefreshed = "Updating...");
                        await provider.fetchCustomers();
                        if (mounted) {
                          setState(() => _lastRefreshed = DateFormat('HH:mm:ss').format(DateTime.now()));
                        }
                      },
                      child: const Row(children: [
                        Icon(Icons.refresh, size: 14, color: NexusTheme.indigo600),
                        SizedBox(width: 4),
                        Text('REFRESH DATA', style: TextStyle(color: NexusTheme.indigo600, fontSize: 11, fontWeight: FontWeight.w800)),
                      ]),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Search bar
                TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() { _searchQuery = v; _currentPage = 0; }),
                  decoration: InputDecoration(
                    hintText: 'Search by Customer Name, ID, Location...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    filled: true,
                    fillColor: NexusTheme.slate50,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                const SizedBox(height: 12),
                // Risk filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: filters.map((f) {
                      final isSelected = _selectedFilter == f;
                      Color chipColor = const Color(0xFF0F172A);
                      if (f == 'HIGH RISK') chipColor = Colors.redAccent;
                      if (f == 'MEDIUM')    chipColor = Colors.orange;
                      if (f == 'LOW')       chipColor = NexusTheme.emerald500;
                      if (f == 'NO OD')     chipColor = const Color(0xFF94A3B8);
                      return GestureDetector(
                        onTap: () => setState(() { _selectedFilter = f; _currentPage = 0; }),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: isSelected ? chipColor : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: isSelected ? chipColor : const Color(0xFFE2E8F0)),
                          ),
                          child: Text(f, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: isSelected ? Colors.white : const Color(0xFF64748B))),
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
                              Icon(Icons.account_balance_outlined, size: 60, color: Color(0xFFCBD5E1)),
                              SizedBox(height: 16),
                              Text('NO OD ACCOUNTS FOUND', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF94A3B8), letterSpacing: 1)),
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
                            final c = _selectedCustomer!;
                            final ag = c.agingData;
                            return RowDetailPanel(
                              title: c.name,
                              icon: Icons.account_balance,
                              accentColor: const Color(0xFF6366F1),
                              onClose: () => setState(() => _selectedCustomer = null),
                              fields: [
                                ('Customer ID', c.id),
                                ('Location / Dist', c.location ?? '-'),
                                ('Class', c.customerClass ?? '-'),
                                ('Sales Manager', c.salesManager ?? '-'),
                                ('Credit Days', '${c.exposureDays} days'),
                                ('Credit Limit', '₹${fmt.format(c.limit.toInt())}'),
                                ('Security Chq', c.securityChq),
                                ('O/s Balance', '₹${fmt.format(c.osBalance.toInt())}'),
                                ('OD Amount', '₹${fmt.format(c.odAmt.toInt())}'),
                                ('Ageing 0-7',    '₹${fmt.format((ag['0to7']   ?? ag['0 to 7']   ?? 0))}'),
                                ('Ageing 7-15',   '₹${fmt.format((ag['7to15']  ?? ag['7 to 15']  ?? 0))}'),
                                ('Ageing 15-30',  '₹${fmt.format((ag['15to30'] ?? ag['15 to 30'] ?? 0))}'),
                                ('Ageing 30-45',  '₹${fmt.format((ag['30to45'] ?? ag['30 to 45'] ?? 0))}'),
                                ('Ageing 45-90',  '₹${fmt.format((ag['45to90'] ?? ag['45 to 90'] ?? 0))}'),
                                ('Ageing 90-120', '₹${fmt.format((ag['90to120'] ?? ag['90 to 120'] ?? 0))}'),
                                ('Ageing 120-150','₹${fmt.format((ag['120to150'] ?? ag['120 to 150'] ?? 0))}'),
                                ('Ageing 150-180','₹${fmt.format((ag['150to180'] ?? ag['150 to 180'] ?? 0))}'),
                                ('Ageing >180',   '₹${fmt.format((ag['>180'] ?? ag['above180'] ?? 0))}'),
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

          // ── Bottom action bar ──
          _buildActionBar(context, provider, authProv),
        ],
      ),
    );
  }

  // ─────────────────────────── METRIC CARD ───────────────────────────
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
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -0.5), overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────── TABLE ───────────────────────────
  Widget _buildTable(List<Customer> items) {
    const headerColor = Color(0xFF64748B);
    const headerBg    = Color(0xFFF1F5F9);
    const divider     = Color(0xFFE2E8F0);
    const rowDivider  = Color(0xFFE8EDF2);

    final scrollCols = [
      ('DIST',      90.0),
      ('CLASS',     70.0),
      ('CR.DAYS',   75.0),
      ('CR.LIMIT',  110.0),
      ('SEC CHQ',   80.0),
      ('O/S AMT',   110.0),
      ('OD AMT',    110.0),
      ('0-7',       65.0),
      ('7-15',      65.0),
      ('15-30',     65.0),
      ('30-45',     65.0),
      ('45-90',     70.0),
      ('90-120',    75.0),
      ('120-150',   80.0),
      ('150-180',   80.0),
      ('>180',      65.0),
    ];

    Widget frozenCell(String text, {bool isHeader = false, bool isSelected = false}) => Container(
      width: 150,
      height: 50,
      decoration: BoxDecoration(
        color: isHeader ? headerBg : (isSelected ? const Color(0xFFEEF2FF) : Colors.white),
        border: Border(
          right: const BorderSide(color: divider, width: 1),
          bottom: const BorderSide(color: rowDivider, width: 1),
        ),
      ),
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: isHeader ? 9 : 11,
          fontWeight: FontWeight.w700,
          color: isHeader ? headerColor : const Color(0xFF0F172A),
          letterSpacing: isHeader ? 0.6 : 0,
        ),
      ),
    );

    Widget cell(String text, double width, {bool isHeader = false, Color? textColor, bool isSelected = false}) => Container(
      width: width,
      height: 50,
      decoration: BoxDecoration(
        color: isHeader ? headerBg : (isSelected ? const Color(0xFFEEF2FF) : Colors.white),
        border: Border(
          right: const BorderSide(color: divider, width: 1),
          bottom: const BorderSide(color: rowDivider, width: 1),
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

    final fmt = NumberFormat('#,##,###');

    final headerRow = Row(
      children: [
        frozenCell('CUSTOMER NAME', isHeader: true),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            controller: _hHeader,
            child: Row(
              children: scrollCols.map((c) => cell(c.$1, c.$2, isHeader: true)).toList(),
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
              // Frozen column
              SingleChildScrollView(
                controller: _vFrozen,
                child: Column(
                  children: items.map((c) => GestureDetector(
                    onTap: () => setState(() =>
                        _selectedCustomer = (_selectedCustomer?.id == c.id) ? null : c),
                    child: frozenCell(c.name, isSelected: _selectedCustomer?.id == c.id),
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
                      children: items.map((c) {
                        final ag  = c.agingData;
                        final sel = _selectedCustomer?.id == c.id;
                        final vals = [
                          c.location ?? '-',
                          c.customerClass ?? '-',
                          '${c.exposureDays}d',
                          '₹${fmt.format(c.limit.toInt())}',
                          c.securityChq,
                          '₹${fmt.format(c.osBalance.toInt())}',
                          '₹${fmt.format(c.odAmt.toInt())}',
                          (ag['0to7']   ?? ag['0 to 7']   ?? 0).toString(),
                          (ag['7to15']  ?? ag['7 to 15']  ?? 0).toString(),
                          (ag['15to30'] ?? ag['15 to 30'] ?? 0).toString(),
                          (ag['30to45'] ?? ag['30 to 45'] ?? 0).toString(),
                          (ag['45to90'] ?? ag['45 to 90'] ?? 0).toString(),
                          (ag['90to120'] ?? ag['90 to 120'] ?? 0).toString(),
                          (ag['120to150'] ?? ag['120 to 150'] ?? 0).toString(),
                          (ag['150to180'] ?? ag['150 to 180'] ?? 0).toString(),
                          (ag['>180'] ?? ag['above180'] ?? 0).toString(),
                        ];
                        return GestureDetector(
                          onTap: () => setState(() =>
                              _selectedCustomer = (_selectedCustomer?.id == c.id) ? null : c),
                          child: Row(
                            children: List.generate(scrollCols.length, (i) {
                              Color? textColor;
                              if (i == 5 && c.osBalance > c.limit) textColor = Colors.redAccent; // O/s over limit
                              if (i == 6 && c.odAmt > 0)            textColor = Colors.redAccent; // OD amount
                              return cell(vals[i], scrollCols[i].$2, textColor: textColor, isSelected: sel);
                            }),
                          ),
                        );
                      }).toList(),
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

  // ─────────────────────────── PAGINATION ───────────────────────────
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
              _pageBtn(icon: Icons.chevron_left,  enabled: _currentPage > 0,                onTap: () => setState(() => _currentPage--)),
              const SizedBox(width: 8),
              Text('${_currentPage + 1} / $totalPages', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF334155))),
              const SizedBox(width: 8),
              _pageBtn(icon: Icons.chevron_right, enabled: _currentPage < totalPages - 1, onTap: () => setState(() => _currentPage++)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pageBtn({required IconData icon, required bool enabled, required VoidCallback onTap}) {
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

  // ─────────────────────────── ACTION BAR ───────────────────────────
  Widget _buildActionBar(BuildContext context, NexusProvider provider, AuthProvider authProv) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          _aBtn(label: 'IMPORT',   color: const Color(0xFF0369A1), icon: Icons.upload_file_outlined, onTap: () =>
            MasterActions.importExcel(
              context: context,
              uploadRoute: '/customers/bulk-import',
              token: authProv.token,
              onSuccess: provider.fetchCustomers,
            )),
          const SizedBox(width: 8),
          _aBtn(label: 'EXPORT',   color: const Color(0xFF7C3AED), icon: Icons.table_chart_outlined, onTap: () =>
            _exportToExcel(context, provider)),
        ],
      ),
    );
  }

  Widget _aBtn({required String label, required Color color, required IconData icon, required VoidCallback onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: Colors.white),
              const SizedBox(height: 3),
              Text(label, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5)),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────── EXPORT ───────────────────────────
  Future<void> _exportToExcel(BuildContext context, NexusProvider provider) async {
    // Export only customers with actual OD/OS exposure
    final odCustomers = _getOdOnly(provider.customers);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('📊 Preparing OD Master export...'), backgroundColor: NexusTheme.indigo500, behavior: SnackBarBehavior.floating),
    );

    try {
      final excel = xl.Excel.createExcel();
      excel.rename('Sheet1', 'OD Master');
      final sheet = excel['OD Master'];

      final headers = [
        'Customer ID', 'Customer Name', 'Dist', 'Sales Manager', 'Class',
        'Employee Respons.', 'Credit Days', 'Credit Limit', 'Security Chq',
        'Dist Channel', 'O/s Amt', 'OD Amt', 'Diffn btw ydy & tday',
        '0 to 7', '7 to 15', '15 to 30', '30 to 45', '45 to 90',
        '90 to 120', '120 to 150', '150 to 180', '>180'
      ];
      sheet.appendRow(headers.map((h) => xl.TextCellValue(h)).toList());

      for (final c in odCustomers) {
        final ag = c.agingData;
        sheet.appendRow([
          xl.TextCellValue(c.id),
          xl.TextCellValue(c.name),
          xl.TextCellValue(c.location ?? ''),
          xl.TextCellValue(c.salesManager ?? ''),
          xl.TextCellValue(c.customerClass ?? ''),
          xl.TextCellValue(c.employeeResponsible ?? ''),
          xl.IntCellValue(c.exposureDays),
          xl.DoubleCellValue(c.limit),
          xl.TextCellValue(c.securityChq),
          xl.TextCellValue(c.distributionChannel ?? ''),
          xl.DoubleCellValue(c.osBalance),
          xl.DoubleCellValue(c.odAmt),
          xl.DoubleCellValue(c.diffYesterdayToday),
          xl.DoubleCellValue((ag['0to7']   ?? ag['0 to 7']   ?? 0).toDouble()),
          xl.DoubleCellValue((ag['7to15']  ?? ag['7 to 15']  ?? 0).toDouble()),
          xl.DoubleCellValue((ag['15to30'] ?? ag['15 to 30'] ?? 0).toDouble()),
          xl.DoubleCellValue((ag['30to45'] ?? ag['30 to 45'] ?? 0).toDouble()),
          xl.DoubleCellValue((ag['45to90'] ?? ag['45 to 90'] ?? 0).toDouble()),
          xl.DoubleCellValue((ag['90to120'] ?? ag['90 to 120'] ?? 0).toDouble()),
          xl.DoubleCellValue((ag['120to150'] ?? ag['120 to 150'] ?? 0).toDouble()),
          xl.DoubleCellValue((ag['150to180'] ?? ag['150 to 180'] ?? 0).toDouble()),
          xl.DoubleCellValue((ag['>180'] ?? ag['above180'] ?? 0).toDouble()),
        ]);
      }

      final dir      = await getExternalStorageDirectory();
      final filePath = '${dir!.path}/OD_Master_Export_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      final fileBytes = excel.encode();
      if (fileBytes != null) {
        await File(filePath).writeAsBytes(fileBytes);
        await OpenFile.open(filePath);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('✅ Exported ${odCustomers.length} OD accounts!'), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating),
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

  // ─────────────────────────── PRINT REPORT ───────────────────────────
  Future<void> _printReport(BuildContext context, NexusProvider provider) async {
    final odCustomers = _getOdOnly(provider.customers);
    if (odCustomers.isEmpty) {
      MasterActions.showError(context, 'No OD accounts to print.');
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('🖨️ Preparing OD Report...'), backgroundColor: NexusTheme.indigo500, behavior: SnackBarBehavior.floating),
    );

    try {
      final fmt = NumberFormat('#,##,###');
      final buf = StringBuffer();
      buf.writeln('═══════════════════════════════════════════════════');
      buf.writeln('              OD MASTER REPORT');
      buf.writeln('   Generated: ${DateTime.now().toLocal()}');
      buf.writeln('═══════════════════════════════════════════════════');
      buf.writeln('');
      buf.writeln('${'CUSTOMER'.padRight(32)}${'DIST'.padRight(14)}${'CR.DAYS'.padLeft(8)}${'CR.LIMIT'.padLeft(14)}${'O/S AMT'.padLeft(14)}${'OD AMT'.padLeft(14)}');
      buf.writeln('─' * 96);
      for (final c in odCustomers) {
        buf.writeln(
          '${c.name.padRight(32)}${(c.location ?? '-').padRight(14)}'
          '${c.exposureDays.toString().padLeft(8)}'
          '${fmt.format(c.limit.toInt()).padLeft(14)}'
          '${fmt.format(c.osBalance.toInt()).padLeft(14)}'
          '${fmt.format(c.odAmt.toInt()).padLeft(14)}',
        );
      }
      buf.writeln('─' * 96);
      buf.writeln('Total OD Accounts : ${odCustomers.length}');
      buf.writeln('Total O/s Amount  : ₹${fmt.format(odCustomers.fold(0.0, (s, c) => s + c.osBalance).toInt())}');
      buf.writeln('Total OD Exposure : ₹${fmt.format(odCustomers.fold(0.0, (s, c) => s + c.odAmt).toInt())}');
      buf.writeln('═' * 96);

      final dir      = await getExternalStorageDirectory();
      final filePath = '${dir!.path}/OD_Report_${DateTime.now().millisecondsSinceEpoch}.txt';
      await File(filePath).writeAsString(buf.toString());
      await OpenFile.open(filePath);

      if (context.mounted) {
        MasterActions.showSuccess(context, '🖨️ OD Report ready — ${odCustomers.length} accounts');
      }
    } catch (e) {
      if (context.mounted) {
        MasterActions.showError(context, 'Print failed: $e');
      }
    }
  }
}
