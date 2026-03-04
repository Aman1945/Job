import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/nexus_provider.dart';
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
  String _filterAction = 'ALL';
  
  // New Filters
  DateTimeRange? _dateRange;
  String _selectedRole = 'ALL';
  String? _selectedUserId;
  String? _selectedUserName;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    final nexus = Provider.of<NexusProvider>(context, listen: false);
    setState(() => _loading = true);
    
    final logs = await nexus.fetchAuditLogs(
      entityType: 'ORDER', 
      limit: 200,
      role: _selectedRole == 'ALL' ? null : _selectedRole,
      userId: _selectedUserId,
      fromDate: _dateRange?.start,
      toDate: _dateRange?.end,
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
    return _logs.where((l) => (l['action'] ?? '').toString().toUpperCase() == _filterAction).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NexusTheme.slate50,
      appBar: AppBar(
        title: const Text('ORDER MASTER ARCHIVE', 
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5)),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_rounded, color: NexusTheme.emerald600),
            tooltip: 'Filter by Date',
            onPressed: _pickDateRange,
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadLogs,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildActiveFilters(),
          _buildFilterBar(),
          Expanded(
            child: _loading 
              ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
              : _filteredLogs.isEmpty 
                ? _buildEmptyState()
                : _buildLogsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showHierarchyFilter,
        backgroundColor: NexusTheme.slate900,
        child: const Icon(Icons.filter_list_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildActiveFilters() {
    if (_dateRange == null && _selectedRole == 'ALL' && _selectedUserId == null) {
      return const SizedBox.shrink();
    }
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          if (_dateRange != null)
            _FilterChip(
              label: '${DateFormat('dd MMM').format(_dateRange!.start)} - ${DateFormat('dd MMM').format(_dateRange!.end)}',
              onDelete: () => setState(() { _dateRange = null; _loadLogs(); }),
            ),
          if (_selectedRole != 'ALL')
            _FilterChip(
              label: 'Role: $_selectedRole',
              onDelete: () => setState(() { _selectedRole = 'ALL'; _loadLogs(); }),
            ),
          if (_selectedUserId != null)
            _FilterChip(
              label: 'User: ${_selectedUserName ?? _selectedUserId}',
              onDelete: () => setState(() { _selectedUserId = null; _selectedUserName = null; _loadLogs(); }),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    final actions = ['ALL', 'CREATE', 'UPDATE', 'STATUS_CHANGE', 'DELETE'];
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: NexusTheme.slate100)),
      ),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: actions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final a = actions[i];
          final isSel = _filterAction == a;
          return GestureDetector(
            onTap: () => setState(() => _filterAction = a),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSel ? NexusTheme.emerald600 : NexusTheme.slate50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isSel ? NexusTheme.emerald600 : NexusTheme.slate200),
              ),
              child: Text(a.replaceFirst('_', ' '), 
                style: TextStyle(
                  fontSize: 10, 
                  fontWeight: FontWeight.w800, 
                  color: isSel ? Colors.white : NexusTheme.slate600
                )),
            ),
          );
        },
      ),
    );
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
      builder: (context, child) {
        return Theme(
          data: NexusTheme.lightTheme.copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: NexusTheme.emerald600,
              primary: NexusTheme.emerald600,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _dateRange = picked);
      _loadLogs();
    }
  }

  void _showHierarchyFilter() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _HierarchyFilterSheet(
        currentRole: _selectedRole,
        currentUserId: _selectedUserId,
        onApply: (role, userId, userName) {
          setState(() {
            _selectedRole = role;
            _selectedUserId = userId;
            _selectedUserName = userName;
          });
          _loadLogs();
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.history_toggle_off_rounded, size: 64, color: NexusTheme.slate200),
          const SizedBox(height: 16),
          Text('No log entries match your filters', 
            style: TextStyle(color: NexusTheme.slate400, fontWeight: FontWeight.w600)),
          TextButton(
            onPressed: () {
              setState(() {
                _dateRange = null;
                _selectedRole = 'ALL';
                _selectedUserId = null;
                _filterAction = 'ALL';
              });
              _loadLogs();
            },
            child: const Text('Reset All Filters'),
          ),
        ],
      ),
    );
  }

  Widget _buildLogsList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredLogs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final log = _filteredLogs[i];
        final action = log['action'] ?? 'UNKNOWN';
        final user = log['userName'] ?? 'System';
        final tsStr = log['timestamp'] ?? '';
        final ts = DateTime.tryParse(tsStr) ?? DateTime.now();
        final entityId = log['entityId'] ?? 'N/A';
        
        Color color = NexusTheme.slate600;
        IconData icon = Icons.info_outline_rounded;
        
        if (action.contains('CREATE')) { color = NexusTheme.emerald600; icon = Icons.add_box_rounded; }
        else if (action.contains('UPDATE')) { color = NexusTheme.blue600; icon = Icons.edit_square; }
        else if (action.contains('STATUS')) { color = NexusTheme.amber600; icon = Icons.published_with_changes_rounded; }
        else if (action.contains('DELETE')) { color = NexusTheme.rose600; icon = Icons.delete_forever_rounded; }

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: NexusTheme.slate100),
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(
                  width: 5,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(icon, size: 16, color: color),
                            const SizedBox(width: 8),
                            Text(action.toString().replaceAll('_', ' '), 
                              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: color)),
                            const Spacer(),
                            Text(DateFormat('dd MMM, hh:mm a').format(ts), 
                              style: const TextStyle(fontSize: 10, color: NexusTheme.slate400, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Order: $entityId', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: NexusTheme.slate900)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.person_pin_rounded, size: 14, color: NexusTheme.slate400),
                            const SizedBox(width: 4),
                            Text('Modified by: $user', style: const TextStyle(fontSize: 11, color: NexusTheme.slate500, fontWeight: FontWeight.w500)),
                          ],
                        ),
                        if (log['newData'] != null && log['newData']['status'] != null) ...[
                          const SizedBox(height: 8),
                          _buildStatusUpdate(log['oldData']?['status'], log['newData']['status']),
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

  Widget _buildStatusUpdate(String? oldStatus, String newStatus) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: NexusTheme.slate50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (oldStatus != null) ...[
            Text(oldStatus, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: NexusTheme.slate400)),
            const SizedBox(width: 6),
            const Icon(Icons.arrow_forward_rounded, size: 10, color: NexusTheme.slate400),
            const SizedBox(width: 6),
          ],
          Text(newStatus, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: NexusTheme.emerald600)),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onDelete;

  const _FilterChip({required this.label, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 4, top: 4, bottom: 4),
      decoration: BoxDecoration(
        color: NexusTheme.slate100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: NexusTheme.slate700)),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onDelete,
            child: const Icon(Icons.cancel_rounded, size: 16, color: NexusTheme.slate400),
          ),
        ],
      ),
    );
  }
}

