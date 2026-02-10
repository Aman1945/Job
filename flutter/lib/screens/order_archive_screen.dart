import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/nexus_provider.dart';
import '../utils/theme.dart';
import '../widgets/nexus_components.dart';
import 'order_details_screen.dart';
import 'package:intl/intl.dart';

class OrderArchiveScreen extends StatefulWidget {
  const OrderArchiveScreen({super.key});

  @override
  State<OrderArchiveScreen> createState() => _OrderArchiveScreenState();
}

class _OrderArchiveScreenState extends State<OrderArchiveScreen> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NexusProvider>(context);
    final filteredOrders = provider.orders.where((o) {
      final query = searchQuery.toLowerCase();
      return o.id.toLowerCase().contains(query) || 
             o.customerName.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('ORDERS MASTER ARCHIVE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Orders Master Archive', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
                    Text('Trace statuses, invoices, and delivery proof snapshots', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: NexusTheme.slate400)),
                  ],
                ),
                // Search Bar
                Container(
                  width: 300,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: NexusTheme.slate200),
                  ),
                  child: TextField(
                    onChanged: (val) => setState(() => searchQuery = val),
                    decoration: const InputDecoration(
                      hintText: 'Search Reference, Client, or Invoice...',
                      hintStyle: TextStyle(fontSize: 12, color: NexusTheme.slate400),
                      prefixIcon: Icon(Icons.search, size: 18, color: NexusTheme.slate400),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Data Table Section
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: NexusTheme.slate200),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20)],
              ),
              clipBehavior: Clip.antiAlias,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: DataTable(
                    headingRowHeight: 60,
                    dataRowMinHeight: 80,
                    dataRowMaxHeight: 80,
                    horizontalMargin: 24,
                    columnSpacing: 40,
                    columns: const [
                      DataColumn(label: Text('MISSION REF', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: NexusTheme.slate400))),
                      DataColumn(label: Text('CUSTOMER', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: NexusTheme.slate400))),
                      DataColumn(label: Text('STATUS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: NexusTheme.slate400))),
                      DataColumn(label: Text('INVOICE COPY', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: NexusTheme.slate400))),
                      DataColumn(label: Text('ACK. COPY (POD)', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: NexusTheme.slate400))),
                      DataColumn(label: Text('VALUE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: NexusTheme.slate400))),
                    ],
                    rows: filteredOrders.map((order) {
                      return DataRow(
                        cells: [
                          DataCell(
                            InkWell(
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OrderDetailsScreen(order: order))),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(order.id, style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF059669), fontSize: 12)),
                                  Text(DateFormat('dd/MM/yyyy').format(order.createdAt), style: const TextStyle(color: NexusTheme.slate400, fontSize: 10)),
                                ],
                              ),
                            ),
                          ),
                          DataCell(Text(order.customerName, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12))),
                          DataCell(NexusComponents.statusBadge(order.status)),
                          DataCell(Text(
                            order.status == 'Invoiced' || order.status == 'Delivered' ? 'VIEW INVOICE' : 'PENDING',
                            style: TextStyle(
                              fontSize: 10, 
                              fontWeight: FontWeight.w900, 
                              fontStyle: FontStyle.italic,
                              color: order.status == 'Invoiced' || order.status == 'Delivered' ? NexusTheme.indigo600 : NexusTheme.slate200
                            ),
                          )),
                          DataCell(Text(
                            order.status == 'Delivered' ? 'VIEW PROOF' : 'NO PROOF',
                            style: TextStyle(
                              fontSize: 10, 
                              fontWeight: FontWeight.w900, 
                              fontStyle: FontStyle.italic,
                              color: order.status == 'Delivered' ? NexusTheme.indigo600 : NexusTheme.slate200
                            ),
                          )),
                          DataCell(Text('₹${NumberFormat('#,##,###').format(order.total)}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13))),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
