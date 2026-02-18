import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/nexus_provider.dart';
import '../models/models.dart';
import 'package:lucide_icons/lucide_icons.dart';

class LogisticsHubScreen extends StatefulWidget {
  const LogisticsHubScreen({super.key});

  @override
  State<LogisticsHubScreen> createState() => _LogisticsHubScreenState();
}

class _LogisticsHubScreenState extends State<LogisticsHubScreen> {
  final List<String> _selectedMissions = [];
  String _selectedRoute = 'Route-A (Central Mumbai)';
  String? _selectedAgent;
  final TextEditingController _vehicleController = TextEditingController();
  final TextEditingController _ewayBillController = TextEditingController();
  final TextEditingController _sealController = TextEditingController();
  bool isManifesting = false;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NexusProvider>(context);
    final readyMissions = provider.orders.where((o) => (o.status == 'Invoiced' || o.status == 'Ready for Dispatch') && o.logistics?.manifestId == null).toList();
    final agents = provider.users.where((u) => u.role == UserRole.deliveryTeam).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('6. LOGISTICS MISSION CONTROL', 
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1, color: Color(0xFF1E293B))),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 900;
          
          if (isMobile) {
            return Column(
              children: [
                Expanded(child: _buildMissionList(readyMissions)),
                _buildManifestTerminal(agents, provider, isMobile),
              ],
            );
          }
          
          return Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildMissionList(readyMissions),
              ),
              Container(width: 1, color: const Color(0xFFE2E8F0)),
              Expanded(
                child: _buildManifestTerminal(agents, provider, isMobile),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMissionList(List<Order> missions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              const Text('AWAITING MANIFESTATION', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Colors.grey, letterSpacing: 1)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(8)),
                child: Text('${missions.length} MISSIONS', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Color(0xFF6366F1))),
              ),
            ],
          ),
        ),
        Expanded(
          child: missions.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: missions.length,
                  itemBuilder: (context, index) {
                    final order = missions[index];
                    bool isSelected = _selectedMissions.contains(order.id);
                    return _buildMissionCard(order, isSelected);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildMissionCard(Order order, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFEEF2FF) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isSelected ? const Color(0xFF6366F1) : const Color(0xFFE2E8F0)),
      ),
      child: CheckboxListTile(
        value: isSelected,
        onChanged: (v) {
          setState(() {
            if (v!) _selectedMissions.add(order.id);
            else _selectedMissions.remove(order.id);
          });
        },
        activeColor: const Color(0xFF6366F1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(order.id, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF6366F1))),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(order.customerName, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
            Text('Value: ₹${NumberFormat('#,##,###').format(order.total)} | Boxes: 08', style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildManifestTerminal(List<User> agents, NexusProvider provider, bool isMobile) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(isMobile ? 16 : 32),
      child: isMobile 
        ? SingleChildScrollView(
            child: Column(children: _buildManifestContent(agents, provider)))
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _buildManifestContent(agents, provider),
          ),
    );
  }
  
  List<Widget> _buildManifestContent(List<User> agents, NexusProvider provider) {
    return [
          const Row(
            children: [
              Icon(LucideIcons.gitPullRequest, color: Color(0xFF10B981), size: 20),
              SizedBox(width: 12),
              Text('MANIFEST ENGINE', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
            ],
          ),
          const SizedBox(height: 32),
          _buildTerminalInput('ASSIGNMENT ROUTE', DropdownButton<String>(
            value: _selectedRoute,
            isExpanded: true,
            underline: const SizedBox(),
            items: ['Route-A (Central Mumbai)', 'Route-B (Western Suburbs)', 'Route-C (Thane/Navi)'].map((r) => DropdownMenuItem(value: r, child: Text(r, style: const TextStyle(fontSize: 12)))).toList(),
            onChanged: (v) => setState(() => _selectedRoute = v!),
          )),
          const SizedBox(height: 20),
          _buildTerminalInput('DELIVERY AGENT', DropdownButton<String>(
            value: _selectedAgent,
            isExpanded: true,
            hint: const Text('Select Agent', style: TextStyle(fontSize: 12)),
            underline: const SizedBox(),
            items: agents.map((a) => DropdownMenuItem(value: a.name, child: Text(a.name, style: const TextStyle(fontSize: 12)))).toList(),
            onChanged: (v) => setState(() => _selectedAgent = v!),
          )),
          const SizedBox(height: 20),
          _buildTerminalInput('VEHICLE REG NO.', TextField(
            controller: _vehicleController,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(hintText: 'MH-12-XX-0000', border: InputBorder.none),
          )),
          const SizedBox(height: 20),
          _buildTerminalInput('E-WAY BILL NO.', TextField(
            controller: _ewayBillController,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(hintText: '12-Digit Reference', border: InputBorder.none),
          )),
          const SizedBox(height: 20),
          _buildTerminalInput('CONTAINER SEAL NO.', TextField(
            controller: _sealController,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(hintText: 'Security Seal ID', border: InputBorder.none),
          )),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('SELECTED UNITS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
              Text('${_selectedMissions.length} ORDERS', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: (_selectedMissions.isEmpty || _selectedAgent == null) ? null : () => _createManifest(provider),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: isManifesting 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('AUTHENTICATE & DISPATCH', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
            ),
          ),
    ];
  }

  Widget _buildTerminalInput(String label, Widget input) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 0.5)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: input,
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.checkCircle2, size: 64, color: Color(0xFFE2E8F0)),
          SizedBox(height: 16),
          Text('HUB QUEUE CLEAR', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFFCBD5E1))),
        ],
      ),
    );
  }

  void _createManifest(NexusProvider provider) async {
    setState(() => isManifesting = true);
    
    final success = await provider.assignLogistics(
      _selectedMissions, 
      {
        'deliveryAgentId': _selectedAgent,
        'vehicleNo': _vehicleController.text,
        'vehicleProvider': 'Hub Manifest',
        'manifestId': 'MAN-${DateFormat('yyMMdd').format(DateTime.now())}-${_selectedMissions.length}',
        'ewayBill': _ewayBillController.text,
        'sealNo': _sealController.text,
      }
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fleet Manifest generated and agents notified!'), backgroundColor: Color(0xFF10B981)));
      setState(() {
        _selectedMissions.clear();
        _vehicleController.clear();
        _ewayBillController.clear();
        _sealController.clear();
        _selectedAgent = null;
        isManifesting = false;
      });
    } else {
      setState(() => isManifesting = false);
    }
  }
}
