import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser;

    return Scaffold(
      backgroundColor: NexusTheme.slate50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Settings', style: TextStyle(color: NexusTheme.slate900, fontWeight: FontWeight.w900, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Card
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: NexusTheme.primaryBlue.withOpacity(0.1),
                    child: Text(
                      (user?.name ?? 'U').substring(0, 1).toUpperCase(),
                      style: const TextStyle(color: NexusTheme.primaryBlue, fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.name ?? 'Unknown User',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: NexusTheme.slate900),
                  ),
                  Text(
                    user?.role.label ?? 'Role Not Assigned',
                    style: const TextStyle(fontSize: 14, color: NexusTheme.slate500, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: NexusTheme.primaryBlue.withOpacity(0.1),
                      foregroundColor: NexusTheme.primaryBlue,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Settings Menu
            _buildSection(context, 'Account Settings', [
              _buildMenuItem(Icons.person_outline_rounded, 'Personal Information'),
              _buildMenuItem(Icons.notifications_none_rounded, 'Notifications'),
              _buildMenuItem(Icons.lock_outline_rounded, 'Privacy & Security'),
            ]),
            
            const SizedBox(height: 12),
            
            _buildSection(context, 'Support', [
              _buildMenuItem(Icons.help_outline_rounded, 'Help Center'),
              _buildMenuItem(Icons.description_outlined, 'Terms of Service'),
            ]),
            
            const SizedBox(height: 32),
            
            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: () => _showLogoutDialog(context, auth),
                  icon: const Icon(Icons.logout_rounded, color: NexusTheme.error),
                  label: const Text('Log Out', style: TextStyle(color: NexusTheme.error, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: NexusTheme.error),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: NexusTheme.slate400, letterSpacing: 1),
          ),
        ),
        Container(
          color: Colors.white,
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: NexusTheme.slate600, size: 22),
      title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: NexusTheme.slate800)),
      trailing: const Icon(Icons.chevron_right_rounded, color: NexusTheme.slate300),
      onTap: () {},
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out of Nexus OMS?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: NexusTheme.slate500)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              auth.logout();
            },
            child: const Text('Log Out', style: TextStyle(color: NexusTheme.error, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
