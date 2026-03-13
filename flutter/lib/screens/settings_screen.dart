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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: NexusTheme.slate700, size: 20),
          onPressed: () {},
        ),
        title: const Text('Profile & Settings', style: TextStyle(color: NexusTheme.slate900, fontWeight: FontWeight.w900, fontSize: 18)),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert_rounded, color: NexusTheme.slate700), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),
            // Profile Header
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: NexusTheme.slate50, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const CircleAvatar(
                      radius: 68,
                      backgroundColor: NexusTheme.slate200,
                      backgroundImage: NetworkImage('https://i.pravatar.cc/300?u=alexander_wright'), // Visual match for screenshot
                    ),
                  ),
                  Positioned(
                    right: 4,
                    bottom: 4,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: NexusTheme.blue600,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.edit_rounded, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              user?.name ?? 'Alexander Wright',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: NexusTheme.slate900, letterSpacing: -0.5),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: NexusTheme.blue50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'SENIOR OPERATIONS MANAGER',
                style: TextStyle(color: NexusTheme.blue600, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_on_rounded, color: NexusTheme.slate400, size: 16),
                const SizedBox(width: 4),
                Text(
                  'North America Region | ID: ${user?.id.substring(0, 5).toUpperCase() ?? "88291"}',
                  style: const TextStyle(color: NexusTheme.slate500, fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            
            const SizedBox(height: 48),
            
            // Account Management Section
            _buildSectionHeader('ACCOUNT MANAGEMENT'),
            _buildMenuItem(
              icon: Icons.person_rounded,
              iconColor: NexusTheme.blue600,
              bgColor: NexusTheme.blue50,
              title: 'Personal Information',
              subtitle: 'Email, phone, and address',
            ),
            _buildMenuItem(
              icon: Icons.shield_rounded,
              iconColor: NexusTheme.blue600,
              bgColor: NexusTheme.blue50,
              title: 'Security & Privacy',
              subtitle: 'Password, 2FA, and biometrics',
            ),
            
            const SizedBox(height: 32),
            
            // Preferences Section
            _buildSectionHeader('PREFERENCES'),
            _buildMenuItem(
              icon: Icons.notifications_rounded,
              iconColor: NexusTheme.slate600,
              bgColor: NexusTheme.slate50,
              title: 'Notifications',
              subtitle: 'Push, email, and alert rules',
            ),
            _buildMenuItem(
              icon: Icons.language_rounded,
              iconColor: NexusTheme.slate600,
              bgColor: NexusTheme.slate50,
              title: 'Language & Region',
              subtitle: 'English (US), PDT Timezone',
            ),
            
            const SizedBox(height: 32),
            
            // System Section
            _buildSectionHeader('SYSTEM'),
            _buildMenuItem(
              icon: Icons.info_rounded,
              iconColor: NexusTheme.slate600,
              bgColor: NexusTheme.slate50,
              title: 'System Info',
              subtitle: 'Version 4.12.0-stable',
            ),
            
            const SizedBox(height: 40),
            
            // Sign Out Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: TextButton.icon(
                  onPressed: () => auth.logout(),
                  icon: const Icon(Icons.logout_rounded, color: NexusTheme.error, size: 20),
                  label: const Text('Sign Out', style: TextStyle(color: NexusTheme.error, fontWeight: FontWeight.w900, fontSize: 16)),
                  style: TextButton.styleFrom(
                    backgroundColor: NexusTheme.slate50.withOpacity(0.5),
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: NexusTheme.slate400, letterSpacing: 1),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String subtitle,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: NexusTheme.slate900)),
          subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: NexusTheme.slate500, fontWeight: FontWeight.w600)),
          trailing: const Icon(Icons.chevron_right_rounded, color: NexusTheme.slate300),
          onTap: () {},
        ),
        Padding(
          padding: const EdgeInsets.only(left: 88, right: 24),
          child: Divider(color: NexusTheme.slate100, height: 1),
        ),
      ],
    );
  }
}
