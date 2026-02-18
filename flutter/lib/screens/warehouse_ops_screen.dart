import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/nexus_provider.dart';
import '../models/models.dart';
import '../widgets/nexus_components.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class WarehouseOpsScreen extends StatefulWidget {
  const WarehouseOpsScreen({super.key});

  @override
  State<WarehouseOpsScreen> createState() => _WarehouseOpsScreenState();
}

class _WarehouseOpsScreenState extends State<WarehouseOpsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Slate 50 background
      appBar: AppBar(
        title: const Text('3. WAREHOUSE OPERATIONS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1, color: Color(0xFF1E293B))),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF059669),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF059669),
          labelStyle: const TextStyle(fontWeight: FontWeight.w700),
          tabs: const [
            Tab(text: 'WAREHOUSE ASSIGNMENT'),
            Tab(text: 'PACKING OPERATIONS'),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(LucideIcons.refreshCw), onPressed: () => setState((){})),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAssignmentTerminal(),
          _buildPackingTerminalList(),
        ],
      ),
    );
  }

  // --- TAB 1: WAREHOUSE ASSIGNMENT ---
  Widget _buildAssignmentTerminal() {
    final provider = Provider.of<NexusProvider>(context);
    final orders = provider.orders.where((o) => o.status == 'Pending WH Selection').toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 900;
        
        return SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 16 : 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isMobile)
                const Text('Warehouse Selection', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)))
              else
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF059669), Color(0xFF34D399)]),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: const Color(0xFF059669).withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 6))],
                      ),
                      child: const Icon(LucideIcons.warehouse, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 16),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Warehouse Selection Terminal', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
                        Text('Assign cold-room facilities for pending missions', style: TextStyle(color: Colors.grey, fontSize: 13)),
                      ],
                    ),
                  ],
                ),
              const SizedBox(height: 32),
              
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white, 
                  borderRadius: BorderRadius.circular(16), 
                  border: Border.all(color: Colors.grey[200]!),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 16, offset: const Offset(0, 4))],
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    icon: Icon(LucideIcons.search, color: Colors.grey),
                    hintText: 'Search by Order ID, Client, or Location...',
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              if (orders.isEmpty)
                Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 48),
                      Icon(LucideIcons.checkCircle, size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      const Text('All caught up!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8))),
                      const Text('No orders pending facility assignment.', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              else
                ...orders.map((o) => _buildAssignmentCard(o, isMobile)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAssignmentCard(Order order, bool isMobile) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: EdgeInsets.all(isMobile ? 20 : 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: [BoxShadow(color: const Color(0xFF64748B).withValues(alpha: 0.08), blurRadius: 32, offset: const Offset(0, 12))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isMobile) 
            // Mobile Header
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: [
                     NexusComponents.statusBadge(order.status),
                     Text('₹${NumberFormat('#,##,###').format(order.total)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
                   ],
                 ),
                 const SizedBox(height: 16),
                 Text(order.id, style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF6366F1), letterSpacing: 0.5)),
                 const SizedBox(height: 4),
                 Text(order.customerName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
                 const SizedBox(height: 4),
                 const Text('PENDING FACILITY ASSIGNMENT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
              ],
            )
          else
            // Desktop Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Container(
                       padding: const EdgeInsets.all(12),
                       decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
                       child: const Icon(LucideIcons.package, color: Color(0xFF64748B)),
                     ),
                     const SizedBox(width: 16),
                     Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Row(
                           children: [
                             Text(order.id, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF6366F1))),
                             const SizedBox(width: 12),
                             NexusComponents.statusBadge(order.status),
                           ],
                         ),
                         const SizedBox(height: 6),
                         Text(order.customerName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
                         const Text('AWAITING FACILITY ROUTING', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
                       ],
                     )
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('₹${NumberFormat('#,##,###').format(order.total)}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
                    const Text('TOTAL VALUE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5)),
                  ],
                )
              ],
            ),
          
          const SizedBox(height: 32),
          const Text('INVENTORY SNAPSHOT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8), letterSpacing: 1)),
          const SizedBox(height: 16),
          Container(
             padding: const EdgeInsets.all(20),
             decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
             child: const Row(
               children: [
                 Icon(LucideIcons.layers, size: 20, color: Color(0xFF6366F1)),
                 SizedBox(width: 16),
                 Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Text('Mixed SKU Batch', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF1E293B))),
                     Text('Standard Handling Required', style: TextStyle(fontSize: 12, color: Colors.grey)),
                   ],
                 ),
                 Spacer(),
                 Text('VARIOUS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF64748B))),
               ],
             ),
          ),
          const SizedBox(height: 32),
          const Text('SELECT FACILITY TO ROUTE STOCK', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8), letterSpacing: 1)),
          const SizedBox(height: 16),
          LayoutBuilder(
             builder: (ctx, constraints) {
               return Wrap(
                 spacing: 12,
                 runSpacing: 12,
                 children: [
                   _buildFacilityButton(order, 'IOPL KURLA', 'amit.kurla@bigsams.in', isMobile),
                   _buildFacilityButton(order, 'IOPL DP WORLD', 'dp.world@bigsams.in', isMobile),
                   _buildFacilityButton(order, 'IOPL ARIHANT DELHI', 'roshan.delhi@bigsams.in', isMobile),
                   _buildFacilityButton(order, 'IOPL JOLLY BNG', 'jolly.bng@bigsams.in', isMobile),
                 ],
               );
             },
          )
        ],
      ),
    );
  }

  Widget _buildFacilityButton(Order order, String label, String email, bool isMobile) {
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: isMobile ? double.infinity : 180),
      child: ElevatedButton(
        onPressed: () => _assignFacility(order, label, email),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1E293B),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey[200]!, width: 1.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.arrowRightCircle, size: 16, color: Color(0xFF6366F1)),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 0.5)),
          ],
        ),
      ),
    );
  }

  // --- TAB 2: PACKING OPERATIONS (Hub View) ---
  Widget _buildPackingTerminalList() {
    final provider = Provider.of<NexusProvider>(context);
    final orders = provider.orders.where((o) => o.status == 'Pending Packing').toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 900;

        return SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 16 : 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isMobile)
                const Text('Packing Operations', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)))
              else
                Row(
                  children: [
                     Container(
                       padding: const EdgeInsets.all(12),
                       decoration: BoxDecoration(
                         gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF818CF8)]),
                         borderRadius: BorderRadius.circular(12),
                         boxShadow: [BoxShadow(color: const Color(0xFF6366F1).withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 6))],
                       ),
                       child: const Icon(LucideIcons.packageCheck, color: Colors.white, size: 24),
                     ),
                     const SizedBox(width: 16),
                     const Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Text('Packing Operations Terminal', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
                         Text('Oversee packing and dispatch to QC', style: TextStyle(color: Colors.grey, fontSize: 13)),
                        ],
                     ),
                  ],
                ),
              const SizedBox(height: 32),

              if (!isMobile)
                Container(
                 padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                 decoration: const BoxDecoration(
                   color: Colors.white, 
                   borderRadius:  BorderRadius.vertical(top: Radius.circular(16)),
                   border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
                 ),
                 child: Row(
                   children: const [
                     Expanded(flex: 2, child: Text('MISSION REF', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8), letterSpacing: 1))),
                     Expanded(flex: 3, child: Text('ENTITY IDENTITY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8), letterSpacing: 1))),
                     Expanded(flex: 2, child: Text('CURRENT STATUS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8), letterSpacing: 1))),
                     Expanded(flex: 2, child: Text('REFERENCE VALUE (₹)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8), letterSpacing: 1))),
                     Expanded(flex: 3, child: Text('WORKFLOW ACTION', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8), letterSpacing: 1))),
                     Expanded(flex: 2, child: Text('OPERATIONS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8), letterSpacing: 1))),
                   ],
                 ),
               ),
               
               if (orders.isEmpty)
                 Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 48),
                      Icon(LucideIcons.packageOpen, size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      const Text('No packing tasks pending.', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8))),
                    ],
                  ),
                )
               else
                ...orders.map((o) => isMobile 
                    ? _buildMobilePackingCard(o) 
                    : _buildPackingRow(o)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPackingRow(Order order) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
      ),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(order.id, style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF10B981)))),
          Expanded(flex: 3, child: Text(order.customerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B)))),
          Expanded(flex: 2, child: NexusComponents.statusBadge(order.status)),
          Expanded(flex: 2, child: Text('₹${NumberFormat('#,##,###').format(order.total)}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13))),
          Expanded(
            flex: 3, 
            child: SizedBox(
              width: 140,
              child: ElevatedButton(
                onPressed: () => _pushToQC(order),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                  shadowColor: const Color(0xFF6366F1).withValues(alpha: 0.4),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.checkCircle, size: 14),
                    SizedBox(width: 8),
                    Text('PUSH TO QC', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.5)),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2, 
            child: OutlinedButton(
               onPressed: () {}, 
               style: OutlinedButton.styleFrom(
                 backgroundColor: const Color(0xFF0F172A),
                 foregroundColor: Colors.white,
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                 padding: const EdgeInsets.symmetric(vertical: 16),
               ),
               child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.eye, size: 14),
                    SizedBox(width: 8),
                    Text('QUICK VIEW', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10)),
                  ],
               ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobilePackingCard(Order order) {
    return Container(
       margin: const EdgeInsets.only(bottom: 16),
       padding: const EdgeInsets.all(20),
       decoration: BoxDecoration(
         color: Colors.white,
         borderRadius: BorderRadius.circular(20),
         border: Border.all(color: Colors.grey[100]!),
         boxShadow: [BoxShadow(color: const Color(0xFF64748B).withValues(alpha: 0.05), blurRadius: 16, offset: const Offset(0, 8))],
       ),
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
             Text(order.id, style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF10B981))),
             NexusComponents.statusBadge(order.status),
           ]),
           const SizedBox(height: 12),
           Text(order.customerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B))),
           const SizedBox(height: 8),
           Text('₹${NumberFormat('#,##,###').format(order.total)}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF1E293B))),
           const SizedBox(height: 24),
           SizedBox(
             width: double.infinity,
             child: ElevatedButton(
                onPressed: () => _pushToQC(order),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  shadowColor: const Color(0xFF6366F1).withValues(alpha: 0.3),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.checkCircle, size: 18),
                    SizedBox(width: 8),
                    Text('PUSH TO QUALITY CONTROL', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                  ],
                ),
             ),
           ),
           const SizedBox(height: 12),
           SizedBox(
             width: double.infinity,
             child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                   side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                child: const Text('QUICK VIEW', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
             ),
           )
         ],
       ),
    );
  }

  Future<void> _assignFacility(Order order, String facility, String email) async {
    final provider = Provider.of<NexusProvider>(context, listen: false);
    
    // 1. Update Order Status
    await provider.updateOrderStatus(order.id, 'Pending Packing'); 
    
    // 2. Email Notification (CC to Operations for Tracking)
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'cc=operations@bigsams.in&subject=URGENT: Packing Req for ${order.id} @ $facility&body=PRIORITY ORDER DETAILS\n------------------------\nClient: ${order.customerName}\nValue: ${NumberFormat.simpleCurrency(name: 'INR').format(order.total)}\nStatus: Ready for Packing\n\nPlease expedite immediately.\n\n- BigSams Operations System',
    );

    try {
      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri);
      }
    } catch (e) {
      debugPrint('Could not launch email: $e');
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(children: [const Icon(LucideIcons.mailCheck, color: Colors.white, size: 16), const SizedBox(width: 8), Text('Route Assigned: $facility')]),
        backgroundColor: const Color(0xFF059669),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ));
      setState(() {});
    }
  }

  Future<void> _pushToQC(Order order) async {
    final provider = Provider.of<NexusProvider>(context, listen: false);
    await provider.updateOrderStatus(order.id, 'Pending Quality Control');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Row(children: [Icon(LucideIcons.checkCircle, color: Colors.white, size: 16), SizedBox(width: 8), Text('Dispatched to Quality Control')]),
        backgroundColor: const Color(0xFF6366F1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ));
    }
  }
}
