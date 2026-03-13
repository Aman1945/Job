import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/models.dart';
import '../config/api_config.dart';

// ───────────────────────── PALETTE ─────────────────────────────
const _kBg   = Color(0xFFF0F4FA);
const _kDark = Color(0xFF0D2137);
const _kTeal = Color(0xFF1ABFA1);
const _kSub  = Color(0xFF7A8EA5);

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});
  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen>
    with SingleTickerProviderStateMixin {
  bool _loading = true;
  bool _actionLoading = false;
  Map<String, dynamic>? _todayRecord;   // current user's today attendance
  List<Map<String, dynamic>> _teamRecords = []; // admin: all users today

  // For slide gesture
  double _slideDx = 0;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  Future<void> _init() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    _isAdmin = auth.currentUser?.role.label == 'Admin';
    await _fetchAttendance();
  }

  Future<void> _fetchAttendance() async {
    setState(() => _loading = true);
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final endpoint = _isAdmin
          ? '${ApiConfig.baseUrl}/attendance/today'
          : '${ApiConfig.baseUrl}/attendance/me';
      final res = await http.get(Uri.parse(endpoint), headers: auth.authHeaders);
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (_isAdmin) {
          setState(() => _teamRecords = List<Map<String, dynamic>>.from(data));
        } else {
          setState(() => _todayRecord = data is Map ? Map<String, dynamic>.from(data) : null);
        }
      }
    } catch (_) {}
    setState(() => _loading = false);
  }

  Future<void> _checkIn() async {
    setState(() => _actionLoading = true);
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final headers = Map<String, String>.from(auth.authHeaders);
      headers['Content-Type'] = 'application/json';

      final res = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/attendance/check-in'),
        headers: headers,
        body: json.encode({
          'location': {'lat': 0.0, 'lng': 0.0, 'note': 'Manual check-in'},
        }),
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        if (mounted) _showSnack('✅ Checked in successfully!', success: true);
        await _fetchAttendance();
      }
    } catch (e) {
      if (mounted) _showSnack('Error: $e');
    }
    setState(() => _actionLoading = false);
  }

  Future<void> _checkOut() async {
    setState(() => _actionLoading = true);
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final headers = Map<String, String>.from(auth.authHeaders);
      headers['Content-Type'] = 'application/json';

      final res = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/attendance/check-out'),
        headers: headers,
        body: json.encode({
          'location': {'lat': 0.0, 'lng': 0.0, 'note': 'Manual check-out'},
        }),
      );
      if (res.statusCode == 200) {
        if (mounted) _showSnack('👋 Checked out. Have a great day!', success: true);
        await _fetchAttendance();
      }
    } catch (e) {
      if (mounted) _showSnack('Error: $e');
    }
    setState(() => _actionLoading = false);
  }

  void _showSnack(String msg, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w700)),
      backgroundColor: success ? _kTeal : Colors.red,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  // ─── Helpers ────────────────────────────────────────────────
  bool get _isCheckedIn  => _todayRecord != null && _todayRecord!['checkInTime'] != null;
  bool get _isCheckedOut => _isCheckedIn  && _todayRecord!['checkOutTime'] != null;

  String _fmt(String? iso) {
    if (iso == null) return '—';
    final dt = DateTime.tryParse(iso);
    if (dt == null) return '—';
    final local = dt.toLocal();
    final h = local.hour.toString().padLeft(2, '0');
    final m = local.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _today() {
    final now = DateTime.now().toLocal();
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    const days = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser;

    return Scaffold(
      backgroundColor: _kBg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Header ──────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: _kDark,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0D2137), Color(0xFF1A3A5C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(children: [
                          const Icon(Icons.fingerprint_rounded, size: 22, color: _kTeal),
                          const SizedBox(width: 8),
                          const Text('ATTENDANCE', style: TextStyle(
                            color: _kTeal, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.5,
                          )),
                        ]),
                        const SizedBox(height: 4),
                        Text(user?.name ?? 'User', style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w900, fontSize: 22, letterSpacing: -0.3,
                        )),
                        const SizedBox(height: 6),
                        Text(_today(), style: const TextStyle(color: Colors.white60, fontSize: 13)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: _loading
                ? const Padding(
                    padding: EdgeInsets.all(60),
                    child: Center(child: CircularProgressIndicator(color: _kTeal)),
                  )
                : _isAdmin
                    ? _adminView()
                    : _userView(),
          ),
        ],
      ),
    );
  }

  // ─── USER VIEW ───────────────────────────────────────────────
  Widget _userView() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Status card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: _kDark.withOpacity(0.07), blurRadius: 16, offset: const Offset(0, 4))],
            ),
            child: Row(
              children: [
                // Status indicator
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isCheckedOut
                        ? const Color(0xFF0EA5E9).withOpacity(0.12)
                        : _isCheckedIn
                            ? _kTeal.withOpacity(0.12)
                            : const Color(0xFFF1F5F9),
                  ),
                  child: Icon(
                    _isCheckedOut
                        ? Icons.home_rounded
                        : _isCheckedIn
                            ? Icons.work_rounded
                            : Icons.access_time_rounded,
                    size: 28,
                    color: _isCheckedOut
                        ? const Color(0xFF0EA5E9)
                        : _isCheckedIn
                            ? _kTeal
                            : _kSub,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(
                      _isCheckedOut ? 'Checked Out' : _isCheckedIn ? 'Currently Active' : 'Not Checked In',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        color: _isCheckedOut
                            ? const Color(0xFF0EA5E9)
                            : _isCheckedIn
                                ? _kTeal
                                : _kDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (_isCheckedIn) Row(children: [
                      _timeChip('IN', _fmt(_todayRecord!['checkInTime']), _kTeal),
                      if (_isCheckedOut) ...[ const SizedBox(width: 8), _timeChip('OUT', _fmt(_todayRecord!['checkOutTime']), const Color(0xFF0EA5E9)) ],
                    ]),
                    if (!_isCheckedIn) const Text('Tap the button below to start your day.', style: TextStyle(color: _kSub, fontSize: 12)),
                  ]),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Action button
          if (!_isCheckedOut) GestureDetector(
            onTap: _actionLoading ? null : (_isCheckedIn ? _checkOut : _checkIn),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: double.infinity,
              height: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: _isCheckedIn
                      ? [const Color(0xFF0EA5E9), const Color(0xFF6366F1)]
                      : [_kTeal, const Color(0xFF059669)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: (_isCheckedIn ? const Color(0xFF0EA5E9) : _kTeal).withOpacity(0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: _actionLoading
                    ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)
                    : Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(_isCheckedIn ? Icons.logout_rounded : Icons.login_rounded,
                          size: 22, color: Colors.white),
                        const SizedBox(width: 12),
                        Text(
                          _isCheckedIn ? 'SLIDE TO CHECK OUT' : 'SLIDE TO CHECK IN',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 0.5),
                        ),
                      ]),
              ),
            ),
          ),

          if (_isCheckedOut) Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _kTeal.withOpacity(0.3)),
            ),
            child: const Row(children: [
              Icon(Icons.check_circle_rounded, color: _kTeal, size: 20),
              SizedBox(width: 10),
              Expanded(child: Text(
                'Your attendance for today is complete. See you tomorrow!',
                style: TextStyle(color: _kTeal, fontWeight: FontWeight.w700, fontSize: 13),
              )),
            ]),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _timeChip(String prefix, String time, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text('$prefix  $time', style: TextStyle(
        fontSize: 11, fontWeight: FontWeight.w800, color: color,
      )),
    );
  }

  // ─── ADMIN VIEW ──────────────────────────────────────────────
  Widget _adminView() {
    final present = _teamRecords.where((r) => r['checkInTime'] != null).length;
    final absent  = _teamRecords.where((r) => r['checkInTime'] == null).length;
    final checkout = _teamRecords.where((r) => r['checkOutTime'] != null).length;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Metrics row
          Row(children: [
            _metricCard('Present', present.toString(), Icons.check_circle_rounded, _kTeal),
            const SizedBox(width: 10),
            _metricCard('Absent', absent.toString(), Icons.cancel_rounded, Colors.red),
            const SizedBox(width: 10),
            _metricCard('Checked Out', checkout.toString(), Icons.home_rounded, const Color(0xFF6366F1)),
          ]),
          const SizedBox(height: 20),
          const Text('TODAY\'S ATTENDANCE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.3, color: _kSub)),
          const SizedBox(height: 12),
          ..._teamRecords.map((rec) => _adminRow(rec)),
          if (_teamRecords.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Text('No records found for today.', style: TextStyle(color: _kSub)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _metricCard(String label, String count, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: color.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(shape: BoxShape.circle, color: color.withOpacity(0.12)),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(height: 8),
          Text(count, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: _kDark)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: _kSub)),
        ]),
      ),
    );
  }

  Widget _adminRow(Map<String, dynamic> rec) {
    final hasIn  = rec['checkInTime'] != null;
    final hasOut = rec['checkOutTime'] != null;
    final stateColor = hasOut ? const Color(0xFF6366F1) : hasIn ? _kTeal : Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: stateColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(shape: BoxShape.circle, color: stateColor.withOpacity(0.12)),
            child: Center(
              child: Text(
                (rec['userName'] as String? ?? '?')[0].toUpperCase(),
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: stateColor),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(rec['userName'] ?? '—', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: _kDark)),
              const SizedBox(height: 3),
              Text(rec['userRole'] ?? '', style: const TextStyle(fontSize: 10, color: _kSub, fontWeight: FontWeight.w600)),
            ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            if (hasIn) _timeChip('IN', _fmt(rec['checkInTime']), _kTeal),
            if (hasOut) ...[ const SizedBox(height: 4), _timeChip('OUT', _fmt(rec['checkOutTime']), const Color(0xFF6366F1)) ],
            if (!hasIn) const Text('Absent', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700, fontSize: 11)),
          ]),
        ],
      ),
    );
  }
}
