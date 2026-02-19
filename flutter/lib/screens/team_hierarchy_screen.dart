import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/nexus_provider.dart';
import '../providers/auth_provider.dart';
import '../models/models.dart';

// ─────────────────────────────────────────────────────────────
// Department definition — each workflow dept
// ─────────────────────────────────────────────────────────────
class _Dept {
  final String title;
  final String stepLabel; // matches stepAccess key
  final IconData icon;
  final Color color;
  final List<UserRole> roles; // which DB roles belong here
  final List<String> tasks; // task chips
  final String? pushesTo; // next dept label this feeds into

  const _Dept({
    required this.title,
    required this.stepLabel,
    required this.icon,
    required this.color,
    required this.roles,
    required this.tasks,
    this.pushesTo,
  });
}

const List<_Dept> _departments = [
  _Dept(
    title: 'SALES TEAM',
    stepLabel: 'Book Order',
    icon: Icons.shopping_cart_rounded,
    color: Color(0xFF059669),
    roles: [UserRole.sales, UserRole.salesExecutive, UserRole.rsm, UserRole.asm],
    tasks: ['New Customer', 'Book Order', 'Stock Transfer', 'Clearance'],
    pushesTo: 'CREDIT CONTROL',
  ),
  _Dept(
    title: 'CREDIT CONTROL',
    stepLabel: 'Credit Control',
    icon: Icons.credit_score_rounded,
    color: Color(0xFF2563EB),
    roles: [UserRole.creditControl],
    tasks: ['Credit Control'],
    pushesTo: 'WH ASSIGNMENT',
  ),
  _Dept(
    title: 'WH ASSIGNMENT',
    stepLabel: 'Warehouse',
    icon: Icons.warehouse_rounded,
    color: Color(0xFFF59E0B),
    roles: [UserRole.whManager, UserRole.warehouse],
    tasks: ['Warehouse Assignment'],
    pushesTo: 'QC',
  ),
  _Dept(
    title: 'QC',
    stepLabel: 'QC',
    icon: Icons.verified_rounded,
    color: Color(0xFF7C3AED),
    roles: [UserRole.qcHead],
    tasks: ['Quality Control'],
    pushesTo: 'INVOICING',
  ),
  _Dept(
    title: 'INVOICING',
    stepLabel: 'Invoicing',
    icon: Icons.receipt_long_rounded,
    color: Color(0xFFDC2626),
    roles: [UserRole.billing],
    tasks: ['Invoicing'],
    pushesTo: 'LOGISTICS COST',
  ),
  _Dept(
    title: 'LOGISTICS COST',
    stepLabel: 'Logistics Costing',
    icon: Icons.price_change_rounded,
    color: Color(0xFF0891B2),
    roles: [UserRole.logisticsLead],
    tasks: ['Logistics Cost'],
    pushesTo: 'LOGISTICS HUB',
  ),
  _Dept(
    title: 'LOGISTICS HUB',
    stepLabel: 'Logistics',
    icon: Icons.local_shipping_rounded,
    color: Color(0xFF475569),
    roles: [UserRole.logisticsTeam],
    tasks: ['Logistics Hub', 'Dispatch'],
    pushesTo: null,
  ),
];

// ─────────────────────────────────────────────────────────────

class TeamHierarchyScreen extends StatefulWidget {
  const TeamHierarchyScreen({super.key});

  @override
  State<TeamHierarchyScreen> createState() => _TeamHierarchyScreenState();
}

