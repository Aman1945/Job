import 'package:flutter/material.dart';
import '../utils/theme.dart';

class ProcurementScreen extends StatefulWidget {
  const ProcurementScreen({super.key});

  @override
  State<ProcurementScreen> createState() => _ProcurementScreenState();
}

class _ProcurementScreenState extends State<ProcurementScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NexusTheme.slate50,
      appBar: AppBar(
        title: const Text('PROCUREMENT GATE TERMINAL', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Procurement Gate', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: NexusTheme.slate900)),
                      Text('VERIFY SUPPLIER INBOUND REQUIREMENTS & MULTI-STAGE APPROVAL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: NexusTheme.slate400, letterSpacing: 0.5)),
                    ],
                  ),
                ),
                _buildHeaderButton(Icons.add, 'LOG NEW INBOUND', NexusTheme.indigo600, Colors.white),
              ],
            ),
          ),
          
          // Search & Filter Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search Supplier, SKU Name or Code...',
                      hintStyle: const TextStyle(fontSize: 13, color: NexusTheme.slate400),
                      prefixIcon: const Icon(Icons.search, color: NexusTheme.slate400),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                _buildFilterButton(),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Data Table
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20)],
              ),
              child: _buildProcurementTable(),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildHeaderButton(IconData icon, String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Icon(icon, size: 18, color: textColor),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: textColor, letterSpacing: 0.5)),
        ],
      ),
    );
  }

  Widget _buildFilterButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: const Row(
        children: [
          Icon(Icons.filter_list, size: 20, color: NexusTheme.slate400),
          SizedBox(width: 8),
          Text('FILTER ACTIVE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: NexusTheme.slate400)),
        ],
      ),
    );
  }

  Widget _buildProcurementTable() {
    final mockInbounds = [
      {
        'ref': 'PRC-1001',
        'date': '09/02/2026',
        'vendor': 'Global Fisheries Ltd',
        'sku': 'Frozen Salmon Fillets 500G',
        'code': 'SKU-SM-01',
        'checks': [true, false, true],
        'stage': 'PENDING'
      },
      {
        'ref': 'PRC-1002',
        'date': '09/02/2026',
        'vendor': 'Ocean Fresh Imports',
        'sku': 'Tuna Steak Premium 200G',
        'code': 'SKU-TN-42',
        'checks': [false, false, false],
        'stage': 'PENDING'
      },
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          headingRowHeight: 60,
          dataRowMinHeight: 100,
          dataRowMaxHeight: 100,
          columns: const [
            DataColumn(label: Text('MISSION REF', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: NexusTheme.slate400))),
            DataColumn(label: Text('VENDOR / SUPPLIER', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: NexusTheme.slate400))),
            DataColumn(label: Text('MATERIAL SKU', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: NexusTheme.slate400))),
            DataColumn(label: Text('CHECKS (SIP/LBL/DOC)', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: NexusTheme.slate400))),
            DataColumn(label: Text('DOCS / FILES', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: NexusTheme.slate400))),
            DataColumn(label: Text('STAGE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: NexusTheme.slate400))),
          ],
          rows: mockInbounds.map((item) {
            return DataRow(cells: [
              DataCell(Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['ref'] as String, style: const TextStyle(fontWeight: FontWeight.w900, color: NexusTheme.indigo600, fontSize: 13)),
                  Text(item['date'] as String, style: const TextStyle(color: NexusTheme.slate400, fontSize: 10)),
                ],
              )),
              DataCell(Text(item['vendor'] as String, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13))),
              DataCell(Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['sku'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  Text('CODE: ${item['code']}', style: const TextStyle(color: NexusTheme.indigo600, fontSize: 10, fontWeight: FontWeight.w900)),
                ],
              )),
              DataCell(Row(
                children: (item['checks'] as List<bool>).map((checked) {
                  return Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: checked ? NexusTheme.indigo600 : NexusTheme.slate100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      checked ? Icons.check : Icons.sell_outlined,
                      size: 14,
                      color: checked ? Colors.white : NexusTheme.slate300,
                    ),
                  );
                }).toList(),
              )),
              DataCell(IconButton(icon: const Icon(Icons.description_outlined, color: NexusTheme.slate300), onPressed: () {})),
              DataCell(Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: const Text('PENDING', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w900, fontSize: 10)),
              )),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}
