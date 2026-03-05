import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/nexus_provider.dart';
import '../providers/auth_provider.dart';
import '../models/models.dart';
import '../utils/theme.dart';

class OrderArchiveScreen extends StatefulWidget {
  const OrderArchiveScreen({super.key});

  @override
  State<OrderArchiveScreen> createState() => _OrderArchiveScreenState();
}

class _OrderArchiveScreenState extends State<OrderArchiveScreen> {
  List<Map<String, dynamic>> _logs = [];
  bool _loading = true;

  // Dropdown filter values
  String _filterAction = 'ALL';
  String _selectedRole = 'ALL';
  String? _selectedUserId;
  String? _selectedUserName;
  DateTimeRange? _dateRange;

  static const List<String> _actionOptions = [
    'ALL', 'CREATE', 'UPDATE', 'STATUS_CHANGE', 'DELETE'
  ];
  static const List<String> _roleOptions = [
    'ALL', 'Admin', 'NSM', 'RSM', 'ASM', 'Sales'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadLogs());
  }

  Future<void> _loadLogs() async {
    final nexus = Provider.of<NexusProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    setState(() => _loading = true);

    final logs = await nexus.fetchAuditLogs(
      entityType: 'ORDER',
      limit: 200,
      role: _selectedRole == 'ALL' ? null : _selectedRole,
      userId: _selectedUserId,
      fromDate: _dateRange?.start,
      toDate: _dateRange?.end,
      token: auth.token,
    );

    if (mounted) {
      setState(() {
        _logs = logs;
        _loading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredLogs {
    if (_filterAction == 'ALL') return _logs;
    return _logs
        .where((l) => (l['action'] ?? '').toString().toUpperCase() == _filterAction)
        .toList();
  }

  void _resetAllFilters() {
    setState(() {
      _filterAction = 'ALL';
      _selectedRole = 'ALL';
      _selectedUserId = null;
      _selectedUserName = null;
      _dateRange = null;
    });
    _loadLogs();
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
      builder: (context, child) => Theme(
        data: NexusTheme.lightTheme.copyWith(
          colorScheme: ColorScheme.fromSeed(
            seedColor: NexusTheme.emerald600,
            primary: NexusTheme.emerald600,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _dateRange = picked);
      _loadLogs();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NexusTheme.slate50,
      appBar: AppBar(
        title: const Text(
          'ORDER MASTER ARCHIVE',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: _loadLogs,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterPanel(),
          _buildActiveFilterChips(),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                : _filteredLogs.isEmpty
                    ? _buildEmptyState()
                    : _buildLogsList(),
          ),
        ],
      ),
    );
  }

  // ─── FILTER PANEL ─────────────────────────────────────────────────────────
  Widget _buildFilterPanel() {
    final nexus = Provider.of<NexusProvider>(context);
    final filteredUsers = nexus.users.where((u) {
      if (_selectedRole == 'ALL') return true;
      return u.role.label == _selectedRole;
    }).toList();

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: NexusTheme.slate100)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Action Dropdown
              Expanded(
                child: _buildDropdown<String>(
                  icon: Icons.filter_alt_rounded,
                  label: 'Action',
                  value: _filterAction,
                  items: _actionOptions,
                  itemLabel: (a) => a.replaceAll('_', ' '),
                  onChanged: (v) => setState(() => _filterAction = v ?? 'ALL'),
                ),
              ),
              const SizedBox(width: 8),
              // Date Range Button
              GestureDetector(
                onTap: _pickDateRange,
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: _dateRange != null ? NexusTheme.emerald50 : NexusTheme.slate50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _dateRange != null ? NexusTheme.emerald300 : NexusTheme.slate200,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_month_rounded,
                        size: 16,
                        color: _dateRange != null ? NexusTheme.emerald600 : NexusTheme.slate500,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _dateRange != null
                            ? '${DateFormat('dd MMM').format(_dateRange!.start)} – ${DateFormat('dd MMM').format(_dateRange!.end)}'
                            : 'Date',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _dateRange != null ? NexusTheme.emerald700 : NexusTheme.slate500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // Role Dropdown
              Expanded(
                child: _buildDropdown<String>(
                  icon: Icons.badge_rounded,
                  label: 'Role',
                  value: _selectedRole,
                  items: _roleOptions,
                  itemLabel: (r) => r,
                  onChanged: (v) {
                    setState(() {
                      _selectedRole = v ?? 'ALL';
                      _selectedUserId = null;
                      _selectedUserName = null;
                    });
                    _loadLogs();
                  },
                ),
              ),
              const SizedBox(width: 8),
              // User Dropdown
              Expanded(
                child: _buildDropdown<String>(
                  icon: Icons.person_rounded,
                  label: 'User',
                  value: _selectedUserId,
                  items: filteredUsers.map((u) => u.id).toList(),
                  itemLabel: (id) {
                    final u = filteredUsers.firstWhere((u) => u.id == id, orElse: () => filteredUsers.first);
                    return '${u.name} (${u.role.label})';
                  },
                  nullLabel: 'All Users',
                  onChanged: (v) {
                    final u = filteredUsers.where((u) => u.id == v).firstOrNull;
                    setState(() {
                      _selectedUserId = v;
                      _selectedUserName = u?.name;
                    });
                    _loadLogs();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown<T>({
    required IconData icon,
    required String label,
    required T? value,
    required List<T> items,
    required String Function(T) itemLabel,
    String? nullLabel,
    required void Function(T?) onChanged,
  }) {
    final bool isActive = value != null && value.toString() != 'ALL';

    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: isActive ? NexusTheme.emerald50 : NexusTheme.slate50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isActive ? NexusTheme.emerald300 : NexusTheme.slate200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded, size: 18,
              color: isActive ? NexusTheme.emerald600 : NexusTheme.slate400),
          style: const TextStyle(fontFamily: 'default'),
          hint: Row(
            children: [
              Icon(icon, size: 14, color: NexusTheme.slate400),
              const SizedBox(width: 6),
              Text(nullLabel ?? label,
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w700, color: NexusTheme.slate500)),
            ],
          ),
          selectedItemBuilder: (context) {
            final allItems = <T?>[];
            if (nullLabel != null) allItems.add(null);
            allItems.addAll(items);

            return allItems.map((item) {
              final displayText = item == null
                  ? (nullLabel ?? label)
                  : (item.toString() == 'ALL' ? label : itemLabel(item));
              return Row(
                children: [
                  Icon(icon, size: 14,
                      color: isActive ? NexusTheme.emerald600 : NexusTheme.slate400),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      displayText,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: isActive ? NexusTheme.emerald700 : NexusTheme.slate600,
                      ),
                    ),
                  ),
                ],
              );
            }).toList();
          },
          items: [
            if (nullLabel != null)
              DropdownMenuItem<T>(
                value: null,
                child: Text(nullLabel,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w700, color: NexusTheme.slate500)),
              ),
            ...items.map((item) => DropdownMenuItem<T>(
                  value: item,
                  child: Text(itemLabel(item),
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600, color: NexusTheme.slate700),
                      overflow: TextOverflow.ellipsis),
                )),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }

  // ─── ACTIVE FILTER CHIPS ──────────────────────────────────────────────────
  Widget _buildActiveFilterChips() {
    final hasFilters = _dateRange != null ||
        _selectedRole != 'ALL' ||
        _selectedUserId != null ||
        _filterAction != 'ALL';

    if (!hasFilters) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: NexusTheme.emerald50,
      child: Row(
        children: [
          Expanded(
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                if (_filterAction != 'ALL')
                  _Chip(
                    label: _filterAction.replaceAll('_', ' '),
                    color: NexusTheme.blue600,
                    onDelete: () => setState(() => _filterAction = 'ALL'),
                  ),
                if (_selectedRole != 'ALL')
                  _Chip(
                    label: 'Role: $_selectedRole',
                    color: NexusTheme.amber600,
                    onDelete: () {
                      setState(() {
                        _selectedRole = 'ALL';
                        _selectedUserId = null;
                        _selectedUserName = null;
                      });
                      _loadLogs();
                    },
                  ),
                if (_selectedUserId != null)
                  _Chip(
                    label: _selectedUserName ?? _selectedUserId!,
                    color: NexusTheme.emerald600,
                    onDelete: () {
                      setState(() {
                        _selectedUserId = null;
                        _selectedUserName = null;
                      });
                      _loadLogs();
                    },
                  ),
                if (_dateRange != null)
                  _Chip(
                    label:
                        '${DateFormat('dd MMM').format(_dateRange!.start)} – ${DateFormat('dd MMM').format(_dateRange!.end)}',
                    color: NexusTheme.slate600,
                    onDelete: () {
                      setState(() => _dateRange = null);
                      _loadLogs();
                    },
                  ),
              ],
            ),
          ),
          TextButton(
            onPressed: _resetAllFilters,
            style: TextButton.styleFrom(
              foregroundColor: NexusTheme.emerald700,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Reset',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  // ─── EMPTY STATE ─────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off_rounded, size: 64, color: NexusTheme.slate200),
          const SizedBox(height: 16),
          const Text('No log entries match your filters',
              style: TextStyle(
                  color: NexusTheme.slate400, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          const Text('Try adjusting filters or refreshing',
              style: TextStyle(
                  color: NexusTheme.slate300, fontSize: 12, fontWeight: FontWeight.w500)),
          const SizedBox(height: 24),
          TextButton.icon(
            onPressed: _resetAllFilters,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Reset All Filters',
                style: TextStyle(fontWeight: FontWeight.w900)),
            style: TextButton.styleFrom(
              foregroundColor: NexusTheme.emerald600,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  // ─── LOGS LIST ────────────────────────────────────────────────────────────
  Widget _buildLogsList() {
    final provider = Provider.of<NexusProvider>(context, listen: false);
    final userRole = provider.currentUser?.role;
    final canSeePhotos = userRole == UserRole.admin ||
        userRole == UserRole.rsm ||
        userRole == UserRole.asm;

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredLogs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final log = _filteredLogs[i];
        final action = log['action'] ?? 'UNKNOWN';
        final user = log['userName'] ?? 'System';
        final tsStr = log['timestamp'] ?? '';
        final ts = DateTime.tryParse(tsStr)?.toLocal() ?? DateTime.now();
        final entityId = log['entityId'] ?? 'N/A';
        final data = log['newData'] ?? log['oldData'];
        final customerName = data?['customerName'] ?? data?['name'] ?? '';
        final rawPhotos = data?['salesPhotos'];
        final List<String> salesPhotos = rawPhotos is List
            ? rawPhotos.whereType<String>().where((s) => s.startsWith('http')).toList()
            : [];
        final hasPhotos = canSeePhotos && salesPhotos.isNotEmpty;

        Color color = NexusTheme.slate600;
        IconData icon = Icons.info_outline_rounded;

        if (action.contains('CREATE')) {
          color = NexusTheme.emerald600;
          icon = Icons.add_box_rounded;
        } else if (action.contains('UPDATE')) {
          color = NexusTheme.blue600;
          icon = Icons.edit_square;
        } else if (action.contains('STATUS')) {
          color = NexusTheme.amber600;
          icon = Icons.published_with_changes_rounded;
        } else if (action.contains('DELETE')) {
          color = NexusTheme.rose600;
          icon = Icons.delete_forever_rounded;
        }

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: hasPhotos ? NexusTheme.emerald200 : NexusTheme.slate100),
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(
                  width: 5,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16)),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header row
                        Row(
                          children: [
                            Icon(icon, size: 16, color: color),
                            const SizedBox(width: 8),
                            Text(
                              action.toString().replaceAll('_', ' '),
                              style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12,
                                  color: color),
                            ),
                            const Spacer(),
                            if (hasPhotos)
                              Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: NexusTheme.emerald50,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: NexusTheme.emerald200),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.photo_camera_rounded,
                                        size: 10, color: NexusTheme.emerald600),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${salesPhotos.length} PHOTO${salesPhotos.length > 1 ? 'S' : ''}',
                                      style: const TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w900,
                                          color: NexusTheme.emerald600),
                                    ),
                                  ],
                                ),
                              ),
                            Text(
                              DateFormat('dd MMM, hh:mm a').format(ts),
                              style: const TextStyle(
                                  fontSize: 10,
                                  color: NexusTheme.slate400,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Customer name
                        if (customerName.isNotEmpty)
                          Text(customerName,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                  color: NexusTheme.slate900)),
                        const SizedBox(height: 2),
                        Text('Order ID: $entityId',
                            style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                                color: NexusTheme.slate400)),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.person_pin_rounded,
                                size: 13, color: NexusTheme.slate400),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '${action.contains('CREATE') ? 'Placed by' : 'Modified by'}: $user',
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: NexusTheme.slate500,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(DateFormat('dd MMM yyyy').format(ts),
                                    style: const TextStyle(
                                        fontSize: 10,
                                        color: NexusTheme.slate600,
                                        fontWeight: FontWeight.w700)),
                                Text(DateFormat('hh:mm:ss a').format(ts),
                                    style: const TextStyle(
                                        fontSize: 9,
                                        color: NexusTheme.slate400,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ],
                        ),
                        if (log['newData'] != null &&
                            log['newData']['status'] != null) ...[
                          const SizedBox(height: 8),
                          _buildStatusUpdate(
                              log['oldData']?['status'], log['newData']['status']),
                        ],
                        if (hasPhotos) ...[
                          const SizedBox(height: 12),
                          _buildSalesPhotosRow(salesPhotos),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── SALES PHOTOS ─────────────────────────────────────────────────────────
  Widget _buildSalesPhotosRow(List<String> photos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('SALES PHOTOS',
            style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w900,
                color: NexusTheme.slate400,
                letterSpacing: 0.5)),
        const SizedBox(height: 6),
        SizedBox(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: photos.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) => GestureDetector(
              onTap: () => _showFullPhoto(context, photos, i),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  photos[i],
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                        color: NexusTheme.slate100,
                        borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.broken_image_rounded,
                        color: NexusTheme.slate400),
                  ),
                  loadingBuilder: (_, child, progress) => progress == null
                      ? child
                      : Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                              color: NexusTheme.slate50,
                              borderRadius: BorderRadius.circular(10)),
                          child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2)),
                        ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showFullPhoto(BuildContext context, List<String> photos, int initial) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(12),
        child: Stack(
          children: [
            PageView.builder(
              controller: PageController(initialPage: initial),
              itemCount: photos.length,
              itemBuilder: (_, i) => ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(photos[i], fit: BoxFit.contain),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration:
                      const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                  child: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusUpdate(String? oldStatus, String newStatus) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
          color: NexusTheme.slate50, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (oldStatus != null) ...[
            Text(oldStatus,
                style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: NexusTheme.slate400)),
            const SizedBox(width: 6),
            const Icon(Icons.arrow_forward_rounded,
                size: 10, color: NexusTheme.slate400),
            const SizedBox(width: 6),
          ],
          Text(newStatus,
              style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: NexusTheme.emerald600)),
        ],
      ),
    );
  }
}

// ─── CHIP WIDGET ──────────────────────────────────────────────────────────────
class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onDelete;

  const _Chip(
      {required this.label, required this.color, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 4, top: 4, bottom: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 10, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onDelete,
            child: Icon(Icons.cancel_rounded, size: 16, color: color.withValues(alpha: 0.7)),
          ),
        ],
      ),
    );
  }
}
