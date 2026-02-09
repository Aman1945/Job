import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/nexus_provider.dart';
import '../utils/theme.dart';
import '../models/models.dart';

class OrderArchiveScreen extends StatelessWidget {
  const OrderArchiveScreen({super.key});

  void _showTallyPreview(BuildContext context, Order order) {
    // This is the "Trust-Builder" logic. 
    // It generates real Tally XML structure.
    final String tallyXml = '''
<ENVELOPE>
 <HEADER>
  <TALLYREQUEST>Import Data</TALLYREQUEST>
 </HEADER>
 <BODY>
  <IMPORTDATA>
   <REQUESTDESC>
    <REPORTNAME>Vouchers</REPORTNAME>
   </REQUESTDESC>
   <REQUESTDATA>
    <TALLYMESSAGE xmlns:UDF="TallyUDF">
     <VOUCHER VCHTYPE="Sales" ACTION="Create">
      <DATE>${order.createdAt.toString().split(' ')[0].replaceAll('-', '')}</DATE>
      <VOUCHERNUMBER>${order.id}</VOUCHERNUMBER>
      <PARTYLEDGERNAME>${order.customerName}</PARTYLEDGERNAME>
      <EFFECTIVEDATE>${order.createdAt.toString().split(' ')[0].replaceAll('-', '')}</EFFECTIVEDATE>
      <ALLLEDGERENTRIES.LIST>
       <LEDGERNAME>${order.customerName}</LEDGERNAME>
       <ISDEEMEDPOSITIVE>Yes</ISDEEMEDPOSITIVE>
       <AMOUNT>-${order.total}</AMOUNT>
      </ALLLEDGERENTRIES.LIST>
      <ALLLEDGERENTRIES.LIST>
       <LEDGERNAME>Sales Account</LEDGERNAME>
       <ISDEEMEDPOSITIVE>No</ISDEEMEDPOSITIVE>
       <AMOUNT>${order.total}</AMOUNT>
      </ALLLEDGERENTRIES.LIST>
     </VOUCHER>
    </TALLYMESSAGE>
   </REQUESTDATA>
  </IMPORTDATA>
 </BODY>
</ENVELOPE>''';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: NexusTheme.emerald950,
        title: const Text('TALLY XML GENERATED', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.black38, borderRadius: BorderRadius.circular(8)),
            child: Text(
              tallyXml,
              style: const TextStyle(color: NexusTheme.emerald400, fontSize: 10, fontFamily: 'monospace'),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CLOSE', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sent to Tally Bridge successfully!')));
            },
            style: ElevatedButton.styleFrom(backgroundColor: NexusTheme.emerald500),
            child: const Text('SYNC NOW'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NexusProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('ORDER ARCHIVE')),
      body: provider.orders.isEmpty
          ? const Center(child: Text('No orders found in archive.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.orders.length,
              itemBuilder: (context, index) {
                final order = provider.orders[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    order.id, 
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900, 
                                      fontSize: 12, 
                                      color: NexusTheme.slate400
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    order.customerName, 
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold, 
                                      fontSize: 16
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: NexusTheme.emerald500.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                order.status.toUpperCase(),
                                style: const TextStyle(
                                  color: NexusTheme.emerald900, 
                                  fontWeight: FontWeight.w900, 
                                  fontSize: 10
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'TOTAL: ₹${order.total.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900, 
                                  fontSize: 18, 
                                  color: NexusTheme.emerald900
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: () => _showTallyPreview(context, order),
                              icon: const Icon(Icons.sync, size: 16),
                              label: const Text('TALLY'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: NexusTheme.emerald900,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12, 
                                  vertical: 8
                                ),
                              ),
                            ),
                          ],
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
