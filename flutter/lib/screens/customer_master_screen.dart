import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/nexus_provider.dart';
import '../utils/theme.dart';
import '../models/models.dart';

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

  @override
  void dispose() {
    _searchController.dispose();
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
                      Expanded(child: _buildTable(pageItems)),
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

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Frozen: Customer Name
        SingleChildScrollView(
          child: Column(
            children: [
              frozenCell('CUSTOMER NAME', isHeader: true),
              ...items.map((c) => frozenCell(c.name)),
            ],
          ),
        ),
        // Scrollable
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: scrollCols.map((c) => scrollCell(c.$1, c.$2, isHeader: true)).toList()),
                  ...items.map((c) => Row(
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
