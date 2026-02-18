import 'package:flutter/material.dart';
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
    {'label': 'Master Creation', 'icon': Icons.app_registration_rounded, 'color': Colors.indigo},
    {'label': 'Placed Order', 'icon': Icons.shopping_cart_checkout_rounded, 'color': Colors.lightBlue},
    {'label': 'Credit Approv.', 'icon': Icons.verified_rounded, 'color': Colors.orange},
    {'label': 'Warehouse', 'icon': Icons.inventory_2_rounded, 'color': Colors.brown},
    {'label': 'Packing', 'icon': Icons.inventory_rounded, 'color': Colors.amber},
    {'label': 'QC', 'icon': Icons.verified_user_rounded, 'color': Colors.green},
    {'label': 'Logistic Cost', 'icon': Icons.currency_rupee_rounded, 'color': Colors.deepPurple},
    {'label': 'Invoice', 'icon': Icons.receipt_long_rounded, 'color': Colors.blue},
    {'label': 'DA Assignment', 'icon': Icons.assignment_turned_in_rounded, 'color': Colors.blueGrey},
    {'label': 'Loading', 'icon': Icons.local_shipping_rounded, 'color': Colors.purple},
    {'label': 'Delivery Ack', 'icon': Icons.task_alt_rounded, 'color': Colors.redAccent},
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
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStepAccess(String userId, Map<String, String> stepAccess) async {
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final response = await http.patch(
        Uri.parse('${ApiConfig.baseUrl}/users/$userId/step-access'),
        headers: auth.authHeaders,
        body: json.encode({'stepAccess': stepAccess}),
      );
      if (response.statusCode == 200) {
        _fetchUsers();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _showStepUsersDialog(String stepLabel, Color stepColor, IconData stepIcon) {
    // Build userId -> access map for this step
    Map<String, String> userAccessMap = {};
    for (final user in _users) {
      if (user.role.label == 'Admin') continue;
      userAccessMap[user.id] = user.stepAccess[stepLabel] ?? 'no';
    }

    // Zone grouping
    final zones = ['NORTH', 'WEST', 'EAST', 'SOUTH', 'PAN INDIA'];
    Map<String, List<User>> groupedUsers = {for (var z in zones) z: []};
    for (var u in _users) {
      if (u.role.label == 'Admin') continue;
      final z = u.zone.toUpperCase();
      if (groupedUsers.containsKey(z)) {
        groupedUsers[z]!.add(u);
      } else {
        groupedUsers[u.zone] = [u];
      }
    }
    final activeZones = zones.where((z) => (groupedUsers[z]?.isNotEmpty ?? false)).toList();

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.35),
      transitionDuration: const Duration(milliseconds: 380),
      pageBuilder: (ctx, anim1, anim2) => const SizedBox(),
      transitionBuilder: (ctx, anim1, anim2, child) {
        final curved = CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.12),
              end: Offset.zero,
            ).animate(curved),
            child: StatefulBuilder(
              builder: (ctx, setDialogState) {
                String selectedZone = activeZones.isNotEmpty ? activeZones[0] : '';
                final zoneUsers = groupedUsers[selectedZone] ?? [];

                // Helper: set all users in a zone to a given access level
                void selectAllZone(String zone, String access) {
                  setDialogState(() {
                    for (final u in groupedUsers[zone] ?? []) {
                      userAccessMap[u.id] = access;
                    }
                  });
                }

                return StatefulBuilder(
                  builder: (ctx2, setZoneState) {
                    final currentZoneUsers = groupedUsers[selectedZone] ?? [];
                    return Dialog(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // ── HEADER ──
                          Container(
                            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                              border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: stepColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Icon(stepIcon, color: stepColor, size: 26),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            stepLabel.toUpperCase(),
                                            style: const TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontSize: 14,
                                              fontWeight: FontWeight.w900,
                                              color: Color(0xFF0F172A),
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Zone-wise access control',
                                            style: TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontSize: 10,
                                              color: Colors.grey.shade500,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => Navigator.pop(ctx),
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.close, size: 16, color: Color(0xFF64748B)),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                // ── ZONE TABS ──
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: activeZones.map((zone) {
                                      final isSelected = zone == selectedZone;
                                      return GestureDetector(
                                        onTap: () => setZoneState(() => selectedZone = zone),
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 200),
                                          curve: Curves.easeOut,
                                          margin: const EdgeInsets.only(right: 8),
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                          decoration: BoxDecoration(
                                            color: isSelected ? const Color(0xFF0F172A) : Colors.grey.shade100,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            zone,
                                            style: TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontSize: 10,
                                              fontWeight: FontWeight.w800,
                                              color: isSelected ? Colors.white : Colors.grey.shade600,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // ── SELECT ALL ROW ──
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                            child: Row(
                              children: [
                                Text(
                                  '${currentZoneUsers.length} people',
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 10,
                                    color: Colors.grey.shade500,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Spacer(),
                                _selectAllBtn('ALL FULL', const Color(0xFF059669), () => setZoneState(() => selectAllZone(selectedZone, 'full'))),
                                const SizedBox(width: 6),
                                _selectAllBtn('ALL VIEW', const Color(0xFF2563EB), () => setZoneState(() => selectAllZone(selectedZone, 'view'))),
                                const SizedBox(width: 6),
                                _selectAllBtn('CLEAR', Colors.grey.shade500, () => setZoneState(() => selectAllZone(selectedZone, 'no'))),
                              ],
                            ),
                          ),

                          // ── USER LIST ──
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 320),
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                              itemCount: currentZoneUsers.length,
                              itemBuilder: (_, i) {
                                final user = currentZoneUsers[i];
                                final access = userAccessMap[user.id] ?? 'no';
                                return TweenAnimationBuilder<double>(
                                  key: ValueKey('${user.id}_$selectedZone'),
                                  tween: Tween(begin: 0.0, end: 1.0),
                                  duration: Duration(milliseconds: 180 + i * 40),
                                  curve: Curves.easeOut,
                                  builder: (_, v, child) => Opacity(
                                    opacity: v,
                                    child: Transform.translate(
                                      offset: Offset(0, 12 * (1 - v)),
                                      child: child,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: access == 'full'
                                            ? const Color(0xFF10B981)
                                            : access == 'view'
                                                ? const Color(0xFF3B82F6)
                                                : Colors.grey.shade200,
                                        width: 1.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.03),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        AnimatedContainer(
                                          duration: const Duration(milliseconds: 200),
                                          width: 34, height: 34,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: access == 'full'
                                                ? const Color(0xFF10B981)
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
                                                fontSize: 13,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                user.name,
                                                style: const TextStyle(
                                                  fontFamily: 'Montserrat',
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 12,
                                                  color: Color(0xFF0F172A),
                                                ),
                                              ),
                                              Text(
                                                user.role.label,
                                                style: TextStyle(
                                                  fontFamily: 'Montserrat',
                                                  fontSize: 9,
                                                  color: Colors.grey.shade500,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Access toggle chips
                                        Row(
                                          children: ['full', 'view', 'no'].map((level) {
                                            final isActive = access == level;
                                            final color = level == 'full'
                                                ? const Color(0xFF059669)
                                                : level == 'view'
                                                    ? const Color(0xFF2563EB)
                                                    : Colors.grey.shade400;
                                            final label = level == 'full' ? '✓ FULL' : level == 'view' ? '◉ VIEW' : '✕';
                                            return GestureDetector(
                                              onTap: () => setZoneState(() => userAccessMap[user.id] = level),
                                              child: AnimatedContainer(
                                                duration: const Duration(milliseconds: 180),
                                                margin: const EdgeInsets.only(left: 4),
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: isActive ? color : Colors.grey.shade100,
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  label,
                                                  style: TextStyle(
                                                    fontFamily: 'Montserrat',
                                                    fontSize: 8,
                                                    fontWeight: FontWeight.w800,
                                                    color: isActive ? Colors.white : Colors.grey.shade400,
                                                  ),
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          // ── ACTIONS ──
                          Container(
                            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
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
                                      height: 46,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: const Center(
                                        child: Text('CANCEL',
                                            style: TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontWeight: FontWeight.w800,
                                              fontSize: 11,
                                              color: Color(0xFF64748B),
                                            )),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 2,
                                  child: GestureDetector(
                                    onTap: () async {
                                      Navigator.pop(ctx);
                                      for (final user in _users) {
                                        if (user.role.label == 'Admin') continue;
                                        final newAccess = userAccessMap[user.id] ?? 'no';
                                        final oldAccess = user.stepAccess[stepLabel] ?? 'no';
                                        if (newAccess != oldAccess) {
                                          final updated = Map<String, String>.from(user.stepAccess);
                                          updated[stepLabel] = newAccess;
                                          await _updateStepAccess(user.id, updated);
                                        }
                                      }
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('✅ Access updated!'),
                                            backgroundColor: Color(0xFF0F172A),
                                            behavior: SnackBarBehavior.floating,
                                          ),
                                        );
                                      }
                                    },
                                    child: Container(
                                      height: 46,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF0F172A),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: const Center(
                                        child: Text('SAVE CHANGES',
                                            style: TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontWeight: FontWeight.w900,
                                              fontSize: 11,
                                              color: Colors.white,
                                              letterSpacing: 0.5,
                                            )),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _selectAllBtn(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 8,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ),
    );
  }

  Color _accessColor(String access) {
    switch (access) {
      case 'full': return NexusTheme.emerald500;
      case 'view': return Colors.blue;
      default: return NexusTheme.slate300;
    }
  }

  String _accessLabel(String access) {
    switch (access) {
      case 'full': return 'FULL';
      case 'view': return 'VIEW';
      default: return 'NO';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('STEP ASSIGNMENT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(onPressed: _fetchUsers, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: NexusTheme.emerald500))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _workflowSteps.length,
              itemBuilder: (context, index) {
                final step = _workflowSteps[index];
                final stepLabel = step['label'] as String;
                final stepColor = step['color'] as Color;
                final stepIcon = step['icon'] as IconData;

                // Get users with access to this step
                final fullUsers = _users.where((u) => u.stepAccess[stepLabel] == 'full').toList();
                final viewUsers = _users.where((u) => u.stepAccess[stepLabel] == 'view').toList();

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Step Header
                      InkWell(
                        onTap: () => _showStepUsersDialog(stepLabel, stepColor, stepIcon),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: stepColor.withAlpha(20),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: stepColor.withAlpha(30),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(stepIcon, color: stepColor, size: 22),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('STAGE ${index + 1}', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: stepColor, letterSpacing: 1)),
                                    const SizedBox(height: 2),
                                    Text(stepLabel.toUpperCase(), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
                                  ],
                                ),
                              ),
                              // Access counts
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                decoration: BoxDecoration(color: NexusTheme.emerald50, borderRadius: BorderRadius.circular(6)),
                                child: Text('${fullUsers.length} FULL', style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: NexusTheme.emerald600)),
                              ),
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(6)),
                                child: Text('${viewUsers.length} VIEW', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.blue.shade600)),
                              ),
                              const SizedBox(width: 8),
                              Icon(Icons.edit_note_rounded, color: stepColor, size: 24),
                            ],
                          ),
                        ),
                      ),

                      // Users list
                      if (fullUsers.isNotEmpty || viewUsers.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              ...fullUsers.map((u) => _buildUserChip(u, 'full', stepColor)),
                              ...viewUsers.map((u) => _buildUserChip(u, 'view', stepColor)),
                            ],
                          ),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                          child: Text('No users assigned — Tap to configure', style: TextStyle(fontSize: 11, color: Colors.grey.shade400, fontStyle: FontStyle.italic)),
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildUserChip(User user, String access, Color stepColor) {
    final isFullAccess = access == 'full';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isFullAccess ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isFullAccess ? null : Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 9,
            backgroundColor: isFullAccess ? stepColor : Colors.blue,
            child: Text(user.name[0], style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 5),
          Text(
            user.name.split(' ')[0].toUpperCase(),
            style: TextStyle(
              color: isFullAccess ? Colors.white : Colors.blue.shade700,
              fontSize: 9,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            isFullAccess ? '✅' : '👁️',
            style: const TextStyle(fontSize: 9),
          ),
        ],
      ),
    );
  }
}
