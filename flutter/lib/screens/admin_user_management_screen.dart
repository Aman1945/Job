import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/theme.dart';
import '../models/models.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class AdminUserManagementScreen extends StatefulWidget {
  const AdminUserManagementScreen({super.key});

  @override
  State<AdminUserManagementScreen> createState() => _AdminUserManagementScreenState();
}

class _AdminUserManagementScreenState extends State<AdminUserManagementScreen> {
  List<User> _users = [];
  bool _isLoading = true;

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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching users: $e')),
        );
      }
    }
  }

  Future<void> _updatePermissions(String userId, List<String> permissions) async {
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final response = await http.patch(
        Uri.parse('${ApiConfig.baseUrl}/users/$userId/permissions'),
        headers: auth.authHeaders,
        body: json.encode({'permissions': permissions}),
      );

      if (response.statusCode == 200) {
        _fetchUsers();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Permissions updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating permissions: $e')),
        );
      }
    }
  }

  void _showPermissionDialog(User user) {
    showDialog(
      context: context,
      builder: (context) => PermissionDialog(
        user: user,
        onSave: (permissions) {
          _updatePermissions(user.id, permissions);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NexusTheme.slate50,
      appBar: AppBar(
        title: const Text('USER MANAGEMENT', style: TextStyle(fontWeight: FontWeight.w900)),
        actions: [
          IconButton(onPressed: _fetchUsers, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: NexusTheme.emerald500))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _users.length,
              itemBuilder: (context, index) {
                final user = _users[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: NexusTheme.emerald100,
                      child: Text(user.name[0], style: const TextStyle(color: NexusTheme.emerald700, fontWeight: FontWeight.bold)),
                    ),
                    title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(user.id, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: Colors.blueGrey.shade50, borderRadius: BorderRadius.circular(4)),
                              child: Text(user.zone, style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade700)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Permission chips
                        if (user.permissions.isNotEmpty)
                          Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: user.permissions.map((perm) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: NexusTheme.indigo100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _formatPermission(perm),
                                style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: NexusTheme.indigo600),
                              ),
                            )).toList(),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'NO PERMISSIONS SET',
                              style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.orange),
                            ),
                          ),
                      ],
                    ),
                    trailing: IconButton(
                      onPressed: () => _showPermissionDialog(user),
                      icon: const Icon(Icons.security_rounded, color: NexusTheme.emerald500, size: 28),
                      tooltip: 'Manage Access',
                    ),  
                  ),
                );
              },
            ),
    );
  }

  String _formatPermission(String perm) {
    return perm.replaceAll('_', ' ').toUpperCase();
  }
}

// Permission Dialog Widget
class PermissionDialog extends StatefulWidget {
  final User user;
  final Function(List<String>) onSave;

  const PermissionDialog({
    super.key,
    required this.user,
    required this.onSave,
  });

  @override
  State<PermissionDialog> createState() => _PermissionDialogState();
}

class _PermissionDialogState extends State<PermissionDialog> {
  late List<String> selectedPermissions;

  final Map<String, String> permissionLabels = {
    'view_orders': '📋 View Orders',
    'create_orders': '➕ Create Orders',
    'approve_credit': '💳 Approve Credit',
    'manage_warehouse': '📦 Manage Warehouse',
    'quality_control': '✅ Quality Control',
    'logistics_costing': '🚚 Logistics Costing',
    'invoicing': '📄 Invoicing',
    'fleet_loading': '🚛 Fleet Loading',
    'delivery': '🏠 Delivery',
    'procurement': '🏭 Procurement',
    'admin_bypass': '⚡ Admin Bypass',
    'user_management': '👥 User Management',
    'master_data': '🗄️ Master Data',
  };

  @override
  void initState() {
    super.initState();
    selectedPermissions = List.from(widget.user.permissions);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Column(
        children: [
          const Icon(Icons.security, color: NexusTheme.emerald500, size: 40),
          const SizedBox(height: 12),
          Text(
            'Manage Access',
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
          ),
          const SizedBox(height: 4),
          Text(
            widget.user.name,
            style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.normal),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView(
          shrinkWrap: true,
          children: permissionLabels.entries.map((entry) {
            final perm = entry.key;
            final label = entry.value;
            final isSelected = selectedPermissions.contains(perm);

            return CheckboxListTile(
              value: isSelected,
              onChanged: (val) {
                setState(() {
                  if (val!) {
                    selectedPermissions.add(perm);
                  } else {
                    selectedPermissions.remove(perm);
                  }
                });
              },
              title: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              activeColor: NexusTheme.emerald500,
              contentPadding: EdgeInsets.zero,
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCEL', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onSave(selectedPermissions);
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: NexusTheme.emerald500,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('SAVE CHANGES', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
