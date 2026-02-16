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
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NexusTheme.slate50,
      appBar: AppBar(
        title: const Text(
          'MASTER TERMINAL',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: NexusTheme.slate400),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildTerminalToggle('USER MASTER'),
                _buildTerminalToggle('CUSTOMER MASTER'),
                _buildTerminalToggle('MATERIAL MASTER'),
                _buildTerminalToggle('DELIVERY PERSON'),
                _buildTerminalToggle('OD MASTER'),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedTab
                        .split(' ')
                        .map((s) => s[0] + s.substring(1).toLowerCase())
                        .join(' '),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 28,
                      color: NexusTheme.slate900,
                    ),
                  ),
                  const Text(
                    'ENTERPRISE MASTER REGISTRY & DATA MANAGEMENT TERMINAL',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      color: NexusTheme.slate400,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Intelligence-style Metric Cards
                  _buildMasterMetricsGrid(),

                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    children: [
                      _buildActionButton(
                        icon: Icons.description_outlined,
                        label: 'TEMPLATE',
                        onTap: () => _showMasterForm(context),
                        isPrimary: false,
                      ),
                      const SizedBox(width: 12),
                      _buildActionButton(
                        icon: Icons.add,
                        label: 'ADD NEW',
                        onTap: () => _showMasterForm(context),
                        isPrimary: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Data Table Card (Restored to Image 1 Style)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(60),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 40,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(60),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 48),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 56),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Text(
                              'ID',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF94A3B8),
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              'NAME',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF94A3B8),
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(48, 16, 48, 0),
                      child: Divider(color: Color(0xFFF1F5F9), height: 1),
                    ),
                    _buildDataTable(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMasterMetricsGrid() {
    final provider = Provider.of<NexusProvider>(context);
    String totalCount = '0';
    String activeLabel = 'ACTIVE';
    String statusValue = '100%';
    IconData metricIcon = Icons.people;

    if (_selectedTab == 'USER MASTER') {
      totalCount = provider.users.length.toString();
      metricIcon = Icons.people;
    } else if (_selectedTab == 'CUSTOMER MASTER') {
      totalCount = provider.customers.length.toString();
      metricIcon = Icons.business;
    } else if (_selectedTab == 'MATERIAL MASTER') {
      totalCount = provider.products.length.toString();
      metricIcon = Icons.inventory_2;
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.55,
      children: [
        _buildMetricCard(
          'TOTAL ENTRIES',
          totalCount,
          'Registered in system',
          NexusTheme.indigo500,
          NexusTheme.blue900,
          icon: metricIcon,
        ),
        _buildMetricCard(
          'SYSTEM UPTIME',
          '99.9%',
          'Infrastructure health',
          NexusTheme.emerald500,
          NexusTheme.emerald900,
          icon: Icons.bolt,
        ),
        _buildMetricCard(
          'DATA SYNC',
          'LIVE',
          'Real-time database',
          Colors.orange,
          NexusTheme.amber900,
          icon: Icons.sync,
        ),
        _buildMetricCard(
          'SECURITY',
          'ENCRYPTED',
          'AES-256 standard',
          NexusTheme.slate500,
          NexusTheme.slate900,
          icon: Icons.security,
        ),
      ],
    );
  }

  Widget _buildTerminalToggle(String title) {
    bool isSelected = _selectedTab == title;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = title),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? NexusTheme.indigo500.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? NexusTheme.indigo500.withOpacity(0.2)
                : Colors.transparent,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: isSelected ? NexusTheme.indigo600 : NexusTheme.slate400,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    String subtitle,
    Color color,
    Color accentColor, {
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border(left: BorderSide(color: color, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    color: NexusTheme.slate400,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              if (icon != null)
                Icon(icon, size: 14, color: NexusTheme.slate200),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: NexusTheme.slate900,
                    letterSpacing: -1,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: NexusTheme.slate400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionTab(String title, IconData icon) {
    bool isSelected = _selectedTab == title;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = title),
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF5850EC) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : const Color(0xFF64748B),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: isSelected ? Colors.white : const Color(0xFF64748B),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isPrimary,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: isPrimary ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isPrimary ? Colors.white : const Color(0xFF64748B),
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: isPrimary ? Colors.white : const Color(0xFF475569),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tableHeader(String label) => Text(
    label,
    style: const TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w900,
      color: Color(0xFF94A3B8),
      letterSpacing: 1.5,
    ),
  );

  Widget _buildDataTable() {
    final provider = Provider.of<NexusProvider>(context);
    List<dynamic> items = [];
    if (_selectedTab == 'USER MASTER')
      items = provider.users;
    else if (_selectedTab == 'CUSTOMER MASTER')
      items = provider.customers;
    else if (_selectedTab == 'MATERIAL MASTER')
      items = provider.products;

    if (items.isEmpty) {
      return Center(
        child: Text(
          'NO DATA IN $_selectedTab',
          style: const TextStyle(
            color: Color(0xFF94A3B8),
            fontWeight: FontWeight.w900,
            fontSize: 10,
            letterSpacing: 1,
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(48, 24, 48, 48),
      itemCount: items.length,
      separatorBuilder: (_, __) =>
          const Divider(color: Color(0xFFF8FAFC), height: 1),
      itemBuilder: (context, index) {
        final item = items[index];
        String id = '';
        String name = '';
        if (item is User) {
          id = item.id;
          name = item.name;
        } else if (item is Customer) {
          id = item.id;
          name = item.name;
        } else if (item is Product) {
          id = item.id;
          name = item.name;
        }

        return InkWell(
          onTap: () => _showMasterForm(context, initialData: item),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    id,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1E293B),
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

  void _showMasterForm(BuildContext context, {dynamic initialData}) {
    final provider = Provider.of<NexusProvider>(context, listen: false);
    final Map<String, TextEditingController> controllers = {};
    
    List<String> fields = [];
    if (_selectedTab == 'CUSTOMER MASTER') {
      fields = ['ID', 'NAME', 'ADDRESS', 'CITY', 'LIMIT'];
    } else if (_selectedTab == 'MATERIAL MASTER') {
      fields = ['SKU CODE', 'NAME', 'PRICE', 'CATEGORY', 'STOCK'];
    } else {
      fields = ['NAME', 'EMAIL', 'ROLE', 'PASSWORD', 'LOCATION', 'DEPARTMENT 1', 'DEPARTMENT 2', 'CHANNEL', 'WHATSAPP', 'SALARY'];
    }

    // Initialize controllers with initialData if available
    for (var f in fields) {
      String value = '';
      if (initialData != null) {
        if (_selectedTab == 'USER MASTER' && initialData is User) {
          if (f == 'NAME') value = initialData.name;
          if (f == 'EMAIL') value = initialData.id;
          if (f == 'ROLE') value = initialData.role.label;
          if (f == 'LOCATION') value = initialData.location;
          if (f == 'DEPARTMENT 1') value = initialData.department1 ?? '';
          if (f == 'DEPARTMENT 2') value = initialData.department2 ?? '';
          if (f == 'CHANNEL') value = initialData.channel ?? '';
          if (f == 'WHATSAPP') value = initialData.whatsappNumber ?? '';
        } else if (_selectedTab == 'CUSTOMER MASTER' && initialData is Customer) {
          if (f == 'ID') value = initialData.id;
          if (f == 'NAME') value = initialData.name;
          if (f == 'ADDRESS') value = initialData.address;
          if (f == 'CITY') value = initialData.city;
          if (f == 'LIMIT') value = initialData.limit.toString();
        } else if (_selectedTab == 'MATERIAL MASTER' && initialData is Product) {
          if (f == 'SKU CODE') value = initialData.skuCode;
          if (f == 'NAME') value = initialData.name;
          if (f == 'PRICE') value = initialData.price.toString();
          if (f == 'CATEGORY') value = initialData.category;
          if (f == 'STOCK') value = initialData.stock.toString();
        }
      }
      controllers[f] = TextEditingController(text: value);
    }

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          bool isFormLoading = false;
          
          return Dialog(
            backgroundColor: Colors.white,
            insetPadding: const EdgeInsets.all(20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        initialData == null ? 'Add New Entry' : 'Edit Entry',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Color(0xFF0F172A), size: 28),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        children: fields.map((f) => Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: TextField(
                            controller: controllers[f],
                            style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 14),
                            decoration: InputDecoration(
                              labelText: f.toUpperCase(),
                              labelStyle: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1),
                              floatingLabelBehavior: FloatingLabelBehavior.always,
                              enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF0F172A), width: 1.5), borderRadius: BorderRadius.circular(16)),
                              focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2), borderRadius: BorderRadius.circular(16)),
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                            ),
                          ),
                        )).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: isFormLoading ? null : () async {
                        setDialogState(() => isFormLoading = true);
                        bool success = false;
                        
                        try {
                          if (_selectedTab == 'USER MASTER') {
                            success = await provider.createUser({
                              'name': controllers['NAME']!.text,
                              'id': controllers['EMAIL']!.text,
                              'role': controllers['ROLE']!.text,
                              'password': controllers['PASSWORD']!.text,
                              'location': controllers['LOCATION']!.text,
                              'department1': controllers['DEPARTMENT 1']!.text,
                              'department2': controllers['DEPARTMENT 2']!.text,
                              'channel': controllers['CHANNEL']!.text,
                              'whatsappNumber': controllers['WHATSAPP']!.text,
                            });
                          } else if (_selectedTab == 'CUSTOMER MASTER') {
                            success = await provider.createCustomer({
                              'id': controllers['ID']!.text,
                              'name': controllers['NAME']!.text,
                              'address': controllers['ADDRESS']!.text,
                              'city': controllers['CITY']!.text,
                              'limit': double.tryParse(controllers['LIMIT']!.text) ?? 1500000,
                            });
                          } else if (_selectedTab == 'MATERIAL MASTER') {
                            success = await provider.createProduct({
                              'skuCode': controllers['SKU CODE']!.text,
                              'name': controllers['NAME']!.text,
                              'price': double.tryParse(controllers['PRICE']!.text) ?? 0.0,
                              'category': controllers['CATEGORY']!.text,
                              'stock': int.tryParse(controllers['STOCK']!.text) ?? 0,
                            });
                          }
                          
                          if (success && context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Successfully saved to Master!'), backgroundColor: Colors.green),
                            );
                          }
                        } catch (e) {
                           if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                            );
                          }
                        } finally {
                          if (context.mounted) setDialogState(() => isFormLoading = false);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F172A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: isFormLoading 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('SAVE TO MASTER', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
