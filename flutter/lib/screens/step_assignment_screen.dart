import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../providers/auth_provider.dart';
import '../models/models.dart';
import '../config/api_config.dart';

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ PALETTE â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
const _kBg      = Color(0xFFF1F5F9);
const _kDark    = Color(0xFF0F172A);
const _kTeal    = Color(0xFF14B8A6);
const _kSub     = Color(0xFF64748B);
const _kBorder  = Color(0xFFE2E8F0);

class StepAssignmentScreen extends StatefulWidget {
  const StepAssignmentScreen({super.key});

  @override
  State<StepAssignmentScreen> createState() => _StepAssignmentScreenState();
}

class _StepAssignmentScreenState extends State<StepAssignmentScreen> {
  List<User> _users = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _zoneFilter = 'ALL';
  String _roleFilter = 'ALL';

  // State maps to hold un-saved modifications
  final Map<String, Map<String, String>> _modifications = {}; 
  bool _isSaving = false;

  final List<String> _stages = [
    'Creation',
    'Placed Order',
    'Credit Approval',
    'Warehouse',
    'Packing',
    'QC',
    'Logistics Cost',
    'Invoice',
    'Dispatch & Load',
    'Delivery Ack'
  ];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() => _isLoading = true);
    try {
      final res = await http.get(Uri.parse('${ApiConfig.baseUrl}/users'));
      if (res.statusCode == 200) {
        final List data = json.decode(res.body);
        setState(() {
          _users = data.map((u) => User.fromJson(u)).where((u) => u.role.label != 'Admin').toList();
          _modifications.clear();
        });
      }
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  Future<void> _saveAllChanges() async {
    if (_modifications.isEmpty) return;
    setState(() => _isSaving = true);
    
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final headers = Map<String, String>.from(auth.authHeaders)..['Content-Type'] = 'application/json';

      int successCount = 0;
      for (var userId in _modifications.keys) {
        final accessMap = _modifications[userId]!;
        final res = await http.patch(
          Uri.parse('${ApiConfig.baseUrl}/users/$userId/step-access'),
          headers: headers,
          body: json.encode({'stepAccess': accessMap}),
        );
        if (res.statusCode == 200) successCount++;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('âœ… Successfully updated assignments for $successCount user(s)'),
          backgroundColor: _kTeal,
          behavior: SnackBarBehavior.floating,
        ));
      }
      await _fetchUsers();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error saving: $e'), backgroundColor: Colors.red));
      }
    }
    setState(() => _isSaving = false);
  }

  // Toggles cycle: no -> view -> full -> no
  void _toggleAccess(String userId, String stage) {
    if (!_modifications.containsKey(userId)) {
      final user = _users.firstWhere((u) => u.id == userId);
      _modifications[userId] = Map<String, String>.from(user.stepAccess);
    }

    final current = _modifications[userId]![stage] ?? 'no';
    String next = 'no';
    if (current == 'no') next = 'view';
    else if (current == 'view') next = 'full';
    
    setState(() {
      _modifications[userId]![stage] = next;
    });
  }

  String _getAccess(String userId, String stage) {
    if (_modifications.containsKey(userId) && _modifications[userId]!.containsKey(stage)) {
      return _modifications[userId]![stage]!;
    }
    final user = _users.firstWhere((u) => u.id == userId, orElse: () => _users[0]);
    return user.stepAccess[stage] ?? 'no';
  }

  @override
  Widget build(BuildContext context) {
    final filteredUsers = _users.where((u) {
      final matchQ = _searchQuery.isEmpty || u.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchZ = _zoneFilter == 'ALL' || u.zone.toUpperCase() == _zoneFilter;
      final matchR = _roleFilter == 'ALL' || u.role.label == _roleFilter;
      return matchQ && matchZ && matchR;
    }).toList();

    // Collect distinct zones and roles for filters
    final zones = ['ALL', ..._users.map((u) => u.zone.toUpperCase()).toSet().toList()..sort()];
    final roles = ['ALL', ..._users.map((u) => u.role.label).toSet().toList()..sort()];

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.05),
        title: const Row(
          children: [
            Icon(Icons.assignment_ind_rounded, color: _kTeal, size: 22),
            SizedBox(width: 10),
            Text('Step Assignment Map', style: TextStyle(
              fontWeight: FontWeight.w900, fontSize: 18, color: _kDark, letterSpacing: -0.3,
            )),
          ],
        ),
        actions: [
          if (_modifications.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 12, top: 10, bottom: 10),
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveAllChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kDark,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                icon: _isSaving
                    ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.save_alt_rounded, size: 16),
                label: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: _kSub),
            onPressed: _fetchUsers,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _kTeal))
          : Column(
              children: [
                // Filters Row
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(bottom: BorderSide(color: _kBorder)),
                  ),
                  child: Row(
                    children: [
                      // Search
                      Expanded(
                        child: Container(
                          height: 40,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: _kBg,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: _kBorder),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.search, size: 16, color: _kSub),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  onChanged: (v) => setState(() => _searchQuery = v),
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                  decoration: const InputDecoration(
                                    hintText: 'Search user...',
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      // Zone Filter
                      _dropdown('Zone', _zoneFilter, zones, (v) => setState(() => _zoneFilter = v!)),
                      const SizedBox(width: 12),

                      // Role Filter
                      _dropdown('Role', _roleFilter, roles, (v) => setState(() => _roleFilter = v!)),
                    ],
                  ),
                ),

                // Table
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _kBorder),
                      boxShadow: [BoxShadow(color: _kDark.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - 40),
                            child: DataTable(
                              headingRowColor: MaterialStateProperty.all(const Color(0xFFF8FAFC)),
                              dividerThickness: 1,
                              horizontalMargin: 20,
                              columnSpacing: 24,
                              dataRowMaxHeight: 64,
                              dataRowMinHeight: 64,
                              columns: [
                                const DataColumn(label: Text('USER / ROLE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: _kSub, letterSpacing: 0.5))),
                                ..._stages.map((stg) => DataColumn(
                                  label: SizedBox(
                                    width: 80,
                                    child: Text(stg.toUpperCase(), textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 10, color: _kDark)),
                                  ),
                                )),
                              ],
                              rows: filteredUsers.map((u) {
                                return DataRow(
                                  cells: [
                                    DataCell(
                                      SizedBox(
                                        width: 180,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(u.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: _kDark), maxLines: 1, overflow: TextOverflow.ellipsis),
                                            const SizedBox(height: 2),
                                            Row(
                                              children: [
                                                _badge(u.role.label, _kTeal),
                                                const SizedBox(width: 4),
                                                _badge(u.zone.toUpperCase(), const Color(0xFF6366F1)),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    // Stage boxes
                                    ..._stages.map((stg) {
                                      final access = _getAccess(u.id, stg);
                                      return DataCell(
                                        Center(
                                          child: GestureDetector(
                                            onTap: () => _toggleAccess(u.id, stg),
                                            child: AnimatedContainer(
                                              duration: const Duration(milliseconds: 150),
                                              width: 56, height: 32,
                                              decoration: BoxDecoration(
                                                color: access == 'full' ? _kTeal : access == 'view' ? const Color(0xFF3B82F6) : const Color(0xFFF1F5F9),
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: access == 'no' ? _kBorder : Colors.transparent,
                                                ),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  access.toUpperCase(),
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w800, fontSize: 10,
                                                    color: access == 'no' ? _kSub : Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Legend
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _legendItem('FULL', _kTeal),
                      const SizedBox(width: 20),
                      _legendItem('VIEW', const Color(0xFF3B82F6)),
                      const SizedBox(width: 20),
                      _legendItem('NO', const Color(0xFFF1F5F9), hasBorder: true),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _dropdown(String hint, String value, List<String> items, Function(String?) onChanged) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _kBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          icon: const Icon(Icons.arrow_drop_down_rounded, color: _kSub),
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _kDark),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label, style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: color)),
    );
  }

  Widget _legendItem(String label, Color color, {bool hasBorder = false}) {
    return Row(
      children: [
        Container(
          width: 12, height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            border: hasBorder ? Border.all(color: _kBorder) : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _kSub)),
      ],
    );
  }
}
