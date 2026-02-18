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

  // All workflow steps
  final List<Map<String, dynamic>> _workflowSteps = [
    {'label': 'New Customer', 'icon': Icons.person_add_rounded, 'color': Colors.indigo},
    {'label': 'Book Order', 'icon': Icons.add_shopping_cart_rounded, 'color': Colors.lightBlue},
    {'label': 'Stock Transfer', 'icon': Icons.sync_alt_rounded, 'color': Colors.amber},
    {'label': 'Clearance', 'icon': Icons.cleaning_services_rounded, 'color': Colors.blueGrey},
    {'label': 'Credit Control', 'icon': Icons.bolt_rounded, 'color': Colors.orange},
    {'label': 'Credit Alerts', 'icon': Icons.warning_amber_rounded, 'color': Colors.red},
    {'label': 'Warehouse Operations', 'icon': Icons.inventory_2_rounded, 'color': Colors.brown},
    {'label': 'Quality Control (QC)', 'icon': Icons.verified_user_rounded, 'color': Colors.green},
    {'label': 'Logistics Costing', 'icon': Icons.currency_rupee_rounded, 'color': Colors.deepPurple},
    {'label': 'Invoicing', 'icon': Icons.receipt_long_rounded, 'color': Colors.blue},
    {'label': 'Fleet Loading (Hub)', 'icon': Icons.local_shipping_rounded, 'color': Colors.purple},
    {'label': 'Delivery Execution', 'icon': Icons.task_alt_rounded, 'color': Colors.redAccent},
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

  Future<void> _updateAllowedSteps(String userId, List<String> steps) async {
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final response = await http.patch(
        Uri.parse('${ApiConfig.baseUrl}/users/$userId/allowed-steps'),
        headers: auth.authHeaders,
        body: json.encode({'allowedSteps': steps}),
      );
      if (response.statusCode == 200) {
        _fetchUsers();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Steps updated!'), backgroundColor: Colors.green),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _showAssignUsersDialog(String stepLabel) {
    // Get users currently assigned to this step
    List<String> assignedUserIds = _users
        .where((u) => u.allowedSteps.contains(stepLabel))
        .map((u) => u.id)
        .toList();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Column(
                children: [
                  Icon(_workflowSteps.firstWhere((s) => s['label'] == stepLabel)['icon'] as IconData,
                      color: _workflowSteps.firstWhere((s) => s['label'] == stepLabel)['color'] as Color, size: 36),
                  const SizedBox(height: 8),
                  Text(stepLabel.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1)),
                  const SizedBox(height: 4),
                  const Text('Select users for this step', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.normal)),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                height: 400,
                child: ListView.builder(
                  itemCount: _users.length,
                  itemBuilder: (context, index) {
                    final user = _users[index];
                    if (user.role.label == 'Admin') return const SizedBox.shrink(); // Skip Admin
                    final isAssigned = assignedUserIds.contains(user.id);

                    return CheckboxListTile(
                      value: isAssigned,
                      onChanged: (val) {
                        setDialogState(() {
                          if (val!) {
                            assignedUserIds.add(user.id);
                          } else {
                            assignedUserIds.remove(user.id);
                          }
                        });
                      },
                      activeColor: NexusTheme.emerald500,
                      title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: Text(user.role.label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      secondary: CircleAvatar(
                        radius: 16,
                        backgroundColor: isAssigned ? NexusTheme.emerald100 : NexusTheme.slate100,
                        child: Text(user.name[0], style: TextStyle(
                          color: isAssigned ? NexusTheme.emerald700 : NexusTheme.slate400,
                          fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('CANCEL', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    // Update each user's allowedSteps
                    for (final user in _users) {
                      if (user.role.label == 'Admin') continue;
                      
                      List<String> updatedSteps = List.from(user.allowedSteps);
                      bool shouldHaveStep = assignedUserIds.contains(user.id);
                      bool hasStep = updatedSteps.contains(stepLabel);

                      if (shouldHaveStep && !hasStep) {
                        updatedSteps.add(stepLabel);
                      } else if (!shouldHaveStep && hasStep) {
                        updatedSteps.remove(stepLabel);
                      } else {
                        continue; // No change needed
                      }
                      
                      await _updateAllowedSteps(user.id, updatedSteps);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: NexusTheme.emerald500,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('SAVE', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('STEP ASSIGNMENT CONTROL', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1)),
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

                // Find users assigned to this step
                final assignedUsers = _users.where((u) => u.allowedSteps.contains(stepLabel)).toList();

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
                        onTap: () => _showAssignUsersDialog(stepLabel),
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
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: assignedUsers.isEmpty ? Colors.orange.shade50 : NexusTheme.emerald50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${assignedUsers.length} USERS',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    color: assignedUsers.isEmpty ? Colors.orange : NexusTheme.emerald600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(Icons.edit_note_rounded, color: stepColor, size: 24),
                            ],
                          ),
                        ),
                      ),

                      // Assigned Users List
                      if (assignedUsers.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: assignedUsers.map((user) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F172A),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircleAvatar(
                                    radius: 10,
                                    backgroundColor: stepColor,
                                    child: Text(user.name[0], style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(user.name.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)),
                                ],
                              ),
                            )).toList(),
                          ),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                          child: Text(
                            'No users assigned — Tap to add',
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade400, fontStyle: FontStyle.italic),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