class _HierarchyFilterSheet extends StatefulWidget {
  final String currentRole;
  final String? currentUserId;
  final Function(String role, String? userId, String? userName) onApply;

  const _HierarchyFilterSheet({
    required this.currentRole,
    this.currentUserId,
    required this.onApply,
  });

  @override
  State<_HierarchyFilterSheet> createState() => _HierarchyFilterSheetState();
}

class _HierarchyFilterSheetState extends State<_HierarchyFilterSheet> {
  late String _role;
  String? _userId;
  String? _userName;

  @override
  void initState() {
    super.initState();
    _role = widget.currentRole;
    _userId = widget.currentUserId;
  }

  @override
  Widget build(BuildContext context) {
    final nexus = Provider.of<NexusProvider>(context);
    final roles = ['ALL', 'Admin', 'NSM', 'RSM', 'ASM', 'Sales'];
    
    final filteredUsers = nexus.users.where((u) {
      if (_role == 'ALL') return true;
      return u.role.label == _role;
    }).toList();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('HIERARCHY FILTERS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
              const Spacer(),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
            ],
          ),
          const SizedBox(height: 20),
          const Text('SELECT ROLE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: NexusTheme.slate400)),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: roles.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final r = roles[i];
                final isSel = _role == r;
                return GestureDetector(
                  onTap: () => setState(() { _role = r; _userId = null; _userName = null; }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSel ? NexusTheme.emerald600 : NexusTheme.slate50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isSel ? NexusTheme.emerald600 : NexusTheme.slate200),
                    ),
                    child: Text(r, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: isSel ? Colors.white : NexusTheme.slate600)),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          const Text('SELECT SPECIFIC USER', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: NexusTheme.slate400)),
          const SizedBox(height: 12),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: NexusTheme.slate50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: NexusTheme.slate100),
            ),
            child: filteredUsers.isEmpty
                ? const Center(child: Text('No users found for this role'))
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, i) {
                      final u = filteredUsers[i];
                      final isSel = _userId == u.id;
                      return ListTile(
                        onTap: () => setState(() { _userId = u.id; _userName = u.name; }),
                        leading: CircleAvatar(
                          backgroundColor: isSel ? NexusTheme.emerald600 : NexusTheme.slate200,
                          child: Text(u.name.substring(0, 1).toUpperCase(), 
                            style: TextStyle(color: isSel ? Colors.white : NexusTheme.slate600, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                        title: Text(u.name, style: TextStyle(fontSize: 13, fontWeight: isSel ? FontWeight.w800 : FontWeight.w600)),
                        subtitle: Text(u.role.label, style: const TextStyle(fontSize: 11)),
                        trailing: isSel ? const Icon(Icons.check_circle_rounded, color: NexusTheme.emerald600) : null,
                      );
                    },
                  ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                widget.onApply(_role, _userId, _userName);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: NexusTheme.emerald600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text('APPLY FILTERS', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
