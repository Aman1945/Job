import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/nexus_provider.dart';
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

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    final nexus = Provider.of<NexusProvider>(context, listen: false);
    final logs = await nexus.fetchAuditLogs(entityType: 'ORDER', limit: 200);
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
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              setState(() => _loading = true);
              _loadLogs();
            },
          ),
        ],
      ),
      body: Column(
        children: [
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
    );
  }

  Widget _buildFilterBar() {
    final actions = ['ALL', 'CREATE', 'UPDATE', 'STATUS_CHANGE', 'DELETE'];
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 12),
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
                color: isSel ? NexusTheme.emerald600 : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isSel ? NexusTheme.emerald600 : NexusTheme.slate200),
                boxShadow: isSel ? [BoxShadow(color: NexusTheme.emerald600.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))] : null,
              ),
              child: Text(a.replaceFirst('_', ' '), 
                style: TextStyle(
                  fontSize: 11, 
                  fontWeight: FontWeight.w800, 
                  color: isSel ? Colors.white : NexusTheme.slate600
                )),
            ),
          );
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
          Text('No order history found', 
            style: TextStyle(color: NexusTheme.slate400, fontWeight: FontWeight.w600)),
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
