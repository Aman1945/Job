import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../providers/nexus_provider.dart';
import '../models/models.dart';
import '../config/api_config.dart';
import 'org_member_data_sheet.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SalesOrgMapScreen — Admin / CEO / Chairman ONLY  (LIGHT THEME)
// ─────────────────────────────────────────────────────────────────────────────

// ── Premium corporate palette ─────────────────────────────────────────────
const _bgPage   = Color(0xFFF0F4F8);
const _bgCard   = Colors.white;
const _primary  = Color(0xFF0F2B46);  // Deep Navy
const _accent   = Color(0xFF0EA5A0);  // Corporate Teal
const _retailC  = Color(0xFF2563EB);  // Refined Blue
const _horecaC  = Color(0xFF7C3AED);  // Refined Purple
const _vacantC  = Color(0xFFDC2626);
const _bypassC  = Color(0xFFEA580C);
const _goldC    = Color(0xFFD4A017);  // Muted Gold
const _txtHead  = Color(0xFF0F172A);  // Slate 900
const _txtSub   = Color(0xFF64748B);  // Slate 500
const _border   = Color(0xFFE2E8F0);  // Slate 200
const _cardShadow = Color(0x0A000000);

class SalesOrgMapScreen extends StatefulWidget {
  const SalesOrgMapScreen({super.key});

  @override
  State<SalesOrgMapScreen> createState() => _SalesOrgMapScreenState();
}

class _SalesOrgMapScreenState extends State<SalesOrgMapScreen> {
  String _selectedZone = 'ALL';
  bool _saving = false;

  static const List<String> _zones = [
    'ALL', 'NORTH', 'SOUTH', 'EAST', 'WEST',
  ];
  static const Map<String, Color> _zoneColors = {
    'ALL':   _accent,
    'NORTH': Color(0xFF2563EB),
    'SOUTH': Color(0xFFDC2626),
    'EAST':  Color(0xFF059669),
    'WEST':  Color(0xFFD97706),
  };

  // ── Slot key ─────────────────────────────────────────────────────────────
  String _slotKey(String level, String zone, String channel) {
    final z  = zone.toLowerCase().replaceAll(' ', '_');
    final ch = channel.toLowerCase();
    final lv = level.toLowerCase();
    if (lv == 'chairman' || lv == 'ceo') return lv;
    if (lv == 'nsm') return 'nsm_$ch';
    if (zone == 'ALL') return '${lv}_all_$ch';
    return '${lv}_${z}_$ch';
  }

  List<User> _inSlot(List<User> all, String slotKey) =>
      all.where((u) => u.orgPositions.contains(slotKey)).toList();

  /// Returns users eligible for a slot.
  /// For zone-specific slots (rsm_north_*, asm_south_*, etc.), users who
  /// already hold a position in a *different* regional zone are excluded.
  /// National-level slots (chairman, ceo, nsm_*) have no zone restriction.
  List<User> _availableForSlot(List<User> all, String slotKey) {
    // National-level slots — everyone is eligible
    final lk = slotKey.toLowerCase();
    if (lk == 'chairman' || lk == 'ceo' || lk.startsWith('nsm_')) {
      return all.toList()..sort((a, b) => a.name.compareTo(b.name));
    }
    // Regional slots — extract zone from key  (e.g. 'rsm_north_retail' → 'north')
    final parts = lk.split('_');
    if (parts.length < 3) {
      return all.toList()..sort((a, b) => a.name.compareTo(b.name));
    }
    final slotZone = parts[1]; // 'north', 'south', 'east', 'west', 'all'
    if (slotZone == 'all') {
      return all.toList()..sort((a, b) => a.name.compareTo(b.name));
    }
    // Filter out users who already have a position in a DIFFERENT zone
    final regionalZones = {'north', 'south', 'east', 'west'};
    return all.where((u) {
      // Check each of the user's existing positions
      for (final pos in u.orgPositions) {
        final pp = pos.toLowerCase().split('_');
        if (pp.length < 3) continue;  // skip national slots
        final existingZone = pp[1];
        if (existingZone == 'all') continue; // skip "all" positions
        if (regionalZones.contains(existingZone) && existingZone != slotZone) {
          return false; // user is already in a different regional zone
        }
      }
      return true;
    }).toList()..sort((a, b) => a.name.compareTo(b.name));
  }

