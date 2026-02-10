import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/nexus_provider.dart';
import '../utils/theme.dart';
import '../models/models.dart';
import '../widgets/nexus_components.dart';

class MasterDataScreen extends StatefulWidget {
  const MasterDataScreen({super.key});

  @override
  State<MasterDataScreen> createState() => _MasterDataScreenState();
}

class _MasterDataScreenState extends State<MasterDataScreen> {
  String _selectedTab = 'USER MASTER';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NexusTheme.slate50,
      appBar: AppBar(
        title: const Text('ENTERPRISE MASTER TERMINAL', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildTab('USER MASTER'),
                _buildTab('CUSTOMER MASTER'),
                _buildTab('MATERIAL MASTER'),
                _buildTab('DELIVERY PERSON'),
                _buildTab('OD MASTER'),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_selectedTab, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: NexusTheme.slate900)),
                      const Text('MASTER DATA MANAGEMENT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: NexusTheme.slate400, letterSpacing: 1)),
                    ],
                  ),
                ),
                NexusComponents.headerButton(icon: Icons.description_outlined, label: 'TEMPLATE', onTap: () {}),
                const SizedBox(width: 12),
                NexusComponents.headerButton(icon: Icons.add, label: 'ADD NEW', onTap: () {}, bgColor: NexusTheme.slate900, textColor: Colors.white),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20)]),
              child: _buildDataTable(),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildTab(String title) {
    bool isSelected = _selectedTab == title;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = title),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? NexusTheme.indigo600 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? NexusTheme.indigo600 : NexusTheme.slate200),
        ),
        child: Text(
          title,
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: isSelected ? Colors.white : NexusTheme.slate500, letterSpacing: 0.5),
        ),
      ),
    );
  }

  Widget _buildDataTable() {
    final provider = Provider.of<NexusProvider>(context);
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          headingRowHeight: 60,
          dataRowMinHeight: 70,
          dataRowMaxHeight: 70,
          columns: const [
            DataColumn(label: Text('NAME', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: NexusTheme.slate400))),
            DataColumn(label: Text('EMAIL', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: NexusTheme.slate400))),
            DataColumn(label: Text('ROLE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: NexusTheme.slate400))),
            DataColumn(label: Text('APPROVER', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: NexusTheme.slate400))),
            DataColumn(label: Text('ACTIONS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: NexusTheme.slate400))),
          ],
          rows: provider.users.map((user) {
            return DataRow(cells: [
              DataCell(Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
              DataCell(Text(user.id.toLowerCase(), style: const TextStyle(color: NexusTheme.slate500, fontSize: 13))),
              DataCell(Text(user.role.label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
              DataCell(user.role == UserRole.admin 
                ? const Icon(Icons.check_box, color: Colors.green, size: 20) 
                : const Text('-', style: TextStyle(color: NexusTheme.slate400))),
              DataCell(Row(
                children: [
                  IconButton(icon: const Icon(Icons.edit_outlined, size: 18), onPressed: () {}),
                  IconButton(icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent), onPressed: () {}),
                ],
              )),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}