class _TeamHierarchyScreenState extends State<TeamHierarchyScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _zones = ['ALL', 'NORTH', 'WEST', 'EAST', 'SOUTH', 'PAN INDIA'];

  final Map<String, Color> _zoneColors = {
    'NORTH': const Color(0xFF3B82F6),
    'WEST': const Color(0xFFF59E0B),
    'EAST': const Color(0xFF10B981),
    'SOUTH': const Color(0xFFEF4444),
    'PAN INDIA': const Color(0xFF8B5CF6),
    'ALL': const Color(0xFF0F172A),
  };

  // Main page tabs
  late TabController _pageTabCtrl;
  // Workflow zone tabs
  late TabController _workflowZoneCtrl;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _zones.length, vsync: this);
    _pageTabCtrl = TabController(length: 2, vsync: this);
    _workflowZoneCtrl = TabController(length: _zones.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageTabCtrl.dispose();
    _workflowZoneCtrl.dispose();
    super.dispose();
  }

  // ── Helpers for hierarchy tree ──────────────────────────────

  List<User> _getRoots(List<User> allUsers, String zone) {
    return allUsers.where((u) {
      if (u.role == UserRole.admin) return false;
      final zoneMatch = zone == 'ALL' || u.zone.toUpperCase() == zone;
      final isRoot = u.managerId == null ||
          u.managerId!.isEmpty ||
          !allUsers.any((o) => o.id == u.managerId);
      return zoneMatch && isRoot;
    }).toList()
      ..sort((a, b) => _roleRank(a.role).compareTo(_roleRank(b.role)));
  }

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

  Color _roleColor(UserRole r) {
    const m = {
      UserRole.rsm: Color(0xFF7C3AED),
      UserRole.asm: Color(0xFF2563EB),
      UserRole.sales: Color(0xFF059669),
      UserRole.salesExecutive: Color(0xFF059669),
    };
    return m[r] ?? const Color(0xFF64748B);
  }



  // ── BUILD ────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final nexus = Provider.of<NexusProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final currentUser = auth.currentUser;

    List<User> allUsers = nexus.users.where((u) => u.role != UserRole.admin).toList();

    // Restrict visible users based on role
    if (currentUser != null && (currentUser.role == UserRole.rsm || currentUser.role == UserRole.asm)) {
      final ids = nexus.getTeamMemberIds(currentUser);
      allUsers = allUsers.where((u) => ids.contains(u.id) || u.id == currentUser.id).toList();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('TEAM DIRECTORY',
                style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1)),
            Text('Hierarchy & Workflow',
                style: TextStyle(fontFamily: 'Montserrat', fontSize: 10, color: Colors.white54)),
          ],
        ),
        bottom: TabBar(
          controller: _pageTabCtrl,
          indicatorColor: const Color(0xFF10B981),
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w800, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w500, fontSize: 11),
          tabs: const [
            Tab(icon: Icon(Icons.account_tree_rounded, size: 16), text: 'HIERARCHY'),
            Tab(icon: Icon(Icons.alt_route_rounded, size: 16), text: 'WORKFLOW'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _pageTabCtrl,
        children: [
          _buildHierarchyTab(allUsers),
          _buildWorkflowTab(nexus.users), // workflow uses ALL users for assignment check
        ],
      ),
    );
  }

  // ── TAB 1: Hierarchy Tree ────────────────────────────────────

  Widget _buildHierarchyTab(List<User> allUsers) {
    return Column(
      children: [
        // Zone tabs
        Container(
          color: const Color(0xFF0F172A),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: Colors.white,
            indicatorWeight: 2,
            labelStyle: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w800, fontSize: 10, letterSpacing: 0.5),
            unselectedLabelStyle: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w400, fontSize: 10),
            tabs: _zones.map((z) {
              final color = _zoneColors[z] ?? Colors.white;
              return Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 7, height: 7, margin: const EdgeInsets.only(right: 5),
                        decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                    Text(z),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: _zones.map((zone) {
              final roots = _getRoots(allUsers, zone);
              if (roots.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline_rounded, size: 56, color: Colors.grey.shade300),
                      const SizedBox(height: 12),
                      Text('No team members in $zone',
                          style: TextStyle(fontFamily: 'Montserrat', color: Colors.grey.shade400, fontWeight: FontWeight.w600)),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: roots.length,
                itemBuilder: (_, i) => _buildUserTree(roots[i], allUsers, zone, 0),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildUserTree(User user, List<User> all, String zone, int depth) {
    final reports = _getReports(all, user.id, zone);
    final rc = _roleColor(user.role);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(left: depth * 18.0, bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border(left: BorderSide(color: rc, width: depth == 0 ? 4 : 2)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(color: rc.withOpacity(0.1), shape: BoxShape.circle),
                  child: Center(child: Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                      style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w900, fontSize: 16, color: rc))),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.name, style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w800, fontSize: 12, color: Color(0xFF0F172A))),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _chip(user.role.label, rc),
                          const SizedBox(width: 4),
                          _chip(user.zone, _zoneColors[user.zone.toUpperCase()] ?? Colors.grey),
                        ],
                      ),
                      if (reports.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 3),
                          child: Text('${reports.length} report${reports.length > 1 ? 's' : ''}',
                              style: TextStyle(fontFamily: 'Montserrat', fontSize: 9, color: Colors.grey.shade400, fontWeight: FontWeight.w600)),
                        ),
                    ],
                  ),
                ),
                if (depth > 0)
                  Icon(Icons.subdirectory_arrow_right_rounded, size: 14, color: rc.withOpacity(0.5)),
              ],
            ),
          ),
        ),
        if (reports.isNotEmpty) ...[
          Padding(
            padding: EdgeInsets.only(left: depth * 18.0 + 28),
            child: Container(width: 2, height: 10, color: rc.withOpacity(0.2)),
          ),
          ...reports.map((r) => _buildUserTree(r, all, zone, depth + 1)),
          SizedBox(height: depth == 0 ? 12 : 6),
        ] else if (depth == 0)
          const SizedBox(height: 8),
      ],
    );
  }

  // ── TAB 2: Workflow Departments (zone-filtered) ─────────────

  Widget _buildWorkflowTab(List<User> allUsers) {
    return Column(
      children: [
        // Zone filter tabs
        Container(
          color: const Color(0xFF0F172A),
          child: TabBar(
            controller: _workflowZoneCtrl,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: Colors.white,
            indicatorWeight: 2,
            labelStyle: const TextStyle(
                fontFamily: 'Montserrat', fontWeight: FontWeight.w800, fontSize: 10, letterSpacing: 0.5),
            unselectedLabelStyle: const TextStyle(
                fontFamily: 'Montserrat', fontWeight: FontWeight.w400, fontSize: 10),
            tabs: _zones.map((z) {
              final color = _zoneColors[z] ?? Colors.white;
              return Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                        width: 7, height: 7,
                        margin: const EdgeInsets.only(right: 5),
                        decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                    Text(z),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        // Zone tab content
        Expanded(
          child: TabBarView(
            controller: _workflowZoneCtrl,
            children: _zones.map((selectedZone) {
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                itemCount: _departments.length,
                itemBuilder: (_, i) {
                  final dept = _departments[i];
                  final isLast = i == _departments.length - 1;
                  return Column(
                    children: [
                      _buildDeptCard(dept, allUsers, selectedZone),
                      if (!isLast) _buildArrow(dept.pushesTo),
                    ],
                  );
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildArrow(String? nextDept) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          Container(width: 2, height: 12, color: Colors.grey.shade300),
          Icon(Icons.arrow_downward_rounded, size: 16, color: Colors.grey.shade400),
          if (nextDept != null)
            Text('→ $nextDept',
                style: TextStyle(fontFamily: 'Montserrat', fontSize: 8, color: Colors.grey.shade400, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildDeptCard(_Dept dept, List<User> allUsers, String selectedZone) {
    // Filter users by: role in dept + zone match + admin has assigned them (full/view)
    final zoneUsers = allUsers.where((u) {
      final zoneMatch = selectedZone == 'ALL' || u.zone.toUpperCase() == selectedZone;
      return dept.roles.contains(u.role) && zoneMatch;
    }).toList();

    // Assigned = has full/view stepAccess for this step
    final assignedUsers = zoneUsers.where((u) {
      final access = u.stepAccess[dept.stepLabel] ?? 'no';
      return access == 'full' || access == 'view';
    }).toList();

    // Unassigned role users (has role but no stepAccess set yet)
    final unassignedUsers = zoneUsers.where((u) {
      final access = u.stepAccess[dept.stepLabel] ?? 'no';
      return access == 'no';
    }).toList();

    // Red card if NO user in this zone has access to the step
    final isUnassigned = assignedUsers.isEmpty;
    final borderColor = isUnassigned ? const Color(0xFFDC2626) : dept.color;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isUnassigned ? const Color(0xFFDC2626) : dept.color.withOpacity(0.3),
          width: isUnassigned ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isUnassigned ? const Color(0xFFDC2626).withOpacity(0.08) : Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            decoration: BoxDecoration(
              color: isUnassigned ? const Color(0xFFDC2626).withOpacity(0.05) : dept.color.withOpacity(0.06),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isUnassigned ? const Color(0xFFDC2626).withOpacity(0.1) : dept.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(dept.icon, color: isUnassigned ? const Color(0xFFDC2626) : dept.color, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(dept.title,
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                            color: isUnassigned ? const Color(0xFFDC2626) : const Color(0xFF0F172A),
                            letterSpacing: 0.5,
                          )),
                      const SizedBox(height: 3),
                      Wrap(
                        spacing: 4,
                        children: dept.tasks.map((t) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: dept.color.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(t.toUpperCase(),
                              style: TextStyle(fontFamily: 'Montserrat', fontSize: 7, fontWeight: FontWeight.w800, color: dept.color)),
                        )).toList(),
                      ),
                    ],
                  ),
                ),
                // Unassigned warning badge
                if (isUnassigned)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFDC2626), borderRadius: BorderRadius.circular(8)),
                    child: const Text('⚠ UNASSIGNED',
                        style: TextStyle(fontFamily: 'Montserrat', fontSize: 7, fontWeight: FontWeight.w900, color: Colors.white)),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: dept.color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text('${(assignedUsers.length + unassignedUsers.length)} USER${(assignedUsers.length + unassignedUsers.length) != 1 ? 'S' : ''}',
                        style: TextStyle(fontFamily: 'Montserrat', fontSize: 7, fontWeight: FontWeight.w900, color: dept.color)),
                  ),
              ],
            ),
          ),

          // ── Assigned Users ──
          if (assignedUsers.isEmpty && unassignedUsers.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.person_off_rounded, size: 16, color: Colors.red.shade300),
                  const SizedBox(width: 8),
                  Text(selectedZone == 'ALL'
                      ? 'No users with this role in database'
                      : 'No users with this role in $selectedZone zone',
                      style: TextStyle(fontFamily: 'Montserrat', fontSize: 11,
                          color: Colors.red.shade300, fontWeight: FontWeight.w600)),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Assigned (green/normal)
                  if (assignedUsers.isNotEmpty) ...[
                    Text('ASSIGNED',
                        style: TextStyle(fontFamily: 'Montserrat', fontSize: 8,
                            fontWeight: FontWeight.w900, color: dept.color)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8, runSpacing: 8,
                      children: assignedUsers.map((u) => _buildUserChip(u, dept, true)).toList(),
                    ),
                  ],
                  // Unassigned role users (red warning)
                  if (unassignedUsers.isNotEmpty) ...[
                    SizedBox(height: assignedUsers.isNotEmpty ? 12 : 0),
                    Text('NOT YET ASSIGNED',
                        style: TextStyle(fontFamily: 'Montserrat', fontSize: 8,
                            fontWeight: FontWeight.w900, color: Colors.red.shade400)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8, runSpacing: 8,
                      children: unassignedUsers.map((u) => _buildUserChip(u, dept, false)).toList(),
                    ),
                  ],
                ],
              ),
            ),

          // ── Push to next ──
          if (dept.pushesTo != null)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                border: Border(top: BorderSide(color: Colors.grey.shade100)),
              ),
              child: Row(
                children: [
                  Icon(Icons.arrow_circle_down_rounded, size: 14, color: borderColor.withOpacity(0.6)),
                  const SizedBox(width: 6),
                  Text('Pushes to  ',
                      style: TextStyle(fontFamily: 'Montserrat', fontSize: 9, color: Colors.grey.shade400, fontWeight: FontWeight.w500)),
                  Text(dept.pushesTo!,
                      style: TextStyle(fontFamily: 'Montserrat', fontSize: 10, fontWeight: FontWeight.w900, color: borderColor)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUserChip(User user, _Dept dept, bool hasAccess) {
    final isWH = dept.roles.contains(UserRole.whManager) || dept.roles.contains(UserRole.warehouse);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: hasAccess ? dept.color.withOpacity(0.07) : Colors.red.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: hasAccess ? dept.color.withOpacity(0.2) : Colors.red.shade200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 22, height: 22,
                decoration: BoxDecoration(
                  color: hasAccess ? dept.color.withOpacity(0.15) : Colors.red.shade100,
                  shape: BoxShape.circle,
                ),
                child: Center(child: Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                    style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w900, fontSize: 11,
                        color: hasAccess ? dept.color : Colors.red.shade400))),
              ),
              const SizedBox(width: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.name,
                      style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700, fontSize: 11,
                          color: hasAccess ? const Color(0xFF0F172A) : Colors.red.shade600)),
                  // WH: show warehouse location
                  if (isWH && user.location.isNotEmpty && user.location != 'Pan India')
                    Text(user.location.toUpperCase(),
                        style: TextStyle(fontFamily: 'Montserrat', fontSize: 8, fontWeight: FontWeight.w900, color: dept.color)),
                ],
              ),
            ],
          ),
          // Access badge
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: hasAccess ? dept.color.withOpacity(0.1) : Colors.red.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              hasAccess ? (user.stepAccess[dept.stepLabel] ?? 'assigned').toUpperCase() : '⚠ NOT ASSIGNED',
              style: TextStyle(fontFamily: 'Montserrat', fontSize: 7, fontWeight: FontWeight.w900,
                  color: hasAccess ? dept.color : Colors.red.shade600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(5)),
      child: Text(label.toUpperCase(),
          style: TextStyle(fontFamily: 'Montserrat', fontSize: 7, fontWeight: FontWeight.w900, color: color)),
    );
  }
}
