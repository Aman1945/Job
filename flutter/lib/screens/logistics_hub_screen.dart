import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/nexus_provider.dart';
import '../utils/theme.dart';
import '../models/models.dart';

class LogisticsHubScreen extends StatefulWidget {
  const LogisticsHubScreen({super.key});

  @override
  State<LogisticsHubScreen> createState() => _LogisticsHubScreenState();
}

class _LogisticsHubScreenState extends State<LogisticsHubScreen> {
  String? _selectedDriver;
  String _selectedFleetProvider = 'INTERNAL';
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _vehicleController = TextEditingController();
  final TextEditingController _kmController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NexusProvider>(context);
    final readyOrders = provider.orders.where((o) => o.status == 'Invoiced' || o.status == 'Ready for Dispatch').toList();
    final drivers = provider.users.where((u) => u.role == UserRole.delivery).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: NexusTheme.slate900),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 900;
          
          return SingleChildScrollView(
            child: Column(
              children: [
                // Header Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: isMobile 
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Logistics Hub',
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: NexusTheme.slate900, letterSpacing: -0.5),
                          ),
                          const Text(
                            'Assign fleet & vehicles',
                            style: TextStyle(fontSize: 13, color: NexusTheme.slate400, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 16),
                          _buildStatusTabs(readyOrders.length),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Logistics Hub (Fleet Loading)',
                                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: NexusTheme.slate900, letterSpacing: -0.5),
                              ),
                              const Text(
                                'Assign delivery agents and vehicles to invoiced missions',
                                style: TextStyle(fontSize: 13, color: NexusTheme.slate400, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          _buildStatusTabs(readyOrders.length),
                        ],
                      ),
                ),
                
                const SizedBox(height: 32),
                
                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: NexusTheme.slate50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: NexusTheme.slate100),
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: 'Trace by ID or Client...',
                        hintStyle: TextStyle(fontSize: 14, color: NexusTheme.slate300, fontWeight: FontWeight.w600),
                        prefixIcon: Icon(Icons.search, size: 20, color: NexusTheme.slate300),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),

                // Order Table Area
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: NexusTheme.slate100),
                  ),
                  child: Column(
                    children: [
                      _buildTableHeader(isMobile),
                      if (readyOrders.isEmpty) 
                        _buildEmptyPlaceholder()
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: readyOrders.length,
                          itemBuilder: (context, index) => _buildOrderRow(readyOrders[index], isMobile),
                        ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),

                // Assignment Panel
                _buildAssignmentPanel(drivers, provider, readyOrders, isMobile),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusTabs(int count) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: NexusTheme.slate50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: NexusTheme.slate100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)],
            ),
            child: Row(
              children: [
                const Text('UNASSIGNED ', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: NexusTheme.emerald600)),
                Text('($count)', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: NexusTheme.emerald600)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('TRACK TRIPS (0)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: NexusTheme.slate400)),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(bool isMobile) {
    if (isMobile) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Row(
        children: [
          Container(width: 16, height: 16, decoration: BoxDecoration(color: NexusTheme.slate600, borderRadius: BorderRadius.circular(4))),
          const SizedBox(width: 48),
          _buildHeaderText('MISSION ID', 150),
          _buildHeaderText('CUSTOMER ENTITY', 250),
          _buildHeaderText('BOXES', 100),
          _buildHeaderText('INVOICE NUMBER', 150),
        ],
      ),
    );
  }

  Widget _buildHeaderText(String label, double width) {
    return SizedBox(width: width, child: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: NexusTheme.slate300, letterSpacing: 1)));
  }

  Widget _buildEmptyPlaceholder() {
    return const Center(
      child: Text(
        'ALL INVOICED LOADS ASSIGNED TO FLEET.',
        style: TextStyle(color: NexusTheme.slate200, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1, height: 1.5, fontStyle: FontStyle.italic),
      ),
    );
  }

  Widget _buildOrderRow(Order order, bool isMobile) {
    if (isMobile) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(border: Border(top: BorderSide(color: NexusTheme.slate50))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(order.id, style: const TextStyle(fontWeight: FontWeight.w900, color: NexusTheme.indigo600, fontSize: 13)),
                const Text('INV/24/00431', style: TextStyle(fontWeight: FontWeight.w900, color: NexusTheme.slate400, fontSize: 11)),
              ],
            ),
            const SizedBox(height: 12),
            Text(order.customerName.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, color: NexusTheme.slate800, fontSize: 15)),
            const SizedBox(height: 8),
            const Text('8 BOXES • READY FOR LOADING', style: TextStyle(fontWeight: FontWeight.w900, color: NexusTheme.slate400, fontSize: 11)),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: NexusTheme.slate50))),
      child: Row(
        children: [
          Container(width: 16, height: 16, decoration: BoxDecoration(border: Border.all(color: NexusTheme.slate200), borderRadius: BorderRadius.circular(4))),
          const SizedBox(width: 48),
          SizedBox(width: 150, child: Text(order.id, style: const TextStyle(fontWeight: FontWeight.w900, color: NexusTheme.indigo600, fontSize: 13))),
          SizedBox(width: 250, child: Text(order.customerName.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, color: NexusTheme.slate800, fontSize: 13))),
          const SizedBox(width: 100, child: Text('8 BOXES', style: TextStyle(fontWeight: FontWeight.w900, color: NexusTheme.slate400, fontSize: 12))),
          const SizedBox(width: 150, child: Text('INV/24/00431', style: TextStyle(fontWeight: FontWeight.w900, color: NexusTheme.slate400, fontSize: 12))),
        ],
      ),
    );
  }

  Widget _buildAssignmentPanel(List<User> drivers, NexusProvider provider, List<Order> readyOrders, bool isMobile) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF04261E), // Deep Emerald from screenshot
        borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
      ),
      padding: EdgeInsets.all(isMobile ? 24 : 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.near_me_outlined, color: NexusTheme.emerald400, size: 24),
              const SizedBox(width: 12),
              Text('Assignment Panel', style: TextStyle(color: Colors.white, fontSize: isMobile ? 18 : 20, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
            ],
          ),
          const SizedBox(height: 32),
          
          const Text('FLEET PROVIDER', style: TextStyle(color: NexusTheme.emerald600, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildFleetToggle('INTERNAL'),
              const SizedBox(width: 12),
              _buildFleetToggle('PORTER'),
              if (!isMobile) const SizedBox(width: 12),
              if (!isMobile) _buildFleetToggle('OTHER'),
            ],
          ),
          if (isMobile) const SizedBox(height: 12),
          if (isMobile) Row(
            children: [
              _buildFleetToggle('OTHER'),
              const Expanded(flex: 2, child: SizedBox()),
            ],
          ),
          
          const SizedBox(height: 24),
          
          const Text('DELIVERY EXECUTIVE', style: TextStyle(color: NexusTheme.emerald600, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
          const SizedBox(height: 12),
          _buildPanelInput(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedDriver,
                hint: const Text('SELECT DRIVER', style: TextStyle(color: Colors.white10, fontSize: 13, fontWeight: FontWeight.bold)),
                dropdownColor: const Color(0xFF0F172A),
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down, color: NexusTheme.emerald500),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                items: drivers.map((d) => DropdownMenuItem(value: d.name, child: Text(d.name))).toList(),
                onChanged: (v) => setState(() => _selectedDriver = v),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          const Text('VEHICLE REG NO.', style: TextStyle(color: NexusTheme.emerald600, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
          const SizedBox(height: 12),
          _buildPanelInput(
            child: TextField(
              controller: _vehicleController,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                hintText: 'E.G. MH-12-NEXU-1234',
                hintStyle: TextStyle(color: Colors.white12, fontSize: 13),
                border: InputBorder.none,
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          const Text('JOURNEY EST. (KM)', style: TextStyle(color: NexusTheme.emerald600, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
          const SizedBox(height: 12),
          _buildPanelInput(
            child: TextField(
              controller: _kmController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                hintText: '0',
                hintStyle: TextStyle(color: Colors.white10, fontSize: 13),
                border: InputBorder.none,
              ),
            ),
          ),
          
          const SizedBox(height: 40),
          
          SizedBox(
            width: double.infinity,
            height: 64,
            child: ElevatedButton(
              onPressed: (_selectedDriver == null || readyOrders.isEmpty) ? null : () => _confirmDispatch(provider, readyOrders.first),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D5F47), // Emerald 700ish
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.white.withOpacity(0.05),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('CONFIRM LOADING', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1)),
                  const SizedBox(width: 12),
                  const Icon(Icons.arrow_forward_rounded, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFleetToggle(String label) {
    bool isSelected = _selectedFleetProvider == label;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedFleetProvider = label),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: isSelected ? NexusTheme.emerald500 : Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? NexusTheme.emerald400 : Colors.white.withOpacity(0.05)),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white24,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPanelInput({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: child,
    );
  }

  void _confirmDispatch(NexusProvider provider, Order order) async {
    final success = await provider.updateOrderStatus(order.id, 'Picked Up');
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fleet Dispatch Confirmed')),
      );
      _vehicleController.clear();
      _kmController.clear();
      setState(() => _selectedDriver = null);
    }
  }
}
