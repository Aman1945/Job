import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/nexus_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/theme.dart';
import '../models/models.dart';
import '../widgets/nexus_components.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:excel/excel.dart' as xl;

class MasterDataScreen extends StatefulWidget {
  const MasterDataScreen({super.key});

  @override
  State<MasterDataScreen> createState() => _MasterDataScreenState();
}

class _MasterDataScreenState extends State<MasterDataScreen> {
  String _selectedTab = 'USER MASTER';
  bool _isLoading = false;
  late AuthProvider authProvider;
  late NexusProvider provider;

  // Pagination
  int _currentPage = 0;
  static const int _pageSize = 10;

  @override
  Widget build(BuildContext context) {
    provider = Provider.of<NexusProvider>(context);
    authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      backgroundColor: NexusTheme.slate50,
      appBar: AppBar(
        title: const Text(
          'MASTER TERMINAL',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: NexusTheme.slate400),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildTerminalToggle('USER MASTER'),
                _buildTerminalToggle('CUSTOMER MASTER'),
                _buildTerminalToggle('MATERIAL MASTER'),
                _buildTerminalToggle('DELIVERY PERSON'),
                _buildTerminalToggle('OD MASTER'),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedTab
                        .split(' ')
                        .map((s) => s[0] + s.substring(1).toLowerCase())
                        .join(' '),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 28,
                      color: NexusTheme.slate900,
                    ),
                  ),
                  const Text(
                    'ENTERPRISE MASTER REGISTRY & DATA MANAGEMENT TERMINAL',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      color: NexusTheme.slate400,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Intelligence-style Metric Cards
                  _buildMasterMetricsGrid(),

                  const SizedBox(height: 24),

                   Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildActionButton(
                        icon: Icons.add,
                        label: 'ADD NEW ${_selectedTab.replaceAll(' MASTER', '')}',
                        onTap: () => _showMasterForm(context),
                        isPrimary: true,
                        fullWidth: true,
                      ),
                      if (_selectedTab == 'CUSTOMER MASTER') ...[
                        const SizedBox(height: 12),
                        _buildActionButton(
                          icon: Icons.upload_file,
                          label: 'IMPORT EXCEL DATA',
                          onTap: () => _handleBulkImport(context),
                          isPrimary: true,
                          fullWidth: true,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildActionButton(
                                icon: Icons.description_outlined,
                                label: 'DOWNLOAD FORMAT',
                                onTap: () async {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('📥 Download starting...'),
                                      backgroundColor: NexusTheme.indigo500,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                  await provider.downloadCustomerTemplate();
                                },
                                isPrimary: false,
                                fullWidth: true,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildActionButton(
                                icon: Icons.download_rounded,
                                label: 'EXPORT EXCEL',
                                onTap: () => _exportCustomersToExcel(context),
                                isPrimary: false,
                                fullWidth: true,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Data Table Card (Restored to Image 1 Style)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(60),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 40,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(60),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 48),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 56),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Text(
                              'ID',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF94A3B8),
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              'NAME',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF94A3B8),
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(48, 16, 48, 0),
                      child: Divider(color: Color(0xFFF1F5F9), height: 1),
                    ),
                    _buildDataTable(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMasterMetricsGrid() {
    final provider = Provider.of<NexusProvider>(context);
    String totalCount = '0';
    String activeLabel = 'ACTIVE';
    String statusValue = '100%';
    IconData metricIcon = Icons.people;

    if (_selectedTab == 'USER MASTER') {
      totalCount = provider.users.length.toString();
      metricIcon = Icons.people;
    } else if (_selectedTab == 'CUSTOMER MASTER') {
      totalCount = provider.customers.length.toString();
      metricIcon = Icons.business;
    } else if (_selectedTab == 'MATERIAL MASTER') {
      totalCount = provider.products.length.toString();
      metricIcon = Icons.inventory_2;
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.55,
      children: [
        _buildMetricCard(
          'TOTAL ENTRIES',
          totalCount,
          'Registered in system',
          NexusTheme.indigo500,
          NexusTheme.blue900,
          icon: metricIcon,
        ),
        _buildMetricCard(
          'SYSTEM UPTIME',
          '99.9%',
          'Infrastructure health',
          NexusTheme.emerald500,
          NexusTheme.emerald900,
          icon: Icons.bolt,
        ),
        _buildMetricCard(
          'DATA SYNC',
          'LIVE',
          'Real-time database',
          Colors.orange,
          NexusTheme.amber900,
          icon: Icons.sync,
        ),
        _buildMetricCard(
          'SECURITY',
          'ENCRYPTED',
          'AES-256 standard',
          NexusTheme.slate500,
          NexusTheme.slate900,
          icon: Icons.security,
        ),
      ],
    );
  }

  Widget _buildTerminalToggle(String title) {
    bool isSelected = _selectedTab == title;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = title),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? NexusTheme.indigo500.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? NexusTheme.indigo500.withOpacity(0.2)
                : Colors.transparent,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: isSelected ? NexusTheme.indigo600 : NexusTheme.slate400,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    String subtitle,
    Color color,
    Color accentColor, {
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border(left: BorderSide(color: color, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    color: NexusTheme.slate400,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              if (icon != null)
                Icon(icon, size: 14, color: NexusTheme.slate200),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: NexusTheme.slate900,
                    letterSpacing: -1,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: NexusTheme.slate400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionTab(String title, IconData icon) {
    bool isSelected = _selectedTab == title;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = title),
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF5850EC) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : const Color(0xFF64748B),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: isSelected ? Colors.white : const Color(0xFF64748B),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isPrimary,
    bool fullWidth = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: fullWidth ? double.infinity : null,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: isPrimary ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: fullWidth ? MainAxisAlignment.center : MainAxisAlignment.start,
          mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isPrimary ? Colors.white : const Color(0xFF64748B),
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: isPrimary ? Colors.white : const Color(0xFF475569),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tableHeader(String label) => Text(
    label,
    style: const TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w900,
      color: Color(0xFF94A3B8),
      letterSpacing: 1.5,
    ),
  );

  Widget _buildDataTable() {
    final provider = Provider.of<NexusProvider>(context);

    // ── CUSTOMER MASTER: frozen column + horizontal scroll + pagination ──
    if (_selectedTab == 'CUSTOMER MASTER') {
      final customers = provider.customers;

      // Skeleton loading while data is being fetched
      if (customers.isEmpty && _isLoading) {
        return _buildSkeletonTable();
      }

      if (customers.isEmpty) {
        return const Padding(
          padding: EdgeInsets.all(48),
          child: Center(
            child: Text('NO CUSTOMERS FOUND',
                style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                    letterSpacing: 1)),
          ),
        );
      }

      final totalPages = (customers.length / _pageSize).ceil();
      final start = _currentPage * _pageSize;
      final end = (start + _pageSize).clamp(0, customers.length);
      final pageItems = customers.sublist(start, end);

      // Scrollable columns (Dist is now frozen)
      final cols = [
        ('Class', 70.0), ('Cr.Days', 65.0),
        ('Cr.Limit', 85.0), ('Sec.Chq', 75.0), ('O/s Amt', 85.0),
        ('OD Amt', 75.0), ('0-7', 60.0), ('7-15', 60.0),
        ('15-30', 60.0), ('30-45', 60.0), ('45-90', 65.0),
        ('90-120', 70.0), ('120-150', 75.0), ('150-180', 75.0), ('>180', 60.0),
      ];

      const _montserrat = 'Montserrat';
      const _headerColor = Color(0xFF64748B);
      const _headerBg = Color(0xFFF1F5F9);
      const _dividerColor = Color(0xFFE2E8F0);
      const _rowDivider = Color(0xFFE8EDF2);

      Widget buildCell(String text, double width, {bool isHeader = false, bool rightBorder = true}) =>
          Container(
            width: width,
            height: 48,
            decoration: BoxDecoration(
              color: isHeader ? _headerBg : Colors.white,
              border: Border(
                right: rightBorder
                    ? const BorderSide(color: _dividerColor, width: 1)
                    : BorderSide.none,
                bottom: const BorderSide(color: _rowDivider, width: 1),
              ),
            ),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: _montserrat,
                fontSize: isHeader ? 9 : 11,
                fontWeight: isHeader ? FontWeight.w700 : FontWeight.w500,
                color: isHeader ? _headerColor : const Color(0xFF1E293B),
                letterSpacing: isHeader ? 0.6 : 0,
              ),
            ),
          );

      Widget buildFrozenCell(String text, {bool isHeader = false, bool rightBorder = true}) =>
          Container(
            width: 130,
            height: 48,
            decoration: BoxDecoration(
              color: isHeader ? _headerBg : Colors.white,
              border: Border(
                right: rightBorder
                    ? const BorderSide(color: _dividerColor, width: 1)
                    : BorderSide.none,
                bottom: const BorderSide(color: _rowDivider, width: 1),
              ),
            ),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: _montserrat,
                fontSize: isHeader ? 9 : 11,
                fontWeight: isHeader ? FontWeight.w700 : FontWeight.w600,
                color: isHeader ? _headerColor : const Color(0xFF0F172A),
                letterSpacing: isHeader ? 0.6 : 0,
              ),
            ),
          );

