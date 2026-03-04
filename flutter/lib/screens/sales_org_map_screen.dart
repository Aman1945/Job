import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../providers/nexus_provider.dart';
import '../models/models.dart';
import '../config/api_config.dart';
import 'org_member_data_sheet.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SalesOrgMapScreen — Admin / CEO / Chairman ONLY
//
// Position key format: '{level}_{zone}_{channel}'
//   e.g.  'chairman', 'ceo', 'nsm_retail', 'rsm_north_retail', 'asm_south_horeca'
//
// Each user has an `orgPosition` field.
// Filtering is 100% slot-based — only the user whose orgPosition == slotKey
// appears in that card.  Add → sets orgPosition.  Remove → clears it (null).
// ─────────────────────────────────────────────────────────────────────────────

// ── Theme constants ─────────────────────────────────────────────────────────
const _bgPage  = Color(0xFF060E1A);
const _teal    = Color(0xFF1ABFA1);
const _retailC = Color(0xFF3B82F6);
const _horecaC = Color(0xFF8B5CF6);
const _vacantC = Color(0xFFDC2626);
const _bypassC = Color(0xFFF97316);
const _goldC   = Color(0xFFFFD700);
const _txtHead = Colors.white;
const _txtSub  = Color(0xFF64748B);

class SalesOrgMapScreen extends StatefulWidget {
  const SalesOrgMapScreen({super.key});

  @override
  State<SalesOrgMapScreen> createState() => _SalesOrgMapScreenState();
}

class _SalesOrgMapScreenState extends State<SalesOrgMapScreen> {
  String _selectedZone = 'ALL';
  bool _saving = false;

  static const List<String> _zones = [
    'ALL', 'NORTH', 'SOUTH', 'EAST', 'WEST', 'MUMBAI'
  ];
  static const Map<String, Color> _zoneColors = {
    'ALL':    _teal,
    'NORTH':  Color(0xFF3B82F6),
    'SOUTH':  Color(0xFFEF4444),
    'EAST':   Color(0xFF10B981),
    'WEST':   Color(0xFFF59E0B),
    'MUMBAI': Color(0xFF8B5CF6),
  };

  // ── Slot key builder ─────────────────────────────────────────────────────

  /// Build the slot key for a given level + zone + channel.
  /// Zone 'ALL' means no zone suffix (top-level positions).
  String _slotKey(String level, String zone, String channel) {
    final z = zone.toLowerCase().replaceAll(' ', '_');
    final ch = channel.toLowerCase();
    final lv = level.toLowerCase();
    if (lv == 'chairman' || lv == 'ceo') return lv;
    if (lv == 'nsm') return 'nsm_$ch';
    if (zone == 'ALL') return '${lv}_all_$ch';
    return '${lv}_${z}_$ch';
  }

  // ── Users for a slot ─────────────────────────────────────────────────────

  List<User> _inSlot(List<User> all, String slotKey) =>
      all.where((u) => u.orgPosition == slotKey).toList();

  // ── All users NOT in any org-map slot (available to pick) ────────────────
  List<User> _available(List<User> all) =>
      all.where((u) =>
          u.orgPosition == null || u.orgPosition!.isEmpty).toList()
        ..sort((a, b) => a.name.compareTo(b.name));

  // ── PATCH helper ─────────────────────────────────────────────────────────

