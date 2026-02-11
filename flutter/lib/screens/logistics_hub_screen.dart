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
  String _selectedFleetProvider = 'Internal';
  final TextEditingController _vehicleController = TextEditingController();
  final TextEditingController _kmController = TextEditingController();
  String _activeTab = 'pending';
  final List<String> _selectedOrderIds = [];
  String _searchTerm = '';

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NexusProvider>(context);
    
    final pendingOrders = provider.orders.where((o) => 
      (o.status == 'Invoiced' || o.status == 'Ready for Dispatch') && 
      o.logistics?.deliveryAgentId == null &&
      (o.id.toLowerCase().contains(_searchTerm.toLowerCase()) || o.customerName.toLowerCase().contains(_searchTerm.toLowerCase()))
    ).toList();

    final activeShipments = provider.orders.where((o) => 
      o.logistics?.deliveryAgentId != null &&
      (o.id.toLowerCase().contains(_searchTerm.toLowerCase()) || o.customerName.toLowerCase().contains(_searchTerm.toLowerCase()))
    ).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final drivers = provider.users.where((u) => u.role == UserRole.delivery).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: NexusTheme.slate900),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('LOGISTICS HUB', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: NexusTheme.slate900, letterSpacing: 1)),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 900;
          
          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),

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
                    child: TextField(
                      onChanged: (v) => setState(() => _searchTerm = v),
                      decoration: const InputDecoration(
                        hintText: 'Trace by ID or Client...',
                        hintStyle: TextStyle(fontSize: 14, color: NexusTheme.slate300, fontWeight: FontWeight.w600),
                        prefixIcon: Icon(Icons.search, size: 20, color: NexusTheme.slate300),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _buildStatusTabs(pendingOrders.length, activeShipments.length),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Order Table Area
                if (_activeTab == 'pending')
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: NexusTheme.slate100),
                    ),
                    child: Column(
                      children: [
                        _buildTableHeader(isMobile, pendingOrders.length),
                        if (pendingOrders.isEmpty) 
                          _buildEmptyPlaceholder()
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: pendingOrders.length,
                            itemBuilder: (context, index) => _buildOrderRow(pendingOrders[index], isMobile),
                          ),
                      ],
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: activeShipments.isEmpty 
                      ? _buildEmptyPlaceholder()
                      : Column(
                          children: activeShipments.map((order) => _buildTrackShipmentCard(order, isMobile, provider)).toList(),
                        ),
                  ),
                
                const SizedBox(height: 24),

                // Assignment Panel
                if (_activeTab == 'pending')
                  _buildAssignmentPanel(drivers, provider, pendingOrders, isMobile),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusTabs(int pendingCount, int activeCount) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: NexusTheme.slate50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: NexusTheme.slate100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTabButton('pending', 'UNASSIGNED ($pendingCount)'),
          const SizedBox(width: 8),
          _buildTabButton('active', 'TRACK TRIPS ($activeCount)'),
        ],
      ),
    );
  }

  Widget _buildTabButton(String tab, String label) {
    bool isSelected = _activeTab == tab;
    return GestureDetector(
      onTap: () => setState(() => _activeTab = tab),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)] : [],
        ),
        child: Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: isSelected ? NexusTheme.emerald600 : NexusTheme.slate400,
          ),
        ),
      ),
    );
  }

  Widget _buildTableHeader(bool isMobile, int totalCount) {
    if (isMobile) return const SizedBox.shrink();
    
    // Get pending orders for select all functionality
    final provider = Provider.of<NexusProvider>(context, listen: false);
    final pendingOrders = provider.orders.where((o) => 
      (o.status == 'Invoiced' || o.status == 'Ready for Dispatch') && 
      o.logistics?.deliveryAgentId == null &&
      (o.id.toLowerCase().contains(_searchTerm.toLowerCase()) || o.customerName.toLowerCase().contains(_searchTerm.toLowerCase()))
    ).toList();
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Row(
        children: [
          Checkbox(
            value: _selectedOrderIds.length == pendingOrders.length && pendingOrders.isNotEmpty,
            activeColor: NexusTheme.emerald600,
            onChanged: (v) {
              setState(() {
                if (v == true) {
                  _selectedOrderIds.clear();
                  _selectedOrderIds.addAll(pendingOrders.map((o) => o.id));
                } else {
                  _selectedOrderIds.clear();
                }
              });
            },
          ),
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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: Column(
        children: [
          Icon(Icons.check_circle_outline, size: 64, color: NexusTheme.slate100),
          const SizedBox(height: 24),
          const Text(
            'ALL LOADS CLEAR.',
            style: TextStyle(color: NexusTheme.slate200, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1, height: 1.5, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderRow(Order order, bool isMobile) {
    bool isSelected = _selectedOrderIds.contains(order.id);
    if (isMobile) {
      return GestureDetector(
        onTap: () {
          setState(() {
            if (isSelected) _selectedOrderIds.remove(order.id);
            else _selectedOrderIds.add(order.id);
          });
        },
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isSelected ? NexusTheme.emerald50.withOpacity(0.3) : Colors.transparent,
            border: const Border(top: BorderSide(color: NexusTheme.slate50)),
          ),
          child: Row(
            children: [
              Checkbox(
                value: isSelected,
                activeColor: NexusTheme.emerald600,
                onChanged: (v) {
                  setState(() {
                    if (v == true) _selectedOrderIds.add(order.id);
                    else _selectedOrderIds.remove(order.id);
                  });
                },
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(order.id, style: const TextStyle(fontWeight: FontWeight.w900, color: NexusTheme.indigo600, fontSize: 13)),
                        const Text('READY FOR LOADING', style: TextStyle(fontWeight: FontWeight.w900, color: NexusTheme.slate400, fontSize: 9)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(order.customerName.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, color: NexusTheme.slate800, fontSize: 15)),
                    const SizedBox(height: 8),
                    const Text('8 BOXES • INV/24/00431', style: TextStyle(fontWeight: FontWeight.w900, color: NexusTheme.slate400, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) _selectedOrderIds.remove(order.id);
          else _selectedOrderIds.add(order.id);
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
        decoration: BoxDecoration(
          color: isSelected ? NexusTheme.emerald50.withOpacity(0.3) : Colors.transparent,
          border: const Border(top: BorderSide(color: NexusTheme.slate50)),
        ),
        child: Row(
          children: [
            Checkbox(
              value: isSelected,
              activeColor: NexusTheme.emerald600,
              onChanged: (v) {
                setState(() {
                  if (v == true) _selectedOrderIds.add(order.id);
                  else _selectedOrderIds.remove(order.id);
                });
              },
            ),
            const SizedBox(width: 48),
            SizedBox(width: 150, child: Text(order.id, style: const TextStyle(fontWeight: FontWeight.w900, color: NexusTheme.indigo600, fontSize: 13))),
            SizedBox(width: 250, child: Text(order.customerName.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, color: NexusTheme.slate800, fontSize: 13))),
            const SizedBox(width: 100, child: Text('8 BOXES', style: TextStyle(fontWeight: FontWeight.w900, color: NexusTheme.slate400, fontSize: 12))),
            const SizedBox(width: 150, child: Text('INV/24/00431', style: TextStyle(fontWeight: FontWeight.w900, color: NexusTheme.slate400, fontSize: 12))),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackShipmentCard(Order order, bool isMobile, NexusProvider provider) {
    final statusColor = order.status == 'Delivered' ? const Color(0xFF10B981) : const Color(0xFF6366F1);
    final statusBg = statusColor.withOpacity(0.1);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: NexusTheme.slate100),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.all(24),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(order.status == 'Delivered' ? Icons.check_circle_rounded : Icons.local_shipping_rounded, color: statusColor, size: 24),
          ),
          title: Row(
            children: [
              Text(order.id, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF6366F1))),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(8)),
                child: Text(order.status.toUpperCase(), style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: statusColor, letterSpacing: 0.5)),
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(order.customerName.toUpperCase(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.person_pin, size: 12, color: Color(0xFF94A3B8)),
                  const SizedBox(width: 6),
                  Text(order.logistics?.deliveryAgentId ?? 'NO AGENT', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8))),
                  const SizedBox(width: 16),
                  const Icon(Icons.navigation_rounded, size: 12, color: Color(0xFF94A3B8)),
                  const SizedBox(width: 6),
                  Text('${order.logistics?.distanceKm ?? 0} KM', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8))),
                ],
              ),
            ],
          ),
          children: [
            Container(
              padding: const EdgeInsets.only(left: 24, right: 24, bottom: 32),
              child: Column(
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildDetailItem('VEHICLE REG', order.logistics?.vehicleNo ?? 'N/A'),
                      _buildDetailItem('FLEET TYPE', order.logistics?.vehicleProvider ?? 'INTERNAL'),
                      _buildDetailItem('INVOICE VAL', '₹${order.total.toInt().toLocaleString()}'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Color(0xFFCBD5E1), letterSpacing: 1)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
      ],
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
              _buildFleetToggle('Internal'),
              const SizedBox(width: 12),
              _buildFleetToggle('Porter'),
              if (!isMobile) const SizedBox(width: 12),
              if (!isMobile) _buildFleetToggle('Other'),
            ],
          ),
          if (isMobile) const SizedBox(height: 12),
          if (isMobile) Row(
            children: [
              _buildFleetToggle('Other'),
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
                hint: const Text('SELECT DRIVER', style: TextStyle(color: Colors.white12, fontSize: 13, fontWeight: FontWeight.bold)),
                dropdownColor: const Color(0xFF04261E),
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
              onPressed: (_selectedDriver == null || _selectedOrderIds.isEmpty) ? null : () => _confirmDispatch(provider),
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
                  Text('CONFIRM LOADING (${_selectedOrderIds.length})', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1)),
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
            // ignore: deprecated_member_use
            color: isSelected ? NexusTheme.emerald500 : Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? NexusTheme.emerald400 : Colors.white.withOpacity(0.05)),
          ),
          child: Center(
            child: Text(
              label.toUpperCase(),
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
        // ignore: deprecated_member_use
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: child,
    );
  }

  void _confirmDispatch(NexusProvider provider) async {
    final success = await provider.assignLogistics(
      _selectedOrderIds, 
      {
        'deliveryAgentId': _selectedDriver,
        'vehicleNo': _vehicleController.text,
        'vehicleProvider': _selectedFleetProvider,
        'distanceKm': double.tryParse(_kmController.text) ?? 0,
      }
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fleet Assigned to ${_selectedOrderIds.length} Missions')),
      );
      _vehicleController.clear();
      _kmController.clear();
      _selectedOrderIds.clear();
      setState(() {
        _selectedDriver = null;
        _activeTab = 'active'; // Move to track trips
      });
    }
  }
}

extension NumberFormatting on num {
  String toLocaleString() {
    return toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
  }
}
