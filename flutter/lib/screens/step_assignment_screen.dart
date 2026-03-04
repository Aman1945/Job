import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/theme.dart';
import '../models/models.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class StepAssignmentScreen extends StatefulWidget {
  const StepAssignmentScreen({super.key});

  @override
  State<StepAssignmentScreen> createState() => _StepAssignmentScreenState();
}

class _StepAssignmentScreenState extends State<StepAssignmentScreen> {
  List<User> _users = [];
  bool _isLoading = true;

  final List<Map<String, dynamic>> _workflowSteps = [
    {'label': 'Master Creation', 'icon': Icons.app_registration_rounded, 'color': const Color(0xFF6366F1)},
    {'label': 'Placed Order', 'icon': Icons.shopping_cart_checkout_rounded, 'color': const Color(0xFF0EA5E9)},
    {'label': 'Sales Alignment', 'icon': Icons.group_add_rounded, 'color': const Color(0xFF14B8A6)},
    {'label': 'Credit Approv.', 'icon': Icons.verified_rounded, 'color': const Color(0xFFF97316)},
    {'label': 'Warehouse', 'icon': Icons.inventory_2_rounded, 'color': const Color(0xFF78716C)},
    {'label': 'Packing', 'icon': Icons.inventory_rounded, 'color': const Color(0xFFEAB308)},
    {'label': 'QC', 'icon': Icons.verified_user_rounded, 'color': const Color(0xFF22C55E)},
    {'label': 'Logistic Cost', 'icon': Icons.currency_rupee_rounded, 'color': const Color(0xFF8B5CF6)},
    {'label': 'Invoice', 'icon': Icons.receipt_long_rounded, 'color': const Color(0xFF3B82F6)},
    {'label': 'DA Assignment', 'icon': Icons.assignment_turned_in_rounded, 'color': const Color(0xFF64748B)},
    {'label': 'Loading', 'icon': Icons.local_shipping_rounded, 'color': const Color(0xFFA855F7)},
    {'label': 'Delivery Ack', 'icon': Icons.task_alt_rounded, 'color': const Color(0xFFEF4444)},
  ];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/users'));
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        setState(() {
          _users = data.map((u) => User.fromJson(u)).toList();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStepAccess(String userId, Map<String, String> stepAccess) async {
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final headers = Map<String, String>.from(auth.authHeaders);
      headers['Content-Type'] = 'application/json';
      final response = await http.patch(
        Uri.parse('${ApiConfig.baseUrl}/users/$userId/step-access'),
        headers: headers,
        body: json.encode({'stepAccess': stepAccess}),
      );
      if (response.statusCode == 200) {
        _fetchUsers();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating access: $e')),
        );
      }
    }
  }

