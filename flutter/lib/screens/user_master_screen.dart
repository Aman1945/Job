import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/nexus_provider.dart';
import '../utils/theme.dart';
import '../utils/master_actions.dart';
import '../providers/auth_provider.dart';
import '../models/models.dart';
import '../widgets/row_detail_panel.dart';

class UserMasterScreen extends StatefulWidget {
  const UserMasterScreen({super.key});

  @override
  State<UserMasterScreen> createState() => _UserMasterScreenState();
}

class _UserMasterScreenState extends State<UserMasterScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedRole = 'ALL';
  int _currentPage = 0;
  static const int _pageSize = 10;
  User? _selectedUser;

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
    final allUsers = provider.users;

    final roles = ['ALL', 'Admin', 'Sales', 'RSM', 'ASM', 'Sales Executive', 'Warehouse', 'Delivery Team'];
    final filtered = allUsers.where((u) {
      final matchSearch = _searchQuery.isEmpty ||
          u.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          u.id.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          u.zone.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchRole = _selectedRole == 'ALL' || u.role.label == _selectedRole;
      return matchSearch && matchRole;
    }).toList();

    final totalPages = filtered.isEmpty ? 1 : (filtered.length / _pageSize).ceil();
    final start = _currentPage * _pageSize;
    final end = (start + _pageSize).clamp(0, filtered.length);
    final pageItems = filtered.isEmpty ? <User>[] : filtered.sublist(start, end);

    // Stats
    final adminCount = allUsers.where((u) => u.role == UserRole.admin).length;
    final salesCount = allUsers.where((u) => u.role == UserRole.sales || u.role == UserRole.salesExecutive || u.role == UserRole.rsm || u.role == UserRole.asm).length;

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
          'USER MASTER',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1, color: Color(0xFF1E293B)),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
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
                      _metricCard('TOTAL USERS', allUsers.length.toString(), NexusTheme.indigo600, Icons.people_outline),
                      const SizedBox(width: 10),
                      _metricCard('ADMINS', adminCount.toString(), NexusTheme.emerald500, Icons.security_outlined),
                      const SizedBox(width: 10),
                      _metricCard('SALES TEAM', salesCount.toString(), Colors.orange, Icons.trending_up_outlined),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() { _searchQuery = v; _currentPage = 0; }),
                    decoration: InputDecoration(
                      hintText: 'Search by User ID, Name, Zone...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      filled: true,
                      fillColor: NexusTheme.slate50,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Role Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: roles.map((r) {
                        final isSelected = _selectedRole == r;
                        return GestureDetector(
                          onTap: () => setState(() { _selectedRole = r; _currentPage = 0; }),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF0F172A) : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0)),
                            ),
                            child: Text(r, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: isSelected ? Colors.white : const Color(0xFF64748B))),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            // ── Table ──
            SizedBox(
              height: 650,
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
                                Icon(Icons.people_outline, size: 60, color: Color(0xFFCBD5E1)),
                                SizedBox(height: 16),
                                Text('NO USERS FOUND', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF94A3B8), letterSpacing: 1)),
                              ],
                            ),
                          ),
                        )
                      else ...[
                        Expanded(
                          child: AnimatedDetailWrapper(
                            selectedKey: _selectedUser?.id,
                            table: _buildTable(pageItems),
                            detailPanel: _selectedUser == null ? null : () {
                              final u = _selectedUser!;
                              return RowDetailPanel(
                                title: u.name,
                                icon: Icons.person_outline,
                                accentColor: NexusTheme.indigo600,
                                onClose: () => setState(() => _selectedUser = null),
                                fields: [
                                  ('User ID', u.id),
                                  ('Full Name', u.name),
                                  ('Role', u.role.label),
                                  ('Zone', u.zone),
                                  ('Location', u.location),
                                  ('Dept 1', u.department1 ?? '-'),
                                  ('Dept 2', u.department2 ?? '-'),
                                  ('Channel', u.channel ?? '-'),
                                  ('WhatsApp', u.whatsappNumber ?? '-'),
                                  if (u.managerId != null) ('Reports To (ID)', u.managerId!),
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

            // ── Action Bar ──
            MasterActions.actionBar(
              context: context,
              onAdd: () => _showAddDialog(context, provider),
              onImport: () {
                // Future implementation: User bulk import if needed
              },
              onExport: () {
                // Future implementation: User export if needed
              },
            ),
          ],
        ),
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

  Widget _buildTable(List<User> items) {
    const headerColor = Color(0xFF64748B);
    const headerBg = Color(0xFFF1F5F9);
    const divider = Color(0xFFE2E8F0);
    const rowDivider = Color(0xFFE8EDF2);

    final scrollCols = [
      ('USER ID', 100.0),
      ('ROLE', 120.0),
      ('ZONE', 100.0),
      ('LOCATION', 120.0),
      ('WHATSAPP', 120.0),
      ('DEPT 1', 100.0),
      ('CHANNEL', 100.0),
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

    Widget roleBadge(String label) {
       Color bg = NexusTheme.indigo50.withOpacity(0.8);
       Color fg = NexusTheme.indigo600;
       if (label == 'Admin') { bg = const Color(0xFFFEF2F2); fg = const Color(0xFFEF4444); }
       if (label.contains('WS') || label.contains('Warehouse')) { bg = const Color(0xFFF0FDF4); fg = const Color(0xFF15803D); }
       return Container(
         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
         decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
         child: Text(label.toUpperCase(), style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: fg)),
       );
    }

    final headerRow = Row(
      children: [
        frozenCell('USER NAME', isHeader: true),
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
              SingleChildScrollView(
                controller: _vFrozen,
                child: Column(
                  children: items.map((u) => GestureDetector(
                    onTap: () => setState(() =>
                        _selectedUser = (_selectedUser?.id == u.id) ? null : u),
                    child: Container(
                      color: _selectedUser?.id == u.id ? const Color(0xFFEEF2FF) : Colors.transparent,
                      child: frozenCell(u.name),
                    ),
                  )).toList(),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  controller: _hBody,
                  child: SingleChildScrollView(
                    controller: _vBody,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: items.map((u) => GestureDetector(
                        onTap: () => setState(() =>
                            _selectedUser = (_selectedUser?.id == u.id) ? null : u),
                        child: Container(
                          color: _selectedUser?.id == u.id ? const Color(0xFFEEF2FF) : Colors.transparent,
                          child: Row(
                            children: [
                              scrollCell(u.id, scrollCols[0].$2, textColor: NexusTheme.indigo600),
                              scrollCell('', scrollCols[1].$2, child: roleBadge(u.role.label)),
                              scrollCell(u.zone, scrollCols[2].$2),
                              scrollCell(u.location, scrollCols[3].$2),
                              scrollCell(u.whatsappNumber ?? '-', scrollCols[4].$2),
                              scrollCell(u.department1 ?? '-', scrollCols[5].$2),
                              scrollCell(u.channel ?? '-', scrollCols[6].$2),
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

  void _showAddDialog(BuildContext context, NexusProvider provider) {
    // Basic implementation of add user dialog
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add User functionality coming soon')));
  }
}
