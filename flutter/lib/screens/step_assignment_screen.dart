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
    // Build a map of userId -> access level for this step
    Map<String, String> userAccessMap = {};
    for (final user in _users) {
      if (user.role.label == 'Admin') continue;
      userAccessMap[user.id] = user.stepAccess[stepLabel] ?? 'no';
    }

    // Grouping logic for Zone segregation
    Map<String, List<User>> groupedUsers = {
      'NORTH': [],
      'WEST': [],
      'EAST': [],
      'SOUTH': [],
      'PAN INDIA': [],
    };
    
    for (var u in _users) {
      if (u.role.label == 'Admin') continue;
      String z = u.zone.toUpperCase();
      if (!groupedUsers.containsKey(z)) groupedUsers[u.zone] = [];
      groupedUsers[z]!.add(u);
    }

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.3),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (ctx, anim1, anim2) => const SizedBox(),
      transitionBuilder: (ctx, anim1, anim2, child) {
        return BackdropFilter(
          filter: ColorFilter.mode(
            Colors.white.withOpacity(0.1),
            BlendMode.srcOver,
          ),
          child: FadeTransition(
            opacity: anim1,
            child: ScaleTransition(
              scale: anim1,
              child: AlertDialog(
                backgroundColor: Colors.white.withOpacity(0.9),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                title: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: stepColor.withOpacity(0.1), shape: BoxShape.circle),
                      child: Icon(stepIcon, color: stepColor, size: 32),
                    ),
                    const SizedBox(height: 12),
                    Text(stepLabel.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.2)),
                    const SizedBox(height: 4),
                    const Text('Configure zone-wise access control', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w500)),
                  ],
                ),
                content: StatefulBuilder(
                  builder: (ctx, setDialogState) {
                    return SizedBox(
                      width: double.maxFinite,
                      height: 450,
                      child: ListView(
                        physics: const BouncingScrollPhysics(),
                        children: groupedUsers.entries.where((e) => e.value.isNotEmpty).map((entry) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 16, bottom: 8, left: 4),
                                child: Text(
                                  entry.key,
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.blueGrey.shade700, letterSpacing: 1),
                                ),
                              ),
                              ...entry.value.map((user) {
                                final access = userAccessMap[user.id] ?? 'no';
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 2))],
                                    border: Border.all(
                                      color: access == 'full' ? NexusTheme.emerald300 
                                           : access == 'view' ? Colors.blue.shade200 
                                           : Colors.grey.shade100,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 14,
                                        backgroundColor: access == 'full' ? NexusTheme.emerald500 
                                                       : access == 'view' ? Colors.blue 
                                                       : Colors.grey.shade200,
                                        child: Text(user.name[0], style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(user.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11)),
                                            Text(user.role.label, style: const TextStyle(fontSize: 8, color: Colors.grey)),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade50,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                            value: access,
                                            isDense: true,
                                            icon: const Icon(Icons.arrow_drop_down, size: 16),
                                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900),
                                            items: const [
                                              DropdownMenuItem(value: 'full', child: Text('✅ FULL', style: TextStyle(color: Color(0xFF059669)))),
                                              DropdownMenuItem(value: 'view', child: Text('👁️ VIEW', style: TextStyle(color: Color(0xFF2563EB)))),
                                              DropdownMenuItem(value: 'no', child: Text('❌ NO', style: TextStyle(color: Color(0xFFDC2626)))),
                                            ],
                                            onChanged: (val) {
                                              setDialogState(() {
                                                userAccessMap[user.id] = val!;
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ],
                          );
                        }).toList(),
                      ),
                    );
                  }
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('CANCEL', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 11)),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      for (final user in _users) {
                        if (user.role.label == 'Admin') continue;
                        final newAccess = userAccessMap[user.id] ?? 'no';
                        final oldAccess = user.stepAccess[stepLabel] ?? 'no';
                        
                        if (newAccess != oldAccess) {
                          Map<String, String> updated = Map.from(user.stepAccess);
                          updated[stepLabel] = newAccess;
                          await _updateStepAccess(user.id, updated);
                        }
                      }
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('✅ Access updated mapping to Zone!'), backgroundColor: Colors.black87),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black87,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text('SAVE CHANGES', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
