import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/nexus_provider.dart';
import '../models/models.dart';

// ─────────────────────────────────────────────────────────────────────────────
// OrgMemberDataSheet
// Full-screen bottom sheet showing:
//  • Sales summary stats for this person's team
//  • Custom calendar grid — tap a date → see that day's orders
//  • Orders list filtered by date + hierarchy
//
// Hierarchy rule (for order visibility):
//   Chairman / CEO / Admin  → ALL orders
//   NSM slot                → All RSM/ASM/Sales orders in their channel
//   RSM slot                → ASM + Sales in same zone + channel
//   ASM slot                → Sales in same zone + channel
//   Sales / Sales Exec      → Own orders only
// ─────────────────────────────────────────────────────────────────────────────

const _bg     = Color(0xFF060E1A);
const _card   = Color(0xFF0D1829);
const _teal   = Color(0xFF1ABFA1);
const _sub    = Color(0xFF64748B);
const _white  = Colors.white;

class OrgMemberDataSheet extends StatefulWidget {
  final User member;        // the person whose card was tapped
  final String slotKey;    // e.g. 'rsm_north_retail'
  final Color  accentColor;

  const OrgMemberDataSheet({
    super.key,
    required this.member,
    required this.slotKey,
    required this.accentColor,
  });

  @override
  State<OrgMemberDataSheet> createState() => _OrgMemberDataSheetState();
}