  // ── PATCH helpers (atomic org-position endpoints) ──────────────────────
  Future<bool> _orgAdd(String userId, String slotKey) async {
    try {
      final r = await http.patch(
        Uri.parse('${ApiConfig.baseUrl}/users/$userId/org-add'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'slotKey': slotKey}),
      ).timeout(const Duration(seconds: 10));
      return r.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _orgRemove(String userId, String slotKey) async {
    try {
      final r = await http.patch(
        Uri.parse('${ApiConfig.baseUrl}/users/$userId/org-remove'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'slotKey': slotKey}),
      ).timeout(const Duration(seconds: 10));
      return r.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // Batch assign multiple users at once — all PATCHes in parallel, one refresh
  Future<void> _assignBatch(List<User> users, String slotKey) async {
    setState(() => _saving = true);
    final results = await Future.wait(
      users.map((u) => _orgAdd(u.id, slotKey)),
    );
    if (mounted) {
      await Provider.of<NexusProvider>(context, listen: false).fetchUsers();
      setState(() => _saving = false);
      final failed = results.where((ok) => !ok).length;
      if (failed == 0) {
        _snack('✅ ${users.length} member${users.length > 1 ? 's' : ''} assigned!');
      } else {
        _snack('⚠️ ${users.length - failed} assigned, $failed failed', error: true);
      }
    }
  }

  Future<void> _remove(User user, String slotKey) async {
    setState(() => _saving = true);
    final ok = await _orgRemove(user.id, slotKey);
    if (mounted) {
      await Provider.of<NexusProvider>(context, listen: false).fetchUsers();
      setState(() => _saving = false);
      _snack(ok
          ? '🗑 ${user.name} removed from position'
          : '❌ Failed to remove', error: !ok);
    }
  }

  void _snack(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,
          style: const TextStyle(
              fontFamily: 'Montserrat', fontWeight: FontWeight.w700)),
      backgroundColor: error ? _vacantC : _accent,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  // ── User picker bottom sheet with MULTI-SELECT ──────────────────────────
  void _openPicker({
    required String positionLabel,
    required String slotKey,
    required List<User> allUsers,
  }) {
    final avail = _availableForSlot(allUsers, slotKey);
    final Set<String> selection = {}; // Track selected user IDs
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
          height: MediaQuery.of(ctx).size.height * 0.85,
          decoration: const BoxDecoration(
            color: _bgCard,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(children: [
            // Handle bar
            Container(width: 36, height: 4,
                margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                    color: _border,
                    borderRadius: BorderRadius.circular(2))),

            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(children: [
                Container(width: 38, height: 38,
                    decoration: BoxDecoration(
                        color: _accent.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.person_add_rounded,
                        color: _accent, size: 18)),
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
                              color: _accent)),
                    ])),
                if (selection.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: _accent, borderRadius: BorderRadius.circular(12)),
                    child: Text('${selection.length} selected',
                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
                  ),
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
                  fillColor: _bgPage,
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
            const Divider(color: _border, height: 1),

            Expanded(
              child: filtered.isEmpty
                  ? Center(child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.person_off_rounded,
                            size: 40, color: _border),
                        const SizedBox(height: 10),
                        const Text('No unassigned users',
                            style: TextStyle(
                                fontFamily: 'Montserrat',
                                color: _txtSub,
                                fontWeight: FontWeight.w600)),
                      ]))
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) =>
                          const Divider(color: _border, height: 1),
                      itemBuilder: (_, i) {
                        final u = filtered[i];
                        final isSelected = selection.contains(u.id);
                        final init = u.name.trim().split(' ')
                            .take(2)
                            .map((p) => p.isNotEmpty ? p[0].toUpperCase() : '')
                            .join();
                        return CheckboxListTile(
                          value: isSelected,
                          activeColor: _accent,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 2, horizontal: 4),
                          title: Text(u.name,
                              style: const TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                  color: _txtHead)),
                          subtitle: Row(children: [
                            _chip(u.role.label, _accent),
                            const SizedBox(width: 4),
                            _chip(u.zone,
                                _zoneColors[u.zone.toUpperCase()] ?? _txtSub),
                          ]),
                          secondary: Container(
                              width: 36, height: 36,
                              decoration: BoxDecoration(
                                  color: _accent.withValues(alpha: 0.12),
                                  shape: BoxShape.circle),
                              child: Center(child: Text(init,
                                  style: const TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w900,
                                      fontSize: 12,
                                      color: _accent)))),
                          onChanged: (val) {
                            setS?.call(() {
                              if (val == true) {
                                selection.add(u.id);
                              } else {
                                selection.remove(u.id);
                              }
                            });
                          },
                        );
                      }),
            ),
            
            // Action Button
            if (selection.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      // Collect the User objects for selected IDs
                      final selectedUsers = selection
                          .map((id) => avail.firstWhere((x) => x.id == id))
                          .toList();
                      await _assignBatch(selectedUsers, slotKey);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('ASSIGN ${selection.length} MEMBERS',
                        style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w900)),
                  ),
                ),
              ),
          ]),
        );
      }),
    );
  }

  Widget _chip(String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
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
        backgroundColor: _bgCard,
        foregroundColor: _txtHead,
        elevation: 0,
        scrolledUnderElevation: 0,
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
                  color: _txtSub)),
        ]),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: _accent, size: 20),
            onPressed: () async {
              setState(() => _saving = true);
              await nexus.fetchUsers();
              if (mounted) setState(() => _saving = false);
            },
          ),
          if (_saving)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: SizedBox(width: 18, height: 18,
                  child: CircularProgressIndicator(
                      color: _accent, strokeWidth: 2)),
            )
          else
            Container(
              margin: const EdgeInsets.only(right: 14),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                  color: _accent.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _accent.withValues(alpha: 0.25))),
              child: const Row(children: [
                Icon(Icons.lock_rounded, size: 11, color: _accent),
                SizedBox(width: 4),
                Text('CONFIDENTIAL',
                    style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        color: _accent,
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
        color: _bgCard,
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
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
                      color: sel ? col : _bgCard,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                          color: sel ? col : _border)),
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
      _fullCard('chairman', 'CHAIRMAN', all, _goldC, Icons.stars_rounded),
      _conn('to CEO'),

      _lvLabel('LEVEL 2', 'Chief Executive'),
      _fullCard('ceo', 'CEO', all, _accent, Icons.corporate_fare_rounded),
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

  Widget _lvLabel(String level, String sub) => Padding(
        padding: const EdgeInsets.fromLTRB(0, 20, 0, 8),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
                color: _accent.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(8)),
            child: Text(level,
                style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: _accent,
                    letterSpacing: 0.5)),
          ),
          const SizedBox(width: 8),
          Text(sub,
              style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: _txtSub)),
        ]),
      );

  Widget _conn(String label) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(width: 1, height: 16, color: _border),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 8,
                  color: _txtSub,
                  fontWeight: FontWeight.w600)),
        ]),
      );

  Widget _channelHeader() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(children: [
          Expanded(child: Container(
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
                color: _retailC.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _retailC.withValues(alpha: 0.2))),
            child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.shopping_cart_rounded, size: 12, color: _retailC),
              SizedBox(width: 4),
              Text('RETAIL CHANNEL',
                  style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: _retailC)),
            ]),
          )),
          const SizedBox(width: 8),
          Expanded(child: Container(
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
                color: _horecaC.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _horecaC.withValues(alpha: 0.2))),
            child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.restaurant_rounded, size: 12, color: _horecaC),
              SizedBox(width: 4),
              Text('HORECA CHANNEL',
                  style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: _horecaC)),
            ]),
          )),
        ]),
      );

  Widget _legend() => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: _bgCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _border)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('LEGEND',
              style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  color: _txtSub,
                  letterSpacing: 0.8)),
          const SizedBox(height: 8),
          Wrap(spacing: 12, runSpacing: 6, children: [
            _legendItem(_retailC, 'Retail Channel'),
            _legendItem(_horecaC, 'Horeca Channel'),
            _legendItem(_vacantC, 'Vacant Position'),
            _legendItem(_bypassC, 'Bypass Active'),
            _legendItem(_goldC, 'Executive'),
          ]),
        ]),
      );

  Widget _legendItem(Color c, String label) => Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontFamily: 'Montserrat', fontSize: 8, color: _txtSub, fontWeight: FontWeight.w600)),
      ]);

  // ── Full-width card (Chairman / CEO) ─────────────────────────────────────
  Widget _fullCard(String slotKey, String title, List<User> all,
      Color color, IconData icon) {
    final users  = _inSlot(all, slotKey);
    final vacant = users.isEmpty;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: vacant ? const Color(0xFFFFF5F5) : _bgCard,
        borderRadius: BorderRadius.circular(16),
        border: vacant ? Border.all(color: _vacantC.withValues(alpha: 0.3)) : null,
        boxShadow: [
          if (!vacant) BoxShadow(color: _cardShadow, blurRadius: 16, offset: const Offset(0, 4))
        ],
      ),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
              color: (vacant ? _vacantC : color).withValues(alpha: 0.12),
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

  // ── Dual-column row ───────────────────────────────────────────────────────
  Widget _dualRow(String level, String zone, String labelPrefix, List<User> all) {
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
            width: 1, height: 140,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            color: _border),
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
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: vacant ? const Color(0xFFFFF5F5) : _bgCard,
        borderRadius: BorderRadius.circular(14),
        border: vacant ? Border.all(color: _vacantC.withValues(alpha: 0.3), width: 1.5) : null,
        boxShadow: [
          if (!vacant) BoxShadow(color: _cardShadow, blurRadius: 12, offset: const Offset(0, 4))
        ],
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
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: color.withValues(alpha: 0.35))),
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
          Wrap(spacing: 4, runSpacing: 6,
              children: users.map((u) => _userPill(u, color, slotKey)).toList()),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6)),
              child: Text('${users.length} member${users.length != 1 ? 's' : ''}',
                  style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 7,
                      fontWeight: FontWeight.w700,
                      color: color)),
            ),
          ),
        ],
      ]),
    );
  }

  // ── User pill WITH visible remove button ──────────────────────────────────
  Widget _userPill(User user, Color color, String slotKey) {
    final init = user.name.trim().split(' ')
        .take(2).map((p) => p.isNotEmpty ? p[0].toUpperCase() : '').join();
    return Container( 
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.22))),
      child: Row(children: [
        // Tap to view details - Expanded to take available space
        Expanded(
          child: GestureDetector(
            onTap: () async {
              final shouldRemove = await showModalBottomSheet<bool>(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => OrgMemberDataSheet(
                  member: user,
                  slotKey: slotKey,
                  accentColor: color,
                ),
              );
              if (shouldRemove == true) {
                _remove(user, slotKey);
              }
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
              child: Row(children: [
                // Avatar
                Container(
                  width: 24, height: 24,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                  child: Center(child: Text(init,
                      style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 8.5,
                          fontWeight: FontWeight.w900,
                          color: Colors.white))),
                ),
                const SizedBox(width: 8),
                Expanded( // Allow text to wrap/truncate
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(user.name,
                        style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 12.5,
                            fontWeight: FontWeight.w900,
                            color: _txtHead),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    Text(user.id,
                        style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 8.5,
                            fontWeight: FontWeight.w600,
                            color: _txtSub),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    if (user.zone.isNotEmpty && user.zone.toUpperCase() != 'PAN INDIA')
                      Text(user.zone.toUpperCase(),
                          style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 7.5,
                              fontWeight: FontWeight.w700,
                              color: color)),
                  ]),
                ),
              ]),
            ),
          ),
        ),

        // ✕ Remove button — clearly visible
        GestureDetector(
          onTap: () => _confirmRemove(user, slotKey),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            decoration: BoxDecoration(
                color: _vacantC.withValues(alpha: 0.10),
                borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(9),
                    bottomRight: Radius.circular(9)),
                border: Border(
                    left: BorderSide(color: _vacantC.withValues(alpha: 0.2)))),
            child: const Icon(Icons.close_rounded, size: 14, color: _vacantC),
          ),
        ),
      ]),
    );
  }

  void _confirmRemove(User user, String slotKey) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _bgCard,
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
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _remove(user, slotKey);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _vacantC,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('REMOVE',
                style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  // ── Small widgets ─────────────────────────────────────────────────────────
  Widget _addBtn(Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withValues(alpha: 0.25))),
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
            color: _vacantC.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: _vacantC.withValues(alpha: 0.3))),
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
                  color: _bypassC))),
        ]),
      );
}