  Future<bool> _patchUser(String userId, Map<String, dynamic> payload) async {
    try {
      final r = await http.patch(
        Uri.parse('${ApiConfig.baseUrl}/users/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 10));
      return r.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<void> _assign(User user, String slotKey) async {
    setState(() => _saving = true);
    final ok = await _patchUser(user.id, {'orgPosition': slotKey});
    if (mounted) {
      await Provider.of<NexusProvider>(context, listen: false).fetchUsers();
      _snack(ok
          ? '✅ ${user.name} assigned to position'
          : '❌ Failed to assign', error: !ok);
      setState(() => _saving = false);
    }
  }

  Future<void> _remove(User user) async {
    setState(() => _saving = true);
    final ok = await _patchUser(user.id, {'orgPosition': null});
    if (mounted) {
      await Provider.of<NexusProvider>(context, listen: false).fetchUsers();
      _snack(ok
          ? '🗑 ${user.name} removed from position'
          : '❌ Failed to remove', error: !ok);
      setState(() => _saving = false);
    }
  }

  void _snack(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,
          style: const TextStyle(
              fontFamily: 'Montserrat', fontWeight: FontWeight.w700)),
      backgroundColor: error ? _vacantC : _teal,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  // ── User picker bottom sheet ─────────────────────────────────────────────

  void _openPicker({
    required String positionLabel,
    required String slotKey,
    required List<User> allUsers,
  }) {
    final avail = _available(allUsers);
    String query = '';
    StateSetter? setS;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(builder: (ctx, ss) {
        setS = ss;
        final filtered = query.isEmpty
            ? avail
            : avail.where((u) =>
                u.name.toLowerCase().contains(query.toLowerCase()) ||
                u.role.label.toLowerCase().contains(query.toLowerCase()) ||
                u.zone.toLowerCase().contains(query.toLowerCase())).toList();

        return Container(
          height: MediaQuery.of(ctx).size.height * 0.82,
          decoration: const BoxDecoration(
            color: Color(0xFF0D1829),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(children: [
            // Handle bar
            Container(width: 36, height: 4,
                margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(2))),

            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(children: [
                Container(width: 38, height: 38,
                    decoration: BoxDecoration(
                        color: _teal.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.person_add_rounded,
                        color: _teal, size: 18)),
                const SizedBox(width: 12),
                Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('ASSIGN TO POSITION',
                          style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: _txtHead,
                              letterSpacing: 0.8)),
                      Text(positionLabel,
                          style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: _teal)),
                    ])),
                Text('${filtered.length} available',
                    style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 9,
                        color: _txtSub)),
              ]),
            ),

            // Search
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: TextField(
                style: const TextStyle(
                    fontFamily: 'Montserrat', fontSize: 12, color: _txtHead),
                decoration: InputDecoration(
                  hintText: 'Search name, role, zone…',
                  hintStyle: const TextStyle(
                      fontFamily: 'Montserrat', fontSize: 11, color: _txtSub),
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: _txtSub, size: 18),
                  filled: true,
                  fillColor: const Color(0xFF142035),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                ),
                onChanged: (v) => setS?.call(() => query = v),
              ),
            ),

            const SizedBox(height: 8),
            const Divider(color: Colors.white10, height: 1),

            Expanded(
              child: filtered.isEmpty
                  ? Center(child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.person_off_rounded,
                            size: 40, color: Colors.white12),
                        const SizedBox(height: 10),
                        const Text('No unassigned users',
                            style: TextStyle(
                                fontFamily: 'Montserrat',
                                color: _txtSub,
                                fontWeight: FontWeight.w600)),
                      ]))
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) =>
                          const Divider(color: Colors.white10, height: 1),
                      itemBuilder: (_, i) {
                        final u = filtered[i];
                        final init = u.name.trim().split(' ')
                            .take(2)
                            .map((p) => p.isNotEmpty ? p[0].toUpperCase() : '')
                            .join();
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 6, horizontal: 4),
                          leading: Container(
                              width: 40, height: 40,
                              decoration: BoxDecoration(
                                  color: _teal.withValues(alpha: 0.15),
                                  shape: BoxShape.circle),
                              child: Center(child: Text(init,
                                  style: const TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w900,
                                      fontSize: 13,
                                      color: _teal)))),
                          title: Text(u.name,
                              style: const TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                  color: _txtHead)),
                          subtitle: Row(children: [
                            _chip(u.role.label, _teal),
                            const SizedBox(width: 4),
                            _chip(u.zone,
                                _zoneColors[u.zone.toUpperCase()] ?? _txtSub),
                          ]),
                          trailing: const Icon(
                              Icons.arrow_circle_right_rounded,
                              color: _teal, size: 20),
                          onTap: () async {
                            Navigator.pop(ctx);
                            await _assign(u, slotKey);
                          },
                        );
                      }),
            ),
          ]),
        );
      }),
    );
  }

  Widget _chip(String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: color.withValues(alpha: 0.25))),
        child: Text(label,
            style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 7,
                fontWeight: FontWeight.w800,
                color: color)),
      );

  // ── BUILD ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final nexus    = Provider.of<NexusProvider>(context);
    final allUsers = nexus.users;

    return Scaffold(
      backgroundColor: _bgPage,
      appBar: AppBar(
        backgroundColor: _bgPage,
        foregroundColor: _txtHead,
        elevation: 0,
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('SALES ORG MAP',
              style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  letterSpacing: 1.5,
                  color: _txtHead)),
          Text('Organizational Hierarchy  •  Admin View Only',
              style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 9,
                  color: _txtHead.withValues(alpha: 0.4))),
        ]),
        actions: [
          if (_saving)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: SizedBox(width: 18, height: 18,
                  child: CircularProgressIndicator(
                      color: _teal, strokeWidth: 2)),
            )
          else
            Container(
              margin: const EdgeInsets.only(right: 14),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                  color: _teal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _teal.withValues(alpha: 0.3))),
              child: const Row(children: [
                Icon(Icons.lock_rounded, size: 11, color: _teal),
                SizedBox(width: 4),
                Text('CONFIDENTIAL',
                    style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        color: _teal,
                        letterSpacing: 0.5)),
              ]),
            ),
        ],
      ),
      body: Column(children: [
        _zoneFilter(),
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(14, 20, 14, 48),
          child: _orgTree(allUsers),
        )),
      ]),
    );
  }

  // ── Zone filter ──────────────────────────────────────────────────────────

  Widget _zoneFilter() => Container(
        color: _bgPage,
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _zones.map((z) {
              final sel = _selectedZone == z;
              final col = _zoneColors[z]!;
              return GestureDetector(
                onTap: () => setState(() => _selectedZone = z),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                      color: sel ? col : col.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                          color: sel ? col : col.withValues(alpha: 0.25))),
                  child: Text(z,
                      style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: sel ? Colors.white : col,
                          letterSpacing: 0.5)),
                ),
              );
            }).toList(),
          ),
        ),
      );

  // ── Org tree ─────────────────────────────────────────────────────────────

  Widget _orgTree(List<User> all) {
    final z = _selectedZone;
    return Column(children: [
      _lvLabel('LEVEL 1', 'Executive Leadership'),
      _fullCard('chairman', 'CHAIRMAN', all, _goldC,
          Icons.stars_rounded),
      _conn('to CEO'),

      _lvLabel('LEVEL 2', 'Chief Executive'),
      _fullCard('ceo', 'CEO', all, _teal,
          Icons.corporate_fare_rounded),
      _conn('to NSM'),

      _channelHeader(),

      _lvLabel('LEVEL 3', 'National Sales Manager'),
      _dualRow('nsm', z, 'NSM', all),
      _conn('to RSM  ·  ${z == 'ALL' ? 'All Zones' : z}'),

      _lvLabel('LEVEL 4', 'Regional Sales Manager${z != 'ALL' ? '  —  $z' : ''}'),
      _dualRow('rsm', z, 'RSM', all),
      _conn('to ASM'),

      _lvLabel('LEVEL 5', 'Area Sales Manager${z != 'ALL' ? '  —  $z' : ''}'),
      _dualRow('asm', z, 'ASM', all),
      _conn('to Sales Team'),

      _lvLabel('LEVEL 6', 'Sales Executives${z != 'ALL' ? '  —  $z' : ''}'),
      _dualRow('sales', z, 'SALES', all),

      const SizedBox(height: 20),
      _legend(),
    ]);
  }

  // Full-width (Chairman / CEO)
  Widget _fullCard(String slotKey, String title, List<User> all,
      Color color, IconData icon) {
    final users  = _inSlot(all, slotKey);
    final vacant = users.isEmpty;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: vacant
            ? const Color(0xFF1A0000)
            : color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: vacant
                ? _vacantC.withValues(alpha: 0.5)
                : color.withValues(alpha: 0.35)),
      ),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
              color: (vacant ? _vacantC : color).withValues(alpha: 0.15),
              shape: BoxShape.circle),
          child: Icon(vacant ? Icons.person_off_rounded : icon,
              color: vacant ? _vacantC : color, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: vacant ? _vacantC : color,
                      letterSpacing: 0.8)),
              const SizedBox(height: 6),
              if (vacant)
                _vacantBadge()
              else
                Wrap(spacing: 6, runSpacing: 6,
                    children: users.map((u) =>
                        _userPill(u, color, slotKey)).toList()),
            ])),
        // ADD button
        GestureDetector(
          onTap: () => _openPicker(
              positionLabel: '$title (Pan India)',
              slotKey: slotKey,
              allUsers: all),
          child: _addBtn(color),
        ),
      ]),
    );
  }

  // Dual-column row
  Widget _dualRow(String level, String zone, String labelPrefix,
      List<User> all) {
    final retKey   = _slotKey(level, zone, 'retail');
    final horKey   = _slotKey(level, zone, 'horeca');
    final retUsers = _inSlot(all, retKey);
    final horUsers = _inSlot(all, horKey);
    final zoneSuffix = zone != 'ALL' ? '\n$zone' : '';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _posCard(
          label:    '$labelPrefix — RETAIL$zoneSuffix',
          users:    retUsers,
          color:    _retailC,
          icon:     Icons.shopping_cart_rounded,
          slotKey:  retKey,
          allUsers: all,
          bypassTo: retUsers.isEmpty ? 'NSM RETAIL' : null,
        )),
        Container(
            width: 1, height: 130,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            color: Colors.white.withValues(alpha: 0.06)),
        Expanded(child: _posCard(
          label:    '$labelPrefix — HORECA$zoneSuffix',
          users:    horUsers,
          color:    _horecaC,
          icon:     Icons.restaurant_rounded,
          slotKey:  horKey,
          allUsers: all,
          bypassTo: horUsers.isEmpty ? 'NSM HORECA' : null,
        )),
      ],
    );
  }

  Widget _posCard({
    required String label,
    required List<User> users,
    required Color color,
    required IconData icon,
    required String slotKey,
    required List<User> allUsers,
    String? bypassTo,
  }) {
    final vacant = users.isEmpty;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: vacant
            ? const Color(0xFF1A0000)
            : color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: vacant
                ? _vacantC.withValues(alpha: 0.35)
                : color.withValues(alpha: 0.22),
            width: vacant ? 1.5 : 1),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Title row + Add btn
        Row(children: [
          Icon(icon, size: 12, color: vacant ? _vacantC : color),
          const SizedBox(width: 5),
          Expanded(child: Text(label,
              style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                  color: vacant ? _vacantC : color,
                  letterSpacing: 0.5))),
          GestureDetector(
            onTap: () => _openPicker(
                positionLabel: label.replaceAll('\n', ' '),
                slotKey: slotKey,
                allUsers: allUsers),
            child: Container(
              width: 22, height: 22,
              decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: color.withValues(alpha: 0.4))),
              child: Icon(Icons.add_rounded, size: 13, color: color),
            ),
          ),
        ]),
        const SizedBox(height: 8),

        if (vacant) ...[
          _vacantBadge(),
          if (bypassTo != null) ...[
            const SizedBox(height: 6),
            _bypassTag(bypassTo),
          ],
        ] else ...[
          // User pills with remove button
          Wrap(spacing: 4, runSpacing: 4,
              children: users.map((u) => _userPill(u, color, slotKey)).toList()),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6)),
              child: Text('${users.length} member${users.length != 1 ? 's' : ''}',
                  style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 7,
                      fontWeight: FontWeight.w700,
                      color: color.withValues(alpha: 0.8))),
            ),
          ),
        ],
      ]),
    );
  }

  // ── User pill WITH remove button ─────────────────────────────────────────

  Widget _userPill(User user, Color color, String slotKey) {
    final init = user.name.trim().split(' ')
        .take(2).map((p) => p.isNotEmpty ? p[0].toUpperCase() : '').join();
    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => OrgMemberDataSheet(
          member: user,
          slotKey: slotKey,
          accentColor: color,
        ),
      ),
      child: Container(
      padding: const EdgeInsets.fromLTRB(6, 5, 4, 5),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.28))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        // Avatar
        Container(
          width: 20, height: 20,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Center(child: Text(init,
              style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                  color: Colors.white))),
        ),
        const SizedBox(width: 5),
        // Name + zone
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(user.name.split(' ').first,
              style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: _txtHead)),
          if (user.zone.isNotEmpty && user.zone.toUpperCase() != 'PAN INDIA')
            Text(user.zone.toUpperCase(),
                style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 7,
                    fontWeight: FontWeight.w600,
                    color: color.withValues(alpha: 0.8))),
        ]),
        const SizedBox(width: 6),
        // ✕ Remove button
        GestureDetector(
          onTap: () => _confirmRemove(user),
          child: Container(
            width: 18, height: 18,
            decoration: BoxDecoration(
                color: _vacantC.withValues(alpha: 0.15),
                shape: BoxShape.circle),
            child: const Icon(Icons.close_rounded, size: 10, color: _vacantC),
          ),
        ),
      ]),
    ),   // closes Container (child of GestureDetector)
    );   // closes GestureDetector → return
  }

  /// Confirm before removing so admin doesn't remove by accident
  void _confirmRemove(User user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0D1829),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Remove from Position?',
            style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w900,
                color: _txtHead,
                fontSize: 14)),
        content: Text(
          '${user.name} will be removed from their current position.\n\nThey will appear as "Unassigned" in the picker.',
          style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 12,
              color: _txtSub),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL',
                style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w700,
                    color: _txtSub)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _remove(user);
            },
            child: const Text('REMOVE',
                style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w900,
                    color: _vacantC)),
          ),
        ],
      ),
    );
  }

  // ── Small widgets ────────────────────────────────────────────────────────

  Widget _addBtn(Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withValues(alpha: 0.3))),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.person_add_alt_1_rounded, size: 13, color: color),
          const SizedBox(width: 4),
          Text('ADD',
              style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                  color: color,
                  letterSpacing: 0.5)),
        ]),
      );

  Widget _vacantBadge() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
            color: _vacantC.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: _vacantC.withValues(alpha: 0.35))),
        child: const Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.error_outline_rounded, size: 10, color: _vacantC),
          SizedBox(width: 4),
          Text('VACANT',
              style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                  color: _vacantC,
                  letterSpacing: 0.5)),
        ]),
      );

  Widget _bypassTag(String to) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
            color: _bypassC.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: _bypassC.withValues(alpha: 0.25))),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.arrow_upward_rounded, size: 8, color: _bypassC),
          const SizedBox(width: 4),
          Flexible(child: Text('BYPASSES → $to',
              style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 7,
                  fontWeight: FontWeight.w700,
                  color: _bypassC),
              overflow: TextOverflow.ellipsis)),
        ]),
      );

  Widget _lvLabel(String level, String sub) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
                color: _teal.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6)),
            child: Text(level,
                style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    color: _teal,
                    letterSpacing: 0.8)),
          ),
          const SizedBox(width: 8),
          Text(sub,
              style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: _txtHead.withValues(alpha: 0.3))),
        ]),
      );

  Widget _channelHeader() => Padding(
        padding: const EdgeInsets.only(bottom: 10, top: 4),
        child: Row(children: [
          Expanded(child: Container(
            padding: const EdgeInsets.symmetric(vertical: 7),
            decoration: BoxDecoration(
                color: _retailC.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _retailC.withValues(alpha: 0.2))),
            child: const Center(child: Text('🛒  RETAIL CHANNEL',
                style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: _retailC,
                    letterSpacing: 0.5))),
          )),
          const SizedBox(width: 8),
          Expanded(child: Container(
            padding: const EdgeInsets.symmetric(vertical: 7),
            decoration: BoxDecoration(
                color: _horecaC.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _horecaC.withValues(alpha: 0.2))),
            child: const Center(child: Text('🍽  HORECA CHANNEL',
                style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: _horecaC,
                    letterSpacing: 0.5))),
          )),
        ]),
      );

  Widget _conn(String? label) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(children: [
          Container(width: 2, height: 12, color: Colors.white10),
          if (label != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(14)),
              child: Text(label,
                  style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 7,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withValues(alpha: 0.22),
                      letterSpacing: 0.5)),
            ),
            Container(width: 2, height: 12, color: Colors.white10),
          ],
          Icon(Icons.keyboard_arrow_down_rounded,
              size: 18, color: Colors.white.withValues(alpha: 0.15)),
        ]),
      );

  Widget _legend() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('LEGEND',
              style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                  color: Colors.white.withValues(alpha: 0.4),
                  letterSpacing: 1)),
          const SizedBox(height: 8),
          Wrap(spacing: 12, runSpacing: 8, children: [
            _li(_teal, 'Filled Position'),
            _li(_vacantC, 'VACANT Position'),
            _li(_bypassC, 'Bypass Routing'),
            _li(_retailC, 'Retail Channel'),
            _li(_horecaC, 'HORECA Channel'),
            _li(_vacantC, '✕ = Remove user'),
          ]),
        ]),
      );

  Widget _li(Color c, String label) => Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 8, height: 8,
            decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(label,
            style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 8,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.4))),
      ]);
}