  Future<void> _updateUserDetails(String userId, String zone, UserRole role) async {
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final headers = Map<String, String>.from(auth.authHeaders);
      headers['Content-Type'] = 'application/json';
      await http.patch(
        Uri.parse('${ApiConfig.baseUrl}/users/$userId'),
        headers: headers,
        body: json.encode({'zone': zone, 'role': role.label}),
      );
    } catch (e) {
      debugPrint('Error updating user details: $e');
    }
  }

  Future<void> _updateManagerId(String userId, String? managerId) async {
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final headers = Map<String, String>.from(auth.authHeaders);
      headers['Content-Type'] = 'application/json';
      await http.patch(
        Uri.parse('${ApiConfig.baseUrl}/users/$userId'),
        headers: headers,
        body: json.encode({'managerId': managerId}),
      );
    } catch (e) {
      debugPrint('Error updating managerId: $e');
    }
  }

  void _showStepUsersDialog(String stepLabel, Color stepColor, IconData stepIcon) {
    Map<String, String> userAccessMap = {};
    Map<String, String> userZoneMap = {};
    Map<String, UserRole> userRoleMap = {};
    Map<String, String?> userManagerMap = {};

    for (final user in _users) {
      if (user.role.label == 'Admin') continue;
      userAccessMap[user.id] = user.stepAccess[stepLabel] ?? 'no';
      userZoneMap[user.id] = user.zone.toUpperCase();
      userRoleMap[user.id] = user.role;
      userManagerMap[user.id] = user.managerId;
    }

    final nonAdminUsers = _users.where((u) => u.role.label != 'Admin').toList();
    String searchQuery = '';
    bool isSaving = false;
    int selectedTab = 0; // 0 = Access, 1 = Team Setup
    String teamSetupZoneFilter = 'ALL';

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.3),
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (ctx, anim1, anim2) => const SizedBox(),
      transitionBuilder: (ctx, anim1, anim2, child) {
        final curved = CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curved,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.08),
                end: Offset.zero,
              ).animate(curved),
              child: StatefulBuilder(
                builder: (ctx, setDialogState) {
                  final filteredUsers = searchQuery.isEmpty
                      ? nonAdminUsers
                      : nonAdminUsers
                          .where((u) => u.name.toLowerCase().contains(searchQuery.toLowerCase()))
                          .toList();

                  // Zone grouping for Access tab
                  final zoneOrder = ['NORTH', 'SOUTH', 'EAST', 'WEST', 'PAN INDIA'];
                  final Map<String, List<User>> zoneGroups = {};
                  for (final z in zoneOrder) zoneGroups[z] = [];
                  for (final u in filteredUsers) {
                    final z = (userZoneMap[u.id] ?? u.zone).toUpperCase();
                    if (zoneGroups.containsKey(z)) {
                      zoneGroups[z]!.add(u);
                    } else {
                      zoneGroups['PAN INDIA']!.add(u);
                    }
                  }

                  final fullCount = userAccessMap.values.where((v) => v == 'full').length;
                  final viewCount = userAccessMap.values.where((v) => v == 'view').length;

                  return Dialog(
                    backgroundColor: Colors.transparent,
                    insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 36),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.18),
                          blurRadius: 40,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(ctx).size.height * 0.88,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // â”€â”€ DIALOG HEADER â”€â”€
                          Container(
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                              border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: stepColor.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Icon(stepIcon, color: stepColor, size: 22),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            stepLabel,
                                            style: const TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontSize: 15,
                                              fontWeight: FontWeight.w900,
                                              color: Color(0xFF0F172A),
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Row(
                                            children: [
                                              _statBadge('$fullCount Full', const Color(0xFF059669), const Color(0xFFD1FAE5)),
                                              const SizedBox(width: 6),
                                              _statBadge('$viewCount View', const Color(0xFF2563EB), const Color(0xFFDBEAFE)),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => Navigator.pop(ctx),
                                      child: Container(
                                        padding: const EdgeInsets.all(7),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF1F5F9),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: const Icon(Icons.close, size: 16, color: Color(0xFF64748B)),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                // Pill-style tabs
                                Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () => setDialogState(() => selectedTab = 0),
                                          child: AnimatedContainer(
                                            duration: const Duration(milliseconds: 200),
                                            padding: const EdgeInsets.symmetric(vertical: 9),
                                            decoration: BoxDecoration(
                                              color: selectedTab == 0 ? Colors.white : Colors.transparent,
                                              borderRadius: BorderRadius.circular(10),
                                              boxShadow: selectedTab == 0 ? [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 4)] : [],
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.shield_outlined, size: 13, color: selectedTab == 0 ? const Color(0xFF1E293B) : const Color(0xFF94A3B8)),
                                                const SizedBox(width: 5),
                                                Text('Access Control', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: selectedTab == 0 ? const Color(0xFF1E293B) : const Color(0xFF94A3B8))),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () => setDialogState(() => selectedTab = 1),
                                          child: AnimatedContainer(
                                            duration: const Duration(milliseconds: 200),
                                            padding: const EdgeInsets.symmetric(vertical: 9),
                                            decoration: BoxDecoration(
                                              color: selectedTab == 1 ? const Color(0xFF0F172A) : Colors.transparent,
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.people_outline_rounded, size: 13, color: selectedTab == 1 ? Colors.white : const Color(0xFF94A3B8)),
                                                const SizedBox(width: 5),
                                                Text('Team Setup', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: selectedTab == 1 ? Colors.white : const Color(0xFF94A3B8))),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // â”€â”€ SEARCH BAR â”€â”€
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Row(
                                children: [
                                  const SizedBox(width: 12),
                                  Icon(Icons.search_rounded, size: 17, color: Colors.grey.shade400),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      onChanged: (val) => setDialogState(() => searchQuery = val),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF0F172A),
                                      ),
                                      decoration: InputDecoration(
                                        hintText: 'Search user...',
                                        hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400, fontWeight: FontWeight.w400),
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                  ),
                                  if (searchQuery.isNotEmpty)
                                    GestureDetector(
                                      onTap: () => setDialogState(() => searchQuery = ''),
                                      child: Padding(
                                        padding: const EdgeInsets.only(right: 10),
                                        child: Icon(Icons.close_rounded, size: 16, color: Colors.grey.shade400),
                                      ),
                                    )
                                  else
                                    const SizedBox(width: 12),
                                ],
                              ),
                            ),
                          ),

                          if (selectedTab == 0) ...[
                            // â”€â”€ BULK ACTIONS ROW â”€â”€
                            Padding(
                              padding: const EdgeInsets.fromLTRB(18, 10, 18, 4),
                              child: Row(
                                children: [
                                  Text(
                                    '${filteredUsers.length} users',
                                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.w600, fontFamily: 'Montserrat'),
                                  ),
                                  const Spacer(),
                                  _bulkBtn('All Full', const Color(0xFF059669), Icons.check_circle_rounded, () {
                                    setDialogState(() {
                                      for (final u in filteredUsers) { userAccessMap[u.id] = 'full'; }
                                    });
                                  }),
                                  const SizedBox(width: 6),
                                  _bulkBtn('All View', const Color(0xFF2563EB), Icons.visibility_rounded, () {
                                    setDialogState(() {
                                      for (final u in filteredUsers) { userAccessMap[u.id] = 'view'; }
                                    });
                                  }),
                                  const SizedBox(width: 6),
                                  _bulkBtn('Clear', Colors.grey.shade500, Icons.block_rounded, () {
                                    setDialogState(() {
                                      for (final u in filteredUsers) { userAccessMap[u.id] = 'no'; }
                                    });
                                  }),
                                ],
                              ),
                            ),
                          ] else ...[
                            // Zone filter chips
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: ['ALL', 'NORTH', 'SOUTH', 'EAST', 'WEST', 'PAN INDIA'].map((z) {
                                    final isActive = teamSetupZoneFilter == z;
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 6),
                                      child: GestureDetector(
                                        onTap: () => setDialogState(() => teamSetupZoneFilter = z),
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 180),
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: isActive ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(color: isActive ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0)),
                                          ),
                                          child: Text(z, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: isActive ? Colors.white : const Color(0xFF64748B))),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ],

                          // â”€â”€ USER LIST â”€â”€
                          Flexible(
                            child: ListView(
                              shrinkWrap: true,
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(14, 4, 14, 8),
                              children: selectedTab == 0
                                  ? [
                                      // â”€â”€ ROLE GROUPED ACCESS TAB --
                                      for (final roleLabel in filteredUsers.map((u) => u.role.label).toSet().toList()..sort()) ...[
                                        if (filteredUsers.any((u) => u.role.label == roleLabel)) ...[
                                          Padding(
                                            padding: const EdgeInsets.only(top: 10, bottom: 6, left: 4),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: stepColor.withOpacity(0.09),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                roleLabel.toUpperCase(),
                                                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: stepColor, letterSpacing: 0.6),
                                              ),
                                            ),
                                          ),
                                          for (final user in filteredUsers.where((u) => u.role.label == roleLabel)) ...[
                                            AnimatedContainer(
                                              duration: const Duration(milliseconds: 200),
                                              margin: const EdgeInsets.only(bottom: 10),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(18),
                                                border: Border.all(
                                                  color: (userAccessMap[user.id] ?? 'no') == 'full'
                                                      ? const Color(0xFF10B981).withOpacity(0.5)
                                                      : (userAccessMap[user.id] ?? 'no') == 'view'
                                                          ? const Color(0xFF3B82F6).withOpacity(0.4)
                                                          : Colors.grey.shade200,
                                                  width: 1.5,
                                                ),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(14),
                                                child: _accessTabUserRow(user, userAccessMap[user.id] ?? 'no', stepColor, setDialogState, userAccessMap),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ],
                                    ]
                                  : [
                                      // TEAM SETUP TAB (flat) â”€â”€
                                      for (final user in filteredUsers.where((u) =>
                                            teamSetupZoneFilter == 'ALL' || (userZoneMap[u.id] ?? u.zone).toUpperCase() == teamSetupZoneFilter))
                                        AnimatedContainer(
                                          duration: const Duration(milliseconds: 200),
                                          margin: const EdgeInsets.only(bottom: 10),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(18),
                                            border: Border.all(color: Colors.grey.shade200, width: 1.5),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(14),
                                            child: _teamSetupTabUserRow(
                                              user, userZoneMap, userRoleMap, userManagerMap, setDialogState),
                                          ),
                                        ),
                                    ],
                            ),
                          ),

                          // â”€â”€ SAVE BUTTON â”€â”€
                          Container(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border(top: BorderSide(color: Colors.grey.shade100)),
                              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => Navigator.pop(ctx),
                                    child: Container(
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Center(
                                        child: Text(
                                          'CANCEL',
                                          style: TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.w800,
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 2,
                                  child: GestureDetector(
                                    onTap: isSaving
                                        ? null
                                        : () async {
                                            setDialogState(() => isSaving = true);
                                            // Save access changes
                                            for (final user in _users) {
                                              if (user.role.label == 'Admin') continue;
                                              final newAccess = userAccessMap[user.id] ?? 'no';
                                              final oldAccess = user.stepAccess[stepLabel] ?? 'no';
                                              if (newAccess != oldAccess) {
                                                final updated = Map<String, String>.from(user.stepAccess);
                                                updated[stepLabel] = newAccess;
                                                await _updateStepAccess(user.id, updated);
                                              }
                                              // Save zone/role changes
                                              final newZone = userZoneMap[user.id] ?? user.zone;
                                              final newRole = userRoleMap[user.id] ?? user.role;
                                              if (newZone != user.zone.toUpperCase() || newRole != user.role) {
                                                await _updateUserDetails(user.id, newZone, newRole);
                                              }
                                              // Save manager changes
                                              if (userManagerMap[user.id] != user.managerId) {
                                                await _updateManagerId(user.id, userManagerMap[user.id]);
                                              }
                                            }
                                            if (ctx.mounted) Navigator.pop(ctx);
                                            if (mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: const Row(
                                                    children: [
                                                      Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                                                      SizedBox(width: 10),
                                                      Text('Changes saved successfully!', style: TextStyle(fontWeight: FontWeight.w600)),
                                                    ],
                                                  ),
                                                  backgroundColor: const Color(0xFF059669),
                                                  behavior: SnackBarBehavior.floating,
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                  duration: const Duration(seconds: 2),
                                                ),
                                              );
                                            }
                                          },
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: isSaving ? const Color(0xFF334155) : const Color(0xFF0F172A),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Center(
                                        child: isSaving
                                            ? const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                              )
                                            : const Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(Icons.save_rounded, color: Colors.white, size: 16),
                                                  SizedBox(width: 8),
                                                  Text(
                                                    'SAVE CHANGES',
                                                    style: TextStyle(
                                                      fontFamily: 'Montserrat',
                                                      fontWeight: FontWeight.w900,
                                                      fontSize: 12,
                                                      color: Colors.white,
                                                      letterSpacing: 0.5,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );
    },
  );
}

  Widget _accessTabUserRow(
    User user,
    String access,
    Color stepColor,
    StateSetter setDialogState,
    Map<String, String> userAccessMap,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: access == 'full'
                ? stepColor
                : access == 'view'
                    ? const Color(0xFF3B82F6)
                    : Colors.grey.shade200,
          ),
          child: Center(
            child: Text(
              user.name[0].toUpperCase(),
              style: TextStyle(
                fontFamily: 'Montserrat',
                color: access == 'no' ? Colors.grey.shade500 : Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Name + Role/Zone + Access Pill toggle (stacked vertically to prevent overflow)
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.name,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  color: Color(0xFF0F172A),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      user.role.label.toUpperCase(),
                      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF64748B)),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      user.zone.toUpperCase(),
                      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Access Pill Toggle moved here below name/role
              _accessPillToggle(access, (newLevel) {
                setDialogState(() => userAccessMap[user.id] = newLevel);
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _accessPillToggle(String currentAccess, Function(String) onChanged) {
    final options = [
      {'value': 'full', 'label': 'Full', 'icon': Icons.edit_rounded, 'color': const Color(0xFF059669), 'bg': const Color(0xFFD1FAE5)},
      {'value': 'view', 'label': 'View', 'icon': Icons.visibility_rounded, 'color': const Color(0xFF2563EB), 'bg': const Color(0xFFDBEAFE)},
      {'value': 'no', 'label': 'None', 'icon': Icons.block_rounded, 'color': const Color(0xFF94A3B8), 'bg': const Color(0xFFF1F5F9)},
    ];

    return Container(
      height: 30,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: options.map((opt) {
          final isActive = currentAccess == opt['value'];
          final color = opt['color'] as Color;
          final bg = opt['bg'] as Color;
          return GestureDetector(
            onTap: () => onChanged(opt['value'] as String),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: EdgeInsets.symmetric(horizontal: isActive ? 7 : 6, vertical: 3),
              decoration: BoxDecoration(
                color: isActive ? bg : Colors.transparent,
                borderRadius: BorderRadius.circular(7),
                border: isActive ? Border.all(color: color.withValues(alpha: 0.3)) : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    opt['icon'] as IconData,
                    size: 11,
                    color: isActive ? color : Colors.grey.shade400,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    opt['label'] as String,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 9,
                      fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                      color: isActive ? color : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _teamSetupTabUserRow(
    User user,
    Map<String, String> userZoneMap,
    Map<String, UserRole> userRoleMap,
    Map<String, String?> userManagerMap,
    StateSetter setDialogState,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // User name + role badge
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0F172A),
              ),
              child: Center(
                child: Text(
                  user.name[0].toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    user.role.label,
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Zone + Role dropdowns
        Row(
          children: [
            Expanded(
              child: _labeledDropdown<String>(
                label: 'ZONE',
                value: userZoneMap[user.id] ?? user.zone.toUpperCase(),
                items: ['NORTH', 'WEST', 'EAST', 'SOUTH', 'PAN INDIA']
                    .map((z) => DropdownMenuItem(value: z, child: Text(z)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setDialogState(() => userZoneMap[user.id] = val);
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _labeledDropdown<UserRole>(
                label: 'ROLE',
                value: userRoleMap[user.id] ?? user.role,
                items: UserRole.values
                    .where((r) => r != UserRole.admin)
                    .map((r) => DropdownMenuItem(value: r, child: Text(r.label)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setDialogState(() => userRoleMap[user.id] = val);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Reports to
        _labeledDropdown<String?>(
          label: 'REPORTS TO',
          value: userManagerMap[user.id],
          items: [
            const DropdownMenuItem<String?>(value: null, child: Text('â€” No Manager â€”')),
            ..._users
                .where((u) => u.role == UserRole.rsm || u.role == UserRole.asm)
                .where((u) => u.id != user.id)
                .map((u) => DropdownMenuItem<String?>(
                      value: u.id,
                      child: Text('${u.role.label}: ${u.name}'),
                    )),
          ],
          onChanged: (val) {
            setDialogState(() => userManagerMap[user.id] = val);
          },
        ),
      ],
    );
  }

  Widget _labeledDropdown<T>({
    required String label,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8), letterSpacing: 0.5)),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.unfold_more_rounded, size: 16, color: Color(0xFF94A3B8)),
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1E293B), fontFamily: 'Montserrat'),
              onChanged: onChanged,
              items: items,
            ),
          ),
        ),
      ],
    );
  }

  Widget _statBadge(String label, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: textColor, fontFamily: 'Montserrat'),
      ),
    );
  }


  Widget _bulkBtn(String label, Color color, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 11, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(fontFamily: 'Montserrat', fontSize: 10, fontWeight: FontWeight.w800, color: color),
            ),
          ],
        ),
      ),
    );
  }

  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final totalUsers  = _users.where((u) => u.role.label != 'Admin').length;
    final assignedUsers = _users.where((u) =>
      u.role.label != 'Admin' &&
      u.stepAccess.values.any((v) => v == 'full' || v == 'view')
    ).length;
    final pendingUsers = totalUsers - assignedUsers;

    final filtered = _searchQuery.isEmpty
        ? _workflowSteps
        : _workflowSteps.where((s) =>
            (s['label'] as String).toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'STEP ASSIGNMENT',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.2, color: Color(0xFF1E293B)),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF64748B)),
            onPressed: _fetchUsers,
            tooltip: 'Refresh',
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1ABFA1)))
          : Column(
              children: [
                // ── Dark navy header card ────────────────────────────
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D2137),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      // Top row: icon + title + badge
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                        child: Row(
                          children: [
                            Container(
                              width: 44, height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.shield_rounded, color: Colors.white, size: 22),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Workflow Access Control',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 14,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Manage access for each workflow stage',
                                    style: TextStyle(
                                      color: Colors.white60,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '$totalUsers Users',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Divider
                      Container(height: 1, color: Colors.white.withOpacity(0.08)),
                      // Stats row
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            _headerStat('Total Users', '$totalUsers', Colors.white),
                            _headerStatDivider(),
                            _headerStat('Assigned', '$assignedUsers', const Color(0xFF22C55E)),
                            _headerStatDivider(),
                            _headerStat('Pending', '$pendingUsers', const Color(0xFFFF8C3A)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // ── Search bar + Export button ───────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: TextField(
                            onChanged: (v) => setState(() => _searchQuery = v),
                            style: const TextStyle(fontSize: 13),
                            decoration: InputDecoration(
                              hintText: 'Search by stage name...',
                              hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                              prefixIcon: const Icon(Icons.search_rounded, size: 18, color: Color(0xFF94A3B8)),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        height: 44,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.download_rounded, size: 16, color: Color(0xFF334155)),
                            SizedBox(width: 6),
                            Text('Export', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // ── Stage cards list ─────────────────────────────────
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final step      = filtered[index];
                      final stepLabel = step['label'] as String;
                      final stepColor = step['color'] as Color;
                      final stepIcon  = step['icon'] as IconData;
                      // Stage number in original list
                      final stageNum  = _workflowSteps.indexOf(step) + 1;

                      final assignedCount = _users.where((u) =>
                          u.stepAccess[stepLabel] == 'full' ||
                          u.stepAccess[stepLabel] == 'view').length;
                      final progress = totalUsers > 0 ? assignedCount / totalUsers : 0.0;
                      final pct = (progress * 100).round();
                      final hasNone = assignedCount == 0;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFE8EEF5)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Stage icon
                              Container(
                                width: 46, height: 46,
                                decoration: BoxDecoration(
                                  color: stepColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(13),
                                ),
                                child: Icon(stepIcon, color: stepColor, size: 22),
                              ),
                              const SizedBox(width: 12),
                              // Stage details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'STAGE $stageNum',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w900,
                                        color: stepColor,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                    const SizedBox(height: 1),
                                    Text(
                                      stepLabel,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    if (hasNone)
                                      Row(
                                        children: const [
                                          Icon(Icons.person_off_outlined, size: 12, color: Colors.redAccent),
                                          SizedBox(width: 4),
                                          Text(
                                            'No Users Assigned',
                                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.redAccent),
                                          ),
                                        ],
                                      )
                                    else
                                      Row(
                                        children: [
                                          Text(
                                            'Assigned Users: $assignedCount / $totalUsers',
                                            style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(4),
                                              child: LinearProgressIndicator(
                                                value: progress,
                                                minHeight: 4,
                                                backgroundColor: const Color(0xFFE2E8F0),
                                                valueColor: AlwaysStoppedAnimation<Color>(stepColor),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              // Right: % badge + Manage Access button
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: pct == 0
                                          ? const Color(0xFFFFEDED)
                                          : const Color(0xFFE8FBF7),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      '$pct%',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                        color: pct == 0 ? Colors.redAccent : const Color(0xFF1ABFA1),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  GestureDetector(
                                    onTap: () => _showStepUsersDialog(stepLabel, stepColor, stepIcon),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: const Color(0xFFE2E8F0)),
                                      ),
                                      child: const Text(
                                        'Manage Access',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF334155),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
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

  Widget _headerStat(String label, String value, Color valueColor) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 9, color: Colors.white54, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: valueColor)),
        ],
      ),
    );
  }

  Widget _headerStatDivider() {
    return Container(width: 1, height: 32, color: Colors.white.withOpacity(0.12), margin: const EdgeInsets.only(right: 16));
  }

}
