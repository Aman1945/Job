import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/nexus_provider.dart';
import '../providers/auth_provider.dart';
import '../models/models.dart';
import '../utils/theme.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'order_details_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderArchiveScreen extends StatefulWidget {
  const OrderArchiveScreen({super.key});

  @override
  State<OrderArchiveScreen> createState() => _OrderArchiveScreenState();
}

class _OrderArchiveScreenState extends State<OrderArchiveScreen> {
  bool _loading = true;
  String _searchQuery = '';
  String _statusFilter = 'ALL';

  @override
  void initState() {
    super.initState();
    _refreshOrders();
  }

  Future<void> _refreshOrders() async {
    setState(() => _loading = true);
    final provider = Provider.of<NexusProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    await provider.fetchOrders();
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NexusProvider>(context);
    List<Order> orders = provider.orders;

    // Filter orders
    if (_statusFilter != 'ALL') {
      orders = orders.where((o) => o.status == _statusFilter).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      orders = orders.where((o) => 
        o.id.toLowerCase().contains(q) || 
        o.customerName.toLowerCase().contains(q)
      ).toList();
    }

    return Scaffold(
      backgroundColor: NexusTheme.slate50,
      appBar: AppBar(
        title: const Text('ORDER MASTER ARCHIVE', 
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw, size: 20),
            onPressed: _refreshOrders,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(),
          _buildTableHeader(),
          Expanded(
            child: _loading 
              ? const Center(child: CircularProgressIndicator())
              : orders.isEmpty 
                ? _buildEmptyState()
                : ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: orders.length,
                    itemBuilder: (context, index) => _buildOrderRow(orders[index]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search mission or customer...',
                prefixIcon: const Icon(LucideIcons.search, size: 18),
                filled: true,
                fillColor: NexusTheme.slate50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: NexusTheme.slate50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _statusFilter,
                style: const TextStyle(fontWeight: FontWeight.bold, color: NexusTheme.slate700, fontSize: 12),
                items: ['ALL', 'Pending', 'Credit Approved', 'In Transit', 'Completed', 'Cancelled']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (v) => setState(() => _statusFilter = v!),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: NexusTheme.slate100,
        border: Border(bottom: BorderSide(color: NexusTheme.slate200)),
      ),
      child: Row(
        children: const [
          Expanded(flex: 3, child: Text('MISSION / CUSTOMER', style: _headerStyle)),
          Expanded(flex: 2, child: Text('STATUS', style: _headerStyle)),
          Expanded(flex: 2, child: Text('DOCS', style: _headerStyle)),
          Expanded(flex: 2, child: Text('VALUE', style: _headerStyle, textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  static const _headerStyle = TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: NexusTheme.slate500, letterSpacing: 0.5);

  Widget _buildOrderRow(Order order) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OrderDetailsScreen(orderId: order.id))),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: NexusTheme.slate100)),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(order.id, style: const TextStyle(fontWeight: FontWeight.w900, color: NexusTheme.emerald600, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(order.customerName, 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: NexusTheme.slate900),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: _buildStatusPill(order.status),
            ),
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  _buildIconLink(LucideIcons.fileText, order.invoiceUrl, 'Invoice'),
                  const SizedBox(width: 8),
                  _buildIconLink(LucideIcons.image, order.podUrl, 'POD'),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                '₹${NumberFormat('#,##,###').format(order.total)}',
                textAlign: TextAlign.right,
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: NexusTheme.slate900),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusPill(String status) {
    Color color = NexusTheme.slate500;
    Color bg = NexusTheme.slate100;
    
    if (status == 'Completed') { color = NexusTheme.emerald600; bg = NexusTheme.emerald50; }
    else if (status == 'In Transit') { color = NexusTheme.blue600; bg = NexusTheme.blue50; }
    else if (status == 'Credit Approved') { color = NexusTheme.amber600; bg = NexusTheme.amber50; }
    else if (status == 'Cancelled') { color = NexusTheme.rose600; bg = NexusTheme.rose50; }

    return UnconstrainedBox(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
        child: Text(status.toUpperCase(), 
          style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 8),
        ),
      ),
    );
  }

  Widget _buildIconLink(IconData icon, String? url, String label) {
    final bool hasUrl = url != null && url.isNotEmpty;
    return GestureDetector(
      onTap: hasUrl ? () => launchUrl(Uri.parse(url)) : null,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: hasUrl ? NexusTheme.slate100 : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: hasUrl ? NexusTheme.slate700 : NexusTheme.slate200),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.package2, size: 64, color: NexusTheme.slate200),
          const SizedBox(height: 16),
          const Text('No orders found', style: TextStyle(color: NexusTheme.slate400, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