class _OrgMemberDataSheetState extends State<OrgMemberDataSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  DateTime _focusMonth = DateTime.now();
  DateTime? _selectedDate;
  List<Order> _teamOrders = [];
  List<Map<String, dynamic>> _auditLogs = [];
  bool _loading = true;
  bool _loadingLogs = true;

  // ── Init ──────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    _tab.addListener(() {
      if (_tab.index == 2 && _auditLogs.isEmpty) {
        _loadAuditLogs();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOrders();
      _loadAuditLogs();
    });
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  // ── Load orders for this person's team ───────────────────────────────────

  void _loadOrders() {
    final nexus = Provider.of<NexusProvider>(context, listen: false);
    final allOrders = nexus.orders;
    final allUsers  = nexus.users;

    final teamIds = _getTeamIds(allUsers);
    setState(() {
      _teamOrders = allOrders
          .where((o) => teamIds.contains(o.salespersonId))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _loading = false;
    });
  }

  Future<void> _loadAuditLogs() async {
    final nexus = Provider.of<NexusProvider>(context, listen: false);
    final logs = await nexus.fetchUserAuditLogs(widget.member.id);
    if (mounted) {
      setState(() {
        _auditLogs = logs;
        _loadingLogs = false;
      });
    }
  }

  /// Collect salesperson IDs visible to this member based on slot + hierarchy
  Set<String> _getTeamIds(List<User> allUsers) {
    final slot = widget.slotKey.toLowerCase();

    // Top-level: see everything
    if (slot == 'chairman' || slot == 'ceo') {
      return allUsers.map((u) => u.id).toSet();
    }
    // NSM: see all users in their channel (retail or horeca)
    if (slot.startsWith('nsm_')) {
      final channel = slot.contains('horeca') ? 'horeca' : 'retail';
      return allUsers.where((u) => _channelMatch(u, channel)).map((u) => u.id).toSet();
    }
    // RSM: see users with same zone + channel (ASM + Sales)
    if (slot.startsWith('rsm_')) {
      final parts   = slot.split('_'); // rsm_north_retail
      final zone    = parts.length > 1 ? parts[1].toUpperCase() : '';
      final channel = slot.contains('horeca') ? 'horeca' : 'retail';
      return allUsers.where((u) =>
          (u.role == UserRole.asm ||
           u.role == UserRole.sales ||
           u.role == UserRole.salesExecutive) &&
          (zone == 'ALL' || u.zone.toUpperCase() == zone) &&
          _channelMatch(u, channel)).map((u) => u.id).toSet();
    }
    // ASM: see Sales in same zone + channel
    if (slot.startsWith('asm_')) {
      final parts   = slot.split('_');
      final zone    = parts.length > 1 ? parts[1].toUpperCase() : '';
      final channel = slot.contains('horeca') ? 'horeca' : 'retail';
      return allUsers.where((u) =>
          (u.role == UserRole.sales ||
           u.role == UserRole.salesExecutive) &&
          (zone == 'ALL' || u.zone.toUpperCase() == zone) &&
          _channelMatch(u, channel)).map((u) => u.id).toSet();
    }
    // Sales: own orders only
    return {widget.member.id};
  }

  bool _channelMatch(User u, String channel) {
    final ch = '${u.channel ?? ''} ${u.department2 ?? ''}'.toLowerCase();
    if (channel == 'retail') return !ch.contains('horeca') && !ch.contains('wholesale');
    return ch.contains('horeca') || ch.contains('wholesale') || ch.contains('all channel');
  }

  // ── Derived data ─────────────────────────────────────────────────────────

  List<Order> get _dateOrders {
    if (_selectedDate == null) return [];
    return _teamOrders.where((o) =>
        o.createdAt.year  == _selectedDate!.year &&
        o.createdAt.month == _selectedDate!.month &&
        o.createdAt.day   == _selectedDate!.day).toList();
  }

  /// Count of orders on a given calendar day
  int _ordersOnDay(DateTime d) => _teamOrders.where((o) =>
      o.createdAt.year == d.year &&
      o.createdAt.month == d.month &&
      o.createdAt.day == d.day).length;

  /// Check if there was any activity (Audit Log) on this day
  bool _hasActivityOnDay(DateTime d) {
    return _auditLogs.any((log) {
      final ts = DateTime.tryParse(log['timestamp'] ?? '');
      if (ts == null) return false;
      return ts.year == d.year && ts.month == d.month && ts.day == d.day;
    });
  }

  double get _totalRevenue => _teamOrders.fold(0.0, (s, o) => s + (o.total));
  int get _pendingCount =>
      _teamOrders.where((o) => !_isDone(o.status)).length;
  int get _deliveredCount =>
      _teamOrders.where((o) => _isDone(o.status)).length;

  bool _isDone(String s) =>
      s.toLowerCase().contains('deliver') ||
      s.toLowerCase().contains('complet') ||
      s.toLowerCase().contains('closed');

  // ── BUILD ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final init = widget.member.name.trim().split(' ')
        .take(2).map((p) => p.isNotEmpty ? p[0].toUpperCase() : '').join();

    return Container(
      height: MediaQuery.of(context).size.height * 0.93,
      decoration: const BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(children: [
        // Handle
        Container(width: 36, height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
                color: Colors.white12, borderRadius: BorderRadius.circular(2))),

        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Row(children: [
            Container(
              width: 46, height: 46,
              decoration: BoxDecoration(
                  color: widget.accentColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle),
              child: Center(child: Text(init,
                  style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: widget.accentColor))),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.member.name,
                      style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          color: _white)),
                  const SizedBox(height: 2),
                  Text(widget.member.id,
                      style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: _sub)),
                  const SizedBox(height: 4),
                  Row(children: [
                    _chip(widget.slotKey.toUpperCase().replaceAll('_', ' '),
                        widget.accentColor),
                    const SizedBox(width: 6),
                    _chip(widget.member.zone, _sub),
                  ]),
                ])),
            // Stats badge
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('${_teamOrders.length}',
                  style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                      color: widget.accentColor)),
              Text('TOTAL ORDERS',
                  style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      color: _sub,
                      letterSpacing: 0.5)),
            ]),
          ]),
        ),

        const SizedBox(height: 14),

        // Stats row
        if (!_loading) _statsRow(),

        const SizedBox(height: 12),

        // Tab bar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
              color: _card, borderRadius: BorderRadius.circular(12)),
          child: TabBar(
            controller: _tab,
            labelStyle: const TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w800,
                fontSize: 10,
                letterSpacing: 0.5),
            unselectedLabelStyle: const TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
                fontSize: 10),
            labelColor: widget.accentColor,
            unselectedLabelColor: _sub,
            indicator: BoxDecoration(
                color: widget.accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10)),
            tabs: const [
              Tab(text: 'CALENDAR'),
              Tab(text: 'ALL ORDERS'),
              Tab(text: 'ARCHIVES'),
            ],
          ),
        ),

        const SizedBox(height: 4),

        // Tab content
        Expanded(
          child: _loading
              ? Center(child: CircularProgressIndicator(
                  color: widget.accentColor, strokeWidth: 2))
              : TabBarView(
                  controller: _tab,
                  children: [
                    _calendarTab(),
                    _ordersTab(_teamOrders),
                    _archiveTab(),
                  ],
                ),
        ),
      ]),
    );
  }

  // ── Stats row ────────────────────────────────────────────────────────────

  Widget _statsRow() {
    final fmt = NumberFormat.compact(locale: 'en_IN');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(children: [
        _statBox('REVENUE', '₹${fmt.format(_totalRevenue)}',
            _teal, Icons.currency_rupee_rounded),
        const SizedBox(width: 8),
        _statBox('PENDING', '$_pendingCount',
            const Color(0xFFF97316), Icons.pending_actions_rounded),
        const SizedBox(width: 8),
        _statBox('DELIVERED', '$_deliveredCount',
            const Color(0xFF10B981), Icons.check_circle_rounded),
      ]),
    );
  }

  Widget _statBox(String label, String value, Color color, IconData icon) =>
      Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: 0.2))),
          child: Row(children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value,
                      style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                          color: color)),
                  Text(label,
                      style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 7,
                          fontWeight: FontWeight.w700,
                          color: _sub,
                          letterSpacing: 0.4)),
                ])),
          ]),
        ),
      );

  // ── Calendar tab ─────────────────────────────────────────────────────────

  Widget _calendarTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _calendarWidget(),
        const SizedBox(height: 16),
        if (_selectedDate != null) ...[
          Row(children: [
            Icon(Icons.calendar_today_rounded,
                size: 13, color: widget.accentColor),
            const SizedBox(width: 6),
            Text(
              'Orders on ${DateFormat('dd MMMM yyyy').format(_selectedDate!)}',
              style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  color: widget.accentColor),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                  color: widget.accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8)),
              child: Text('${_dateOrders.length}',
                  style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                      color: widget.accentColor)),
            ),
          ]),
          const SizedBox(height: 10),
          if (_dateOrders.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(14)),
              child: const Column(children: [
                Icon(Icons.inbox_rounded, size: 32, color: _sub),
                SizedBox(height: 8),
                Text('No orders on this date',
                    style: TextStyle(
                        fontFamily: 'Montserrat',
                        color: _sub,
                        fontWeight: FontWeight.w600,
                        fontSize: 12)),
              ]),
            )
          else
            ..._dateOrders.map((o) => _orderCard(o)),
        ] else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
                color: _card, borderRadius: BorderRadius.circular(14)),
            child: const Column(children: [
              Icon(Icons.touch_app_rounded, size: 32, color: _sub),
              SizedBox(height: 8),
              Text('Tap a date to see orders',
                  style: TextStyle(
                      fontFamily: 'Montserrat',
                      color: _sub,
                      fontWeight: FontWeight.w600,
                      fontSize: 12)),
            ]),
          ),
      ]),
    );
  }

  // ── Custom calendar grid ─────────────────────────────────────────────────

  Widget _calendarWidget() {
    final firstDay = DateTime(_focusMonth.year, _focusMonth.month, 1);
    final daysInMonth =
        DateTime(_focusMonth.year, _focusMonth.month + 1, 0).day;
    final startWeekday = firstDay.weekday % 7; // 0=Sun

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: _card, borderRadius: BorderRadius.circular(16)),
      child: Column(children: [
        // Month navigation
        Row(children: [
          IconButton(
            onPressed: () => setState(() =>
                _focusMonth = DateTime(_focusMonth.year, _focusMonth.month - 1)),
            icon: const Icon(Icons.chevron_left_rounded, color: _white),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          Expanded(
            child: Text(
              DateFormat('MMMM yyyy').format(_focusMonth),
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  color: _white),
            ),
          ),
          IconButton(
            onPressed: () => setState(() =>
                _focusMonth = DateTime(_focusMonth.year, _focusMonth.month + 1)),
            icon: const Icon(Icons.chevron_right_rounded, color: _white),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ]),
        const SizedBox(height: 10),

        // Day headers
        Row(children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
            .map((d) => Expanded(
                  child: Text(d,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w800,
                          fontSize: 10,
                          color: _sub)),
                ))
            .toList()),
        const SizedBox(height: 6),

        // Days grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
              crossAxisSpacing: 2,
              mainAxisSpacing: 2),
          itemCount: startWeekday + daysInMonth,
          itemBuilder: (_, i) {
            if (i < startWeekday) return const SizedBox();
            final day = i - startWeekday + 1;
            final date = DateTime(_focusMonth.year, _focusMonth.month, day);
            final orderCount = _ordersOnDay(date);
            final hasActivity = _hasActivityOnDay(date);
            final isSelected = _selectedDate?.year == date.year &&
                _selectedDate?.month == date.month &&
                _selectedDate?.day == date.day;
            final isToday = DateTime.now().year == date.year &&
                DateTime.now().month == date.month &&
                DateTime.now().day == date.day;

            return GestureDetector(
              onTap: () => setState(() => _selectedDate = date),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  color: isSelected
                      ? widget.accentColor
                      : orderCount > 0
                          ? widget.accentColor.withValues(alpha: 0.12)
                          : hasActivity
                              ? _sub.withValues(alpha: 0.05)
                              : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: isToday && !isSelected
                      ? Border.all(
                          color: widget.accentColor.withValues(alpha: 0.5))
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('$day',
                        style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                            color: isSelected
                                ? Colors.white
                                : orderCount > 0
                                    ? widget.accentColor
                                    : hasActivity
                                        ? _white
                                        : _white.withValues(alpha: 0.5))),
                    if (orderCount > 0 || hasActivity)
                      Container(
                        width: 4, height: 4,
                        margin: const EdgeInsets.only(top: 1),
                        decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white
                                : orderCount > 0
                                    ? widget.accentColor
                                    : _sub,
                            shape: BoxShape.circle),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ]),
    );
  }

  // ── All Orders tab ───────────────────────────────────────────────────────

  Widget _ordersTab(List<Order> orders) {
    if (orders.isEmpty) {
      return Center(child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.receipt_long_rounded, size: 40, color: _sub),
            const SizedBox(height: 10),
            const Text('No orders found',
                style: TextStyle(
                    fontFamily: 'Montserrat',
                    color: _sub,
                    fontWeight: FontWeight.w600)),
          ]));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) => _orderCard(orders[i]),
    );
  }

  // ── Archive tab ──────────────────────────────────────────────────────────

  Widget _archiveTab() {
    if (_loadingLogs) {
      return Center(child: CircularProgressIndicator(color: widget.accentColor, strokeWidth: 2));
    }
    if (_auditLogs.isEmpty) {
      return Center(child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.history_rounded, size: 40, color: _sub),
            const SizedBox(height: 10),
            const Text('No activity history found',
                style: TextStyle(
                    fontFamily: 'Montserrat',
                    color: _sub,
                    fontWeight: FontWeight.w600)),
          ]));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _auditLogs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final log = _auditLogs[i];
        final action = log['action'] ?? 'ACTIVITY';
        final entity = log['entityType'] ?? 'SYSTEM';
        final tsStr = log['timestamp'] ?? '';
        final ts = DateTime.tryParse(tsStr) ?? DateTime.now();
        
        Color actionColor = widget.accentColor;
        IconData icon = Icons.info_outline_rounded;

        if (action.contains('CREATE')) { actionColor = _teal; icon = Icons.add_circle_outline_rounded; }
        else if (action.contains('UPDATE')) { actionColor = const Color(0xFF3B82F6); icon = Icons.edit_note_rounded; }
        else if (action.contains('DELETE')) { actionColor = Colors.redAccent; icon = Icons.delete_outline_rounded; }
        else if (action.contains('LOGIN')) { actionColor = Colors.orange; icon = Icons.login_rounded; }

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: _card, borderRadius: BorderRadius.circular(14)),
          child: Row(children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                  color: actionColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle),
              child: Icon(icon, color: actionColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(action,
                      style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                          color: actionColor,
                          letterSpacing: 0.5)),
                  const SizedBox(height: 2),
                  Text('${entity} - ${log['entityId'] ?? ''}',
                      style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                          color: _white)),
                  const SizedBox(height: 2),
                  Text(DateFormat('dd MMM yyyy, hh:mm a').format(ts),
                      style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 8,
                          color: _sub)),
                ])),
            if (log['success'] == false)
              const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 14),
          ]),
        );
      },
    );
  }

  // ── Order card ───────────────────────────────────────────────────────────

  Widget _orderCard(Order order) {
    final isDone = _isDone(order.status);
    final statusColor = isDone
        ? const Color(0xFF10B981)
        : order.status.toLowerCase().contains('pending')
            ? const Color(0xFFF97316)
            : widget.accentColor;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: statusColor.withValues(alpha: 0.2))),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10)),
          child: Icon(
            isDone
                ? Icons.check_circle_rounded
                : Icons.pending_actions_rounded,
            color: statusColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(order.customerName,
                  style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      color: _white)),
              const SizedBox(height: 3),
              Row(children: [
                Text(order.id,
                    style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 9,
                        color: _sub)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(5)),
                  child: Text(order.status,
                      style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 7,
                          fontWeight: FontWeight.w800,
                          color: statusColor)),
                ),
              ]),
              const SizedBox(height: 2),
              Text(DateFormat('dd MMM yyyy  hh:mm a').format(order.createdAt),
                  style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 8,
                      color: _sub)),
            ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('₹${NumberFormat('#,##,###').format(order.total)}',
              style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  color: widget.accentColor)),
          Text('${order.items.length} items',
              style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 8,
                  color: _sub)),
        ]),
      ]),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _chip(String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color.withValues(alpha: 0.25))),
        child: Text(label,
            style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 8,
                fontWeight: FontWeight.w800,
                color: color)),
      );
}
