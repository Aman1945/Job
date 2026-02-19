import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/nexus_provider.dart';
import '../providers/auth_provider.dart';
import '../models/models.dart';

class TeamHierarchyScreen extends StatefulWidget {
  const TeamHierarchyScreen({super.key});

  @override
  State<TeamHierarchyScreen> createState() => _TeamHierarchyScreenState();
}

class _TeamHierarchyScreenState extends State<TeamHierarchyScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Zone tabs — PAN INDIA listed last, others first
  final List<String> _zones = ['ALL', 'NORTH', 'WEST', 'EAST', 'SOUTH', 'PAN INDIA'];

  final Map<String, Color> _zoneColors = {
    'NORTH': const Color(0xFF3B82F6),
    'WEST': const Color(0xFFF59E0B),
    'EAST': const Color(0xFF10B981),
    'SOUTH': const Color(0xFFEF4444),
    'PAN INDIA': const Color(0xFF8B5CF6),
    'ALL': const Color(0xFF0F172A),
  };

  final Map<UserRole, Color> _roleColors = {
    UserRole.rsm: const Color(0xFF7C3AED),
    UserRole.asm: const Color(0xFF2563EB),
    UserRole.sales: const Color(0xFF059669),
    UserRole.salesExecutive: const Color(0xFF059669),
    UserRole.admin: const Color(0xFFDC2626),
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _zones.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _getRoleColor(UserRole role) =>
      _roleColors[role] ?? const Color(0xFF64748B);

  /// Returns top-level users (no managerId) for a given zone filter
  List<User> _getRoots(List<User> allUsers, String zone) {
    return allUsers.where((u) {
      if (u.role == UserRole.admin) return false;
      final zoneMatch = zone == 'ALL' || u.zone.toUpperCase() == zone;
      // Root = no managerId OR managerId points to someone outside the list
      final isRoot = u.managerId == null ||
          u.managerId!.isEmpty ||
          !allUsers.any((other) => other.id == u.managerId);
      return zoneMatch && isRoot;
    }).toList()
      ..sort((a, b) => _roleRank(a.role).compareTo(_roleRank(b.role)));
  }

  /// Returns direct reports of [managerId]
  List<User> _getReports(List<User> allUsers, String managerId, String zone) {
    return allUsers.where((u) {
      final zoneMatch = zone == 'ALL' || u.zone.toUpperCase() == zone;
      return u.managerId == managerId && zoneMatch;
    }).toList()
      ..sort((a, b) => _roleRank(a.role).compareTo(_roleRank(b.role)));
  }

  int _roleRank(UserRole r) {
    switch (r) {
      case UserRole.rsm: return 0;
      case UserRole.asm: return 1;
      case UserRole.salesExecutive: return 2;
      case UserRole.sales: return 3;
      default: return 9;
    }
  }

  @override
  Widget build(BuildContext context) {
    final nexus = Provider.of<NexusProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final currentUser = auth.currentUser;

    // Filter users based on current user's role
    List<User> visibleUsers = nexus.users.where((u) => u.role != UserRole.admin).toList();
    if (currentUser != null && currentUser.role == UserRole.rsm) {
      final teamIds = nexus.getTeamMemberIds(currentUser);
      visibleUsers = visibleUsers.where((u) => teamIds.contains(u.id) || u.id == currentUser.id).toList();
    } else if (currentUser != null && currentUser.role == UserRole.asm) {
      final teamIds = nexus.getTeamMemberIds(currentUser);
      visibleUsers = visibleUsers.where((u) => teamIds.contains(u.id) || u.id == currentUser.id).toList();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('TEAM HIERARCHY',
                style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1)),
            Text('Reporting Structure',
                style: TextStyle(fontFamily: 'Montserrat', fontSize: 10, color: Colors.white54, fontWeight: FontWeight.w500)),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w800, fontSize: 10, letterSpacing: 0.5),
          unselectedLabelStyle: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w500, fontSize: 10),
          tabs: _zones.map((z) {
            final color = _zoneColors[z] ?? Colors.white;
            return Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8, height: 8,
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                  ),
                  Text(z),
                ],
              ),
            );
          }).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _zones.map((zone) {
          final roots = _getRoots(visibleUsers, zone);
          if (roots.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline_rounded, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  Text('No team members in $zone zone',
                      style: TextStyle(fontFamily: 'Montserrat', color: Colors.grey.shade400, fontWeight: FontWeight.w600)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: roots.length,
            itemBuilder: (_, i) => _buildUserTree(roots[i], visibleUsers, zone, 0),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildUserTree(User user, List<User> allUsers, String zone, int depth) {
    final reports = _getReports(allUsers, user.id, zone);
    final roleColor = _getRoleColor(user.role);
    final isRoot = depth == 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── User Card ──
        Container(
          margin: EdgeInsets.only(left: depth * 20.0, bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border(left: BorderSide(color: roleColor, width: isRoot ? 4 : 2)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: roleColor.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                      style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w900, fontSize: 18, color: roleColor),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.name,
                          style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF0F172A))),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _roleBadge(user.role.label, roleColor),
                          const SizedBox(width: 6),
                          _zoneBadge(user.zone),
                        ],
                      ),
                      if (reports.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text('${reports.length} direct report${reports.length > 1 ? 's' : ''}',
                            style: TextStyle(fontFamily: 'Montserrat', fontSize: 9, color: Colors.grey.shade500, fontWeight: FontWeight.w600)),
                      ],
                    ],
                  ),
                ),
                // Tree line indicator
                if (depth > 0)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: roleColor.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
                    child: Icon(Icons.subdirectory_arrow_right_rounded, size: 14, color: roleColor),
                  ),
              ],
            ),
          ),
        ),

        // ── Connector line + reports ──
        if (reports.isNotEmpty) ...[
          Padding(
            padding: EdgeInsets.only(left: depth * 20.0 + 30),
            child: Row(
              children: [
                Container(width: 2, height: 12, color: roleColor.withOpacity(0.25)),
              ],
            ),
          ),
          ...reports.map((r) => _buildUserTree(r, allUsers, zone, depth + 1)),
          SizedBox(height: isRoot ? 16 : 8),
        ] else if (isRoot) ...[
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  Widget _roleBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(label.toUpperCase(),
          style: TextStyle(fontFamily: 'Montserrat', fontSize: 8, fontWeight: FontWeight.w900, color: color)),
    );
  }

  Widget _zoneBadge(String zone) {
    final color = _zoneColors[zone.toUpperCase()] ?? const Color(0xFF64748B);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(6)),
      child: Text(zone.toUpperCase(),
          style: TextStyle(fontFamily: 'Montserrat', fontSize: 8, fontWeight: FontWeight.w700, color: color)),
    );
  }
}
