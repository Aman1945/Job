import 'package:flutter/material.dart';
import '../utils/theme.dart';

class OrderArchiveScreen extends StatelessWidget {
  const OrderArchiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('ORDERS MASTER ARCHIVE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: NexusTheme.blue50,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.archive_outlined,
                size: 64,
                color: NexusTheme.blue600,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'COMING SOON',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: NexusTheme.slate900,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'The Master Order Archive terminal is currently undergoing\ndigital synchronization and data migration.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: NexusTheme.slate400,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
