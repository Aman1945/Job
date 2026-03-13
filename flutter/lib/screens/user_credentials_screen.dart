import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/models.dart';
import '../config/api_config.dart';

// ─────────────────────── PALETTE ──────────────────────────────
const _kBg     = Color(0xFFF0F4FA);
const _kDark   = Color(0xFF0D2137);
const _kTeal   = Color(0xFF1ABFA1);
const _kSub    = Color(0xFF7A8EA5);
const _kCard   = Colors.white;

class UserCredentialsScreen extends StatefulWidget {
  const UserCredentialsScreen({super.key});
  @override
  State<UserCredentialsScreen> createState() => _UserCredentialsScreenState();
}

class _UserCredentialsScreenState extends State<UserCredentialsScreen> {
  List<User> _users = [];
  bool _loading = true;
  String _search = '';
  User? _selectedUser;

  // Edit controllers
  final _nameCtrl     = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _userIdCtrl   = TextEditingController();
  final _addressCtrl  = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _saving = false;
  bool _showPassword = false;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _userIdCtrl.dispose();
    _addressCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchUsers() async {
    setState(() => _loading = true);
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final res = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/users'),
        headers: auth.authHeaders,
      );
      if (res.statusCode == 200) {
        final data = json.decode(res.body) as List;
        setState(() => _users = data.map((u) => User.fromJson(u)).toList());
      }
    } catch (_) {}
    setState(() => _loading = false);
  }

  void _selectUser(User u) {
    setState(() {
      _selectedUser = u;
      _nameCtrl.text     = u.name;
      _emailCtrl.text    = u.email ?? '';
      _userIdCtrl.text   = u.employeeId ?? '';
      _addressCtrl.text  = u.address ?? '';
      _passwordCtrl.text = '';
    });
  }

  Future<void> _saveCredentials() async {
    if (_selectedUser == null) return;
    setState(() => _saving = true);

    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final headers = Map<String, String>.from(auth.authHeaders);
      headers['Content-Type'] = 'application/json';

      final body = <String, dynamic>{
        'name':       _nameCtrl.text.trim(),
        'email':      _emailCtrl.text.trim(),
        'employeeId': _userIdCtrl.text.trim(),
        'address':    _addressCtrl.text.trim(),
      };
      if (_passwordCtrl.text.isNotEmpty) {
        body['password'] = _passwordCtrl.text;
      }

      final res = await http.patch(
        Uri.parse('${ApiConfig.baseUrl}/users/${_selectedUser!.id}/credentials'),
        headers: headers,
        body: json.encode(body),
      );

      if (res.statusCode == 200 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Row(children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 16),
            SizedBox(width: 8),
            Text('Credentials updated!', style: TextStyle(fontWeight: FontWeight.w700)),
          ]),
          backgroundColor: _kTeal,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
        await _fetchUsers();
        setState(() => _selectedUser = null);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }

    setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _users.where((u) {
      if (_search.isEmpty) return true;
      final q = _search.toLowerCase();
      return u.name.toLowerCase().contains(q) ||
             (u.email ?? '').toLowerCase().contains(q) ||
             (u.employeeId ?? '').toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kDark,
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Row(
          children: [
            Icon(Icons.key_rounded, size: 20, color: _kTeal),
            SizedBox(width: 10),
            Text('User Credentials', style: TextStyle(
              fontWeight: FontWeight.w900, fontSize: 17, color: Colors.white, letterSpacing: 0.3,
            )),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 20),
            onPressed: _fetchUsers,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _kTeal))
          : Row(
              children: [
                // ── LEFT: user list ──
                Container(
                  width: MediaQuery.of(context).size.width > 700 ? 340 : MediaQuery.of(context).size.width,
                  color: _kCard,
                  child: Column(
                    children: [
                      // Search bar
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: _kBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 12),
                              const Icon(Icons.search_rounded, size: 18, color: _kSub),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  onChanged: (v) => setState(() => _search = v),
                                  decoration: const InputDecoration(
                                    hintText: 'Search by name, email or code…',
                                    hintStyle: TextStyle(fontSize: 12, color: _kSub),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Count
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
                        child: Row(
                          children: [
                            Text('${filtered.length} users', style: const TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w700, color: _kSub,
                            )),
                          ],
                        ),
                      ),
                      // User list
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                          itemCount: filtered.length,
                          itemBuilder: (_, i) {
                            final u = filtered[i];
                            final isSelected = _selectedUser?.id == u.id;
                            return GestureDetector(
                              onTap: () => _selectUser(u),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: isSelected ? _kDark : _kBg,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isSelected ? _kTeal : const Color(0xFFE2E8F0),
                                    width: isSelected ? 1.5 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 38, height: 38,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isSelected ? _kTeal.withOpacity(0.25) : const Color(0xFFE2E8F0),
                                      ),
                                      child: Center(
                                        child: Text(
                                          u.name.isNotEmpty ? u.name[0].toUpperCase() : '?',
                                          style: TextStyle(
                                            fontSize: 15, fontWeight: FontWeight.w800,
                                            color: isSelected ? _kTeal : const Color(0xFF64748B),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(u.name,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w800, fontSize: 13,
                                              color: isSelected ? Colors.white : _kDark,
                                            ),
                                            maxLines: 1, overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 3),
                                          Row(
                                            children: [
                                              _chip(u.role.label, isSelected),
                                              const SizedBox(width: 6),
                                              if ((u.email ?? '').isNotEmpty)
                                                Expanded(
                                                  child: Text(u.email!,
                                                    style: TextStyle(
                                                      fontSize: 10, fontWeight: FontWeight.w500,
                                                      color: isSelected ? Colors.white70 : _kSub,
                                                    ),
                                                    maxLines: 1, overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(Icons.chevron_right_rounded,
                                      size: 16,
                                      color: isSelected ? _kTeal : const Color(0xFFCBD5E1),
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
                ),

                // ── RIGHT: edit panel ──
                if (MediaQuery.of(context).size.width > 700)
                  Expanded(
                    child: _selectedUser == null
                        ? _emptyState()
                        : _editPanel(),
                  ),
              ],
            ),
      // Bottom sheet for narrow screens
      bottomSheet: MediaQuery.of(context).size.width <= 700 && _selectedUser != null
          ? _editPanel(bottomSheet: true)
          : null,
    );
  }

  Widget _chip(String label, bool dark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: dark ? _kTeal.withOpacity(0.2) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
        style: TextStyle(
          fontSize: 9, fontWeight: FontWeight.w800,
          color: dark ? _kTeal : _kSub,
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _kTeal.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_search_rounded, size: 40, color: _kTeal),
          ),
          const SizedBox(height: 16),
          const Text('Select a User', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: _kDark)),
          const SizedBox(height: 6),
          const Text('Choose a user from the list to update\ntheir credentials and password.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _kSub, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _editPanel({bool bottomSheet = false}) {
    final u = _selectedUser!;
    Widget content = Container(
      color: _kBg,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: [_kDark, Color(0xFF1A3A5C)]),
                  ),
                  child: Center(child: Text(
                    u.name[0].toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20),
                  )),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(u.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: _kDark)),
                      const SizedBox(height: 4),
                      Row(children: [
                        _chip(u.role.label, false),
                        const SizedBox(width: 6),
                        _chip(u.zone.toUpperCase(), false),
                      ]),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _selectedUser = null),
                  child: const Icon(Icons.close_rounded, color: _kSub),
                ),
              ],
            ),

            const SizedBox(height: 28),
            _sectionLabel('PROFILE INFO'),
            const SizedBox(height: 12),
            _inputField('Full Name', _nameCtrl, icon: Icons.person_outline_rounded),
            const SizedBox(height: 12),
            _inputField('Email Address', _emailCtrl, icon: Icons.email_outlined, keyboard: TextInputType.emailAddress),
            const SizedBox(height: 12),
            _inputField('Employee / User Code', _userIdCtrl, icon: Icons.badge_outlined),
            const SizedBox(height: 12),
            _inputField('Home/Office Address', _addressCtrl, icon: Icons.location_on_outlined),

            const SizedBox(height: 24),
            _sectionLabel('SET NEW PASSWORD'),
            const SizedBox(height: 4),
            const Text(
              'For security, the current password is encrypted and cannot be viewed. Leave blank to keep existing password.',
              style: TextStyle(fontSize: 11, color: _kSub),
            ),
            const SizedBox(height: 12),
            _passwordField(),

            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedUser = null),
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Center(child: Text('CANCEL',
                        style: TextStyle(fontWeight: FontWeight.w800, color: _kSub, fontSize: 12),
                      )),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: _saving ? null : _saveCredentials,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 50,
                      decoration: BoxDecoration(
                        color: _kDark,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: _saving
                            ? const SizedBox(width: 20, height: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                            : const Row(mainAxisSize: MainAxisSize.min, children: [
                                Icon(Icons.save_rounded, color: Colors.white, size: 16),
                                SizedBox(width: 8),
                                Text('SAVE CREDENTIALS',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12)),
                              ]),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );

    if (bottomSheet) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: _kBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: content,
      );
    }
    return content;
  }

  Widget _sectionLabel(String label) {
    return Row(children: [
      Container(width: 3, height: 14, decoration: BoxDecoration(color: _kTeal, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 8),
      Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.8, color: _kSub)),
    ]);
  }

  Widget _inputField(String label, TextEditingController ctrl, {
    IconData? icon, TextInputType keyboard = TextInputType.text,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboard,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _kDark),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _kSub),
        prefixIcon: icon != null ? Icon(icon, size: 18, color: _kSub) : null,
        filled: true,
        fillColor: _kCard,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _kTeal, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }

  Widget _passwordField() {
    return StatefulBuilder(builder: (_, setS) {
      return TextFormField(
        controller: _passwordCtrl,
        obscureText: !_showPassword,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _kDark),
        decoration: InputDecoration(
          labelText: 'New Password',
          labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _kSub),
          prefixIcon: const Icon(Icons.lock_outline_rounded, size: 18, color: _kSub),
          suffixIcon: GestureDetector(
            onTap: () { setState(() => _showPassword = !_showPassword); setS(() {}); },
            child: Icon(
              _showPassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
              size: 18, color: _kSub,
            ),
          ),
          filled: true, fillColor: _kCard,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _kTeal, width: 1.5)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      );
    });
  }
}