      final scrollCtrl = ScrollController();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── TABLE ──
          SizedBox(
            height: (pageItems.length + 1) * 48.0 + 2,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // FROZEN: Customer Name column
                Column(
                  children: [
                    buildFrozenCell('CUSTOMER', isHeader: true),
                    ...pageItems.map((c) => buildFrozenCell(c.name)),
                  ],
                ),

                // FROZEN: Dist column (same 130px width)
                Column(
                  children: [
                    buildFrozenCell('DIST', isHeader: true),
                    ...pageItems.map((c) => buildFrozenCell(c.location ?? '-')),
                  ],
                ),

                // SCROLLABLE: rest of columns
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollCtrl,
                    scrollDirection: Axis.horizontal,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header row
                        Row(
                          children: cols
                              .map((c) => buildCell(c.$1, c.$2, isHeader: true))
                              .toList(),
                        ),
                        // Data rows
                        ...pageItems.map((c) {
                          final ag = c.agingData;
                          // Dist is now frozen, so skip it here
                          final vals = [
                            c.customerClass ?? '-',
                            c.exposureDays.toString(),
                            c.limit.toStringAsFixed(0),
                            c.securityChq,
                            c.osBalance.toStringAsFixed(0),
                            c.odAmt.toStringAsFixed(0),
                            (ag['0to7'] ?? ag['0 to 7'] ?? '').toString(),
                            (ag['7to15'] ?? ag['7 to 15'] ?? '').toString(),
                            (ag['15to30'] ?? ag['15 to 30'] ?? '').toString(),
                            (ag['30to45'] ?? ag['30 to 45'] ?? '').toString(),
                            (ag['45to90'] ?? ag['45 to 90'] ?? '').toString(),
                            (ag['90to120'] ?? ag['90 to 120'] ?? '').toString(),
                            (ag['120to150'] ?? ag['120 to 150'] ?? '').toString(),
                            (ag['150to180'] ?? ag['150 to 180'] ?? '').toString(),
                            (ag['>180'] ?? ag['above180'] ?? '').toString(),
                          ];
                          return Row(
                            children: List.generate(
                              cols.length,
                              (i) => buildCell(vals[i], cols[i].$2),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── PAGINATION ──
          Container(
            margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              border: Border(
                top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
              ),
            ),
            child: Column(
              children: [
                // Record count info
                Text(
                  'Showing ${start + 1}–$end of ${customers.length} records',
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 10,
                    color: Color(0xFF94A3B8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                // Page buttons — centered
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _paginationBtn(
                      icon: Icons.chevron_left,
                      enabled: _currentPage > 0,
                      onTap: () => setState(() => _currentPage--),
                    ),
                    const SizedBox(width: 6),
                    ...List.generate(totalPages, (i) {
                      // Show: first, last, current ±1, and ellipsis
                      final showPage = totalPages <= 7 ||
                          i == 0 ||
                          i == totalPages - 1 ||
                          (i - _currentPage).abs() <= 1;
                      final showEllipsis =
                          (i == 1 && _currentPage > 3) ||
                          (i == totalPages - 2 && _currentPage < totalPages - 4);

                      if (showPage) return _pageNumBtn(i, i == _currentPage);
                      if (showEllipsis) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: Text('···',
                              style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 13,
                                  color: Color(0xFF94A3B8),
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2)),
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                    const SizedBox(width: 6),
                    _paginationBtn(
                      icon: Icons.chevron_right,
                      enabled: _currentPage < totalPages - 1,
                      onTap: () => setState(() => _currentPage++),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      );
    }

    // ── OTHER TABS: simple list ──
    List<dynamic> items = [];
    if (_selectedTab == 'USER MASTER') items = provider.users;
    else if (_selectedTab == 'MATERIAL MASTER') items = provider.products;

    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: Text(
            'NO DATA IN $_selectedTab',
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontWeight: FontWeight.w900,
              fontSize: 10,
              letterSpacing: 1,
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(48, 24, 48, 48),
      itemCount: items.length,
      separatorBuilder: (_, __) =>
          const Divider(color: Color(0xFFF8FAFC), height: 1),
      itemBuilder: (context, index) {
        final item = items[index];
        String id = '';
        String name = '';
        if (item is User) { id = item.id; name = item.name; }
        else if (item is Product) { id = item.id; name = item.name; }

        return InkWell(
          onTap: () => _showMasterForm(context, initialData: item),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
            child: Row(
              children: [
                Expanded(flex: 1, child: Text(id,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF64748B)))),
                Expanded(flex: 3, child: Text(name,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)))),
              ],
            ),
          ),
        );
      },
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
        child: Icon(icon, size: 18,
            color: enabled ? Colors.white : const Color(0xFFCBD5E1)),
      ),
    );
  }

  Widget _pageNumBtn(int page, bool isActive) {
    return GestureDetector(
      onTap: () => setState(() => _currentPage = page),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        width: 32, height: 32,
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text('${page + 1}',
              style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: isActive ? Colors.white : const Color(0xFF64748B))),
        ),
      ),
    );
  }

  Widget _buildSkeletonTable() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.4, end: 1.0),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeInOut,
      builder: (context, opacity, _) {
        return Column(
          children: List.generate(10, (rowIndex) {
            return Container(
              height: 48,
              decoration: BoxDecoration(
                border: const Border(
                  bottom: BorderSide(color: Color(0xFFE8EDF2), width: 1),
                ),
                color: rowIndex.isEven
                    ? Colors.white
                    : const Color(0xFFFAFAFA),
              ),
              child: Row(
                children: [
                  // Frozen name skeleton
                  _skeletonBox(130, 14, opacity),
                  const SizedBox(width: 1),
                  // Dist skeleton
                  _skeletonBox(130, 14, opacity),
                  const SizedBox(width: 1),
                  // Other columns
                  ...[70.0, 65.0, 85.0, 75.0, 85.0, 75.0, 60.0, 60.0]
                      .map((w) => _skeletonBox(w, 10, opacity)),
                ],
              ),
            );
          }),
        );
      },
      onEnd: () => setState(() {}), // retrigger animation loop
    );
  }

  Widget _skeletonBox(double width, double height, double opacity) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
      child: Opacity(
        opacity: opacity,
        child: Container(
          width: width - 20,
          height: height,
          decoration: BoxDecoration(
            color: const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Future<void> _exportCustomersToExcel(BuildContext context) async {
    final provider = Provider.of<NexusProvider>(context, listen: false);
    final customers = provider.customers;
    if (customers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No customer data to export'), backgroundColor: Colors.orange),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('📊 Preparing Excel export...'), backgroundColor: NexusTheme.indigo500, behavior: SnackBarBehavior.floating),
    );

    try {
      final excel = xl.Excel.createExcel();
      final sheet = excel['Customer Master'];

      // Headers
      final headers = [
        'Customer ID', 'Customer Name', 'Dist', 'Sales Manager', 'Class',
        'Employee Respons.', 'Credit Days', 'Credit Limit', 'Security Chq',
        'Dist Channel', 'O/s Amt', 'OD Amt', 'Diffn btw ydy & tday',
        '0 to 7', '7 to 15', '15 to 30', '30 to 45', '45 to 90',
        '90 to 120', '120 to 150', '150 to 180', '>180'
      ];
      sheet.appendRow(headers.map((h) => xl.TextCellValue(h)).toList());

      // Data rows
      for (final c in customers) {
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

      // Save file
      final dir = await getExternalStorageDirectory();
      final filePath = '${dir!.path}/Customer_Export_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      final fileBytes = excel.encode();
      if (fileBytes != null) {
        await File(filePath).writeAsBytes(fileBytes);
        await OpenFile.open(filePath);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Exported ${customers.length} customers!'),
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

  void _showMasterForm(BuildContext context, {dynamic initialData}) {
    final provider = Provider.of<NexusProvider>(context, listen: false);
    final Map<String, TextEditingController> controllers = {};
    
    List<String> fields = [];
    if (_selectedTab == 'CUSTOMER MASTER') {
      fields = ['ID', 'NAME', 'ADDRESS', 'CITY', 'LIMIT'];
    } else if (_selectedTab == 'MATERIAL MASTER') {
      fields = ['SKU CODE', 'NAME', 'PRICE', 'CATEGORY', 'STOCK'];
    } else {
      fields = ['NAME', 'EMAIL', 'ROLE', 'PASSWORD', 'LOCATION', 'DEPARTMENT 1', 'DEPARTMENT 2', 'CHANNEL', 'WHATSAPP', 'SALARY'];
    }

    // Initialize controllers with initialData if available
    for (var f in fields) {
      String value = '';
      if (initialData != null) {
        if (_selectedTab == 'USER MASTER' && initialData is User) {
          if (f == 'NAME') value = initialData.name;
          if (f == 'EMAIL') value = initialData.id;
          if (f == 'ROLE') value = initialData.role.label;
          if (f == 'LOCATION') value = initialData.location;
          if (f == 'DEPARTMENT 1') value = initialData.department1 ?? '';
          if (f == 'DEPARTMENT 2') value = initialData.department2 ?? '';
          if (f == 'CHANNEL') value = initialData.channel ?? '';
          if (f == 'WHATSAPP') value = initialData.whatsappNumber ?? '';
        } else if (_selectedTab == 'CUSTOMER MASTER' && initialData is Customer) {
          if (f == 'ID') value = initialData.id;
          if (f == 'NAME') value = initialData.name;
          if (f == 'ADDRESS') value = initialData.address;
          if (f == 'CITY') value = initialData.city;
          if (f == 'LIMIT') value = initialData.limit.toString();
        } else if (_selectedTab == 'MATERIAL MASTER' && initialData is Product) {
          if (f == 'SKU CODE') value = initialData.skuCode;
          if (f == 'NAME') value = initialData.name;
          if (f == 'PRICE') value = initialData.price.toString();
          if (f == 'CATEGORY') value = initialData.category;
          if (f == 'STOCK') value = initialData.stock.toString();
        }
      }
      controllers[f] = TextEditingController(text: value);
    }

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          bool isFormLoading = false;
          
          return Dialog(
            backgroundColor: Colors.white,
            insetPadding: const EdgeInsets.all(20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        initialData == null ? 'Add New Entry' : 'Edit Entry',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Color(0xFF0F172A), size: 28),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          ...fields.map((f) => Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: TextField(
                              controller: controllers[f],
                              style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 14),
                              decoration: InputDecoration(
                                labelText: f.toUpperCase(),
                                labelStyle: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1),
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                                enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF0F172A), width: 1.5), borderRadius: BorderRadius.circular(16)),
                                focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2), borderRadius: BorderRadius.circular(16)),
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                              ),
                            ),
                          )).toList(),
                          if (_selectedTab == 'CUSTOMER MASTER' && 
                              initialData is Customer && 
                              (authProvider.currentUser?.role.label == 'Admin' || authProvider.currentUser?.role.label == 'Credit Control')) ...[
                            const SizedBox(height: 24),
                            const Divider(height: 48),
                            NexusComponents.creditMatrix(initialData),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: isFormLoading ? null : () async {
                        setDialogState(() => isFormLoading = true);
                        bool success = false;
                        
                        try {
                          if (_selectedTab == 'USER MASTER') {
                            success = await provider.createUser({
                              'name': controllers['NAME']!.text,
                              'id': controllers['EMAIL']!.text,
                              'role': controllers['ROLE']!.text,
                              'password': controllers['PASSWORD']!.text,
                              'location': controllers['LOCATION']!.text,
                              'department1': controllers['DEPARTMENT 1']!.text,
                              'department2': controllers['DEPARTMENT 2']!.text,
                              'channel': controllers['CHANNEL']!.text,
                              'whatsappNumber': controllers['WHATSAPP']!.text,
                            });
                          } else if (_selectedTab == 'CUSTOMER MASTER') {
                            success = await provider.createCustomer({
                              'id': controllers['ID']!.text,
                              'name': controllers['NAME']!.text,
                              'address': controllers['ADDRESS']!.text,
                              'city': controllers['CITY']!.text,
                              'limit': double.tryParse(controllers['LIMIT']!.text) ?? 1500000,
                            });
                          } else if (_selectedTab == 'MATERIAL MASTER') {
                            success = await provider.createProduct({
                              'skuCode': controllers['SKU CODE']!.text,
                              'name': controllers['NAME']!.text,
                              'price': double.tryParse(controllers['PRICE']!.text) ?? 0.0,
                              'category': controllers['CATEGORY']!.text,
                              'stock': int.tryParse(controllers['STOCK']!.text) ?? 0,
                            });
                          }
                          
                          if (success && context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Successfully saved to Master!'), backgroundColor: Colors.green),
                            );
                          }
                        } catch (e) {
                           if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                            );
                          }
                        } finally {
                          if (context.mounted) setDialogState(() => isFormLoading = false);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F172A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: isFormLoading 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('SAVE TO MASTER', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleBulkImport(BuildContext context) async {
    final provider = Provider.of<NexusProvider>(context, listen: false);
    
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() => _isLoading = true);
      final success = await provider.importCustomers(result.files.single.path!);
      setState(() => _isLoading = false);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bulk import completed successfully!'), backgroundColor: Colors.green),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bulk import failed. Please check the file format.'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
