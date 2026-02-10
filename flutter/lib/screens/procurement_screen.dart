import 'package:flutter/material.dart';
import '../utils/theme.dart';

class ProcurementScreen extends StatefulWidget {
  const ProcurementScreen({super.key});

  @override
  State<ProcurementScreen> createState() => _ProcurementScreenState();
}

class _ProcurementScreenState extends State<ProcurementScreen> {
  bool _showInboundForm = false;
  final TextEditingController _supplierController = TextEditingController();
  String? _selectedSku;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NexusTheme.slate50,
      appBar: AppBar(
        title: const Text('PROCUREMENT GATE TERMINAL', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5)),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: NexusTheme.slate900),
          onPressed: () {},
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Procurement Gate Terminal', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: NexusTheme.slate900, letterSpacing: -0.5)),
                          Text('Verify supplier inbound requirements & multi-stage approval', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: NexusTheme.slate400, letterSpacing: 0.2)),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _showInboundForm = true),
                      child: _buildHeaderButton(Icons.add, 'LOG NEW INBOUND', NexusTheme.indigo600, Colors.white),
                    ),
                  ],
                ),
              ),
              
              // Search & Filter Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: NexusTheme.slate200),
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search Supplier, SKU Name or Code...',
                            hintStyle: const TextStyle(fontSize: 14, color: NexusTheme.slate400),
                            prefixIcon: const Icon(Icons.search, color: NexusTheme.slate400),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    _buildFilterButton(),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Data Table
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: NexusTheme.slate200),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20)],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: _buildProcurementTable(),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
          
          if (_showInboundForm) _buildInboundFormOverlay(),
        ],
      ),
    );
  }

  Widget _buildInboundFormOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A), // Dark Navy
            borderRadius: BorderRadius.circular(32),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Supply Inbound Form', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54),
                    onPressed: () => setState(() => _showInboundForm = false),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: _buildFormInput('SUPPLIER NAME', 'Enter vendor identity...', controller: _supplierController),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _buildFormDropdown('TARGET SKU', 'Select Material SKU...'),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: 250,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    // Logic to save
                    setState(() => _showInboundForm = false);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: NexusTheme.indigo600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('REGISTER INBOUND ENTRY', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormInput(String label, String hint, {TextEditingController? controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: NexusTheme.indigo500, fontSize: 10, fontWeight: FontWeight.black, letterSpacing: 0.5)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 14),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormDropdown(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(label, style: TextStyle(color: NexusTheme.indigo500, fontSize: 10, fontWeight: FontWeight.black, letterSpacing: 0.5)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(hint, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14, fontWeight: FontWeight.bold)),
              const Icon(Icons.keyboard_arrow_down, color: Colors.white54),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderButton(IconData icon, String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: bgColor, 
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: bgColor.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: textColor),
          const SizedBox(width: 10),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: textColor, letterSpacing: 1)),
        ],
      ),
    );
  }

  Widget _buildFilterButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: NexusTheme.slate200),
      ),
      child: const Row(
        children: [
          Icon(Icons.filter_list, size: 22, color: NexusTheme.slate400),
          SizedBox(width: 10),
          Text('FILTER ACTIVE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: NexusTheme.slate400, letterSpacing: 0.5)),
        ],
      ),
    );
  }

  Widget _buildProcurementTable() {
    final mockInbounds = [
      {
        'ref': 'PRC-1001',
        'date': '10/02/2026',
        'vendor': 'Global Fisheries Ltd',
        'sku': 'Frozen Salmon Fillets 500G',
        'code': 'SKU-SM-01',
        'checks': [true, true, true],
        'stage': 'PENDING'
      },
      {
        'ref': 'PRC-1002',
        'date': '10/02/2026',
        'vendor': 'Ocean Fresh Imports',
        'sku': 'Tuna Steak Premium 200G',
        'code': 'SKU-TN-42',
        'checks': [true, true, true],
        'stage': 'PENDING'
      },
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowHeight: 80,
        dataRowMinHeight: 120,
        dataRowMaxHeight: 120,
        horizontalMargin: 32,
        columnSpacing: 60,
        headingTextStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: NexusTheme.slate300, letterSpacing: 1),
        columns: const [
          DataColumn(label: Text('MISSION REF')),
          DataColumn(label: Text('VENDOR / SUPPLIER')),
          DataColumn(label: Text('MATERIAL SKU')),
          DataColumn(label: Text('CHECKS (SIP/LBL/DOC)')),
          DataColumn(label: Text('DOCS / FILES')),
          DataColumn(label: Text('STAGE')),
        ],
        rows: mockInbounds.map((item) {
          return DataRow(cells: [
            DataCell(Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['ref'] as String, style: const TextStyle(fontWeight: FontWeight.w900, color: NexusTheme.indigo600, fontSize: 14)),
                const SizedBox(height: 4),
                Text(item['date'] as String, style: const TextStyle(color: NexusTheme.slate400, fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            )),
            DataCell(Text(item['vendor'] as String, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: NexusTheme.slate800))),
            DataCell(Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['sku'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: NexusTheme.slate800)),
                const SizedBox(height: 4),
                Text('CODE: ${item['code']}', style: const TextStyle(color: NexusTheme.indigo600, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
              ],
            )),
            DataCell(Row(
              children: [Icons.fact_check, Icons.sell, Icons.description].map((iconData) {
                return Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: NexusTheme.slate50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: NexusTheme.slate100),
                  ),
                  child: Icon(iconData, size: 20, color: NexusTheme.slate200),
                );
              }).toList(),
            )),
            DataCell(Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: NexusTheme.slate50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: NexusTheme.slate100),
              ),
              child: const Icon(Icons.file_upload_outlined, size: 20, color: NexusTheme.slate200),
            )),
            DataCell(Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('PENDING', style: TextStyle(color: Color(0xFFEA580C), fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1)),
            )),
          ]);
        }).toList(),
      ),
    );
  }
}
