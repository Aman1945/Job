import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../providers/auth_provider.dart';
import '../models/models.dart';
import '../config/api_config.dart';

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ PALETTE â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
const _kBg      = Color(0xFFF8FAFC);
const _kDark    = Color(0xFF0F172A);
const _kBlue    = Color(0xFF1E40AF);
const _kTeal    = Color(0xFF0D9488);
const _kSub     = Color(0xFF64748B);
const _kBorder  = Color(0xFFE2E8F0);
const _kCard    = Colors.white;

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

  User? _selectedUser;
  Map<String, String> _modifications = {};
  bool _isSaving = false;

  final List<String> _intake = ['Creation', 'Placed Order', 'Credit Approval', 'Warehouse'];
  final List<String> _processing = ['Packing', 'QC', 'Logistics Cost'];
  final List<String> _outbound = ['Invoice', 'Dispatch & Load', 'Delivery Ack'];

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
        });
      }
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  Future<void> _saveChanges() async {
    if (_selectedUser == null || _modifications.isEmpty) return;
    setState(() => _isSaving = true);
    
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final headers = Map<String, String>.from(auth.authHeaders)..['Content-Type'] = 'application/json';

      final res = await http.patch(
        Uri.parse('${ApiConfig.baseUrl}/users/${_selectedUser!.id}/step-access'),
        headers: headers,
        body: json.encode({'stepAccess': _modifications}),
      );

      if (res.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('âœ… Step Access updated successfully!'),
            backgroundColor: _kTeal,
            behavior: SnackBarBehavior.floating,
          ));
        }
        await _fetchUsers();
        setState(() {
          _selectedUser = null;
          _modifications.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error saving: $e'), backgroundColor: Colors.red));
      }
    }
    setState(() => _isSaving = false);
  }

  void _openUser(User u) {
    setState(() {
      _selectedUser = u;
      _modifications = Map<String, String>.from(u.stepAccess); // copy current state
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedUser != null) return _buildDetailsScreen();
    return _buildDirectoryScreen();
  }

  // â• â• â• â• â• â• â• â• â• â• â• â• â• â• â• â• â• â• â• â• â• â•  USER DIRECTORY SCREEN â• â• â• â• â• â• â• â• â• â• â• â• â• â• â• â• â• â• â• â• â• â• 
  Widget _buildDirectoryScreen() {
    final filteredUsers = _users.where((u) {
      final matchQ = _searchQuery.isEmpty || u.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchZ = _zoneFilter == 'ALL' || u.zone.toUpperCase() == _zoneFilter;
      final matchR = _roleFilter == 'ALL' || u.role.label == _roleFilter;
      return matchQ && matchZ && matchR;
    }).toList();

    final zones = ['ALL', ..._users.map((u) => u.zone.toUpperCase()).toSet().toList()..sort()];
    final roles = ['ALL', ..._users.map((u) => u.role.label).toSet().toList()..sort()];

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kBg,
        elevation: 0,
        title: const Text('User / Role Management', style: TextStyle(
          fontWeight: FontWeight.w900, fontSize: 18, color: _kDark, letterSpacing: -0.5,
        )),
        actions: [
          IconButton(icon: const Icon(Icons.search_rounded, color: _kDark), onPressed: () {}),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _kBlue))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search & Filter Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: _kBorder),
                        ),
                        child: TextField(
                          onChanged: (v) => setState(() => _searchQuery = v),
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                          decoration: const InputDecoration(
                            hintText: 'Search users or roles',
                            hintStyle: TextStyle(color: _kSub, fontSize: 14),
                            prefixIcon: Icon(Icons.search, color: _kSub, size: 18),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _filterDropdown('All Regions', _zoneFilter, zones, (v) => setState(() => _zoneFilter = v!)),
                            const SizedBox(width: 8),
                            _filterDropdown('All Roles', _roleFilter, roles, (v) => setState(() => _roleFilter = v!)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('USER DIRECTORY', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: _kSub, letterSpacing: 0.5)),
                      Text('${filteredUsers.length} Total Users', style: const TextStyle(fontSize: 12, color: _kSub, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Users List (Premium Card Style)
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filteredUsers.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final u = filteredUsers[index];
                      // Just checking if any access is granted for the quick-badge
                      final hasAccess = u.stepAccess.values.any((v) => v == 'full' || v == 'view');
                      
                      return GestureDetector(
                        onTap: () => _openUser(u),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _kCard,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _kBorder),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
                          ),
                          child: Row(
                            children: [
                              // Avatar
                              Container(
                                width: 42, height: 42,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE0F2FE),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    u.name.isNotEmpty ? u.name.substring(0, 2).toUpperCase() : '??',
                                    style: const TextStyle(color: _kBlue, fontWeight: FontWeight.w900, fontSize: 15),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              
                              // Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(u.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: _kDark)),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(4)),
                                          child: Text(u.role.label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _kSub)),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(u.zone.toUpperCase(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: _kSub, letterSpacing: 0.5)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Access Status Pill
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: hasAccess ? const Color(0xFF2563EB) : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(hasAccess ? 'YES' : 'NO', style: TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.w900,
                                  color: hasAccess ? Colors.white : _kSub,
                                )),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  // â• â• â• â• â• â• â• â• â• â• â• â• â• â• â• â• â• â• â• â• â• â•  USER DETAILS SCREEN â• â• â• â• â• â• â• â• â• â• â• â• â• â• â• â• â• â• â• â• â• â• 
  Widget _buildDetailsScreen() {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: _kBg,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: _kDark),
            onPressed: () {
              // Exit without saving
              setState(() { _selectedUser = null; _modifications.clear(); });
            },
          ),
          title: Text(_selectedUser!.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: _kDark, letterSpacing: -0.5)),
          actions: [
            IconButton(icon: const Icon(Icons.more_vert_rounded, color: _kDark), onPressed: () {}),
          ],
          bottom: const TabBar(
            labelColor: _kBlue,
            unselectedLabelColor: _kSub,
            indicatorColor: _kBlue,
            indicatorWeight: 3,
            labelStyle: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.5),
            tabs: [
              Tab(text: 'INTAKE'),
              Tab(text: 'PROCESSING'),
              Tab(text: 'OUTBOUND'),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: TabBarView(
                // The three screens identical to screenshots
                children: [
                  _tabViewList(_intake),
                  _tabViewCards(_processing),
                  _tabViewList(_outbound), // Invoice / Dispatch / Delivery style
                ],
              ),
            ),
            
            // Bottom Save Bar
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                border: const Border(top: BorderSide(color: _kBorder)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4))],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveChanges,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _kBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isSaving 
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('SAVE ASSIGNMENTS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // A sleek list style (like Screenshot 3 & 4)
  Widget _tabViewList(List<String> stages) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: stages.length,
      itemBuilder: (context, index) {
        final stg = stages[index];
        final val = _modifications[stg] ?? 'no';
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _kCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _kBorder),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(stg.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: _kDark)),
                    const SizedBox(height: 4),
                    Text('Workflow Stage Module', style: TextStyle(fontSize: 11, color: _kSub, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              _segmentToggle(stg, val),
            ],
          ),
        );
      },
    );
  }

  // A Card style with internal splits (like Screenshot 2)
  Widget _tabViewCards(List<String> stages) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          decoration: BoxDecoration(
            color: _kCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _kBorder),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.settings_suggest_rounded, color: _kTeal, size: 20),
                    const SizedBox(width: 8),
                    const Expanded(child: Text('Operational Access Settings', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: _kDark))),
                  ],
                ),
              ),
              const Divider(height: 1, color: _kBorder),
              IntrinsicHeight(
                child: Row(
                  children: stages.map((stg) {
                    final val = _modifications[stg] ?? 'no';
                    return Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
                        decoration: BoxDecoration(
                          border: stg != stages.last ? const Border(right: BorderSide(color: _kBorder)) : null,
                        ),
                        child: Column(
                          children: [
                            Text(stg.toUpperCase(), textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 10, color: _kSub)),
                            const SizedBox(height: 12),
                            _pillButton(stg, val),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  // The cool segmented toggle for Lists
  Widget _segmentToggle(String stage, String currentVal) {
    Widget seg(String label, String valCode, Color activeColor) {
      final active = currentVal == valCode;
      return GestureDetector(
        onTap: () => setState(() => _modifications[stage] = valCode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: active ? activeColor.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(label, style: TextStyle(
            fontSize: 10, fontWeight: FontWeight.w900,
            color: active ? activeColor : _kSub,
          )),
        ),
      );
    }
    
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _kBorder),
      ),
      padding: const EdgeInsets.all(2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          seg('NO', 'no', _kSub),
          seg('VIEW', 'view', const Color(0xFF3B82F6)),
          seg('FULL', 'full', _kTeal),
        ],
      ),
    );
  }

  // The cool pill button for Cards that Cycles on Tap
  Widget _pillButton(String stage, String currentVal) {
    Color bg = const Color(0xFFF1F5F9);
    Color txt = _kSub;
    if (currentVal == 'full') { bg = const Color(0xFFD1FAE5); txt = _kTeal; }
    else if (currentVal == 'view') { bg = const Color(0xFFDBEAFE); txt = const Color(0xFF2563EB); }

    void cycle() {
      String nxt = 'no';
      if (currentVal == 'no') nxt = 'view';
      else if (currentVal == 'view') nxt = 'full';
      setState(() => _modifications[stage] = nxt);
    }

    return GestureDetector(
      onTap: cycle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
        child: Text(currentVal.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: txt)),
      ),
    );
  }

  // Helper for Directory Dropsdowns
  Widget _filterDropdown(String hint, String current, List<String> items, Function(String?) onChange) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _kBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: current == 'ALL' ? hint : current,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: _kSub, size: 16),
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _kDark),
          items: items.map((e) {
            final val = e == 'ALL' ? hint : e;
            return DropdownMenuItem(value: val, child: Text(val));
          }).toList(),
          onChanged: (v) {
            String out = v == hint ? 'ALL' : v!;
            onChange(out);
          },
        ),
      ),
    );
  }
}
