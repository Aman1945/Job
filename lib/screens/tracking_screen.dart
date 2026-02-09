import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../models/models.dart';

class TrackingScreen extends StatefulWidget {
  final Order order;
  const TrackingScreen({super.key, required this.order});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(seconds: 10), vsync: this)..repeat(reverse: true);
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NexusTheme.slate50,
      appBar: AppBar(title: Text('LIVE TRACKING: ${widget.order.id}')),
      body: Column(
        children: [
          // Simulated Map
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                border: Border.all(color: NexusTheme.slate200),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  children: [
                    // A simple background to simulate a map
                    Image.network(
                      'https://api.mapbox.com/styles/v1/mapbox/light-v10/static/72.8777,19.0760,12/600x400?access_token=MOCK_TOKEN',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(color: Colors.blue.shade50);
                      },
                    ),
                    // Grid lines to look technical
                    Opacity(
                      opacity: 0.1,
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 10),
                        itemBuilder: (c, i) => Container(decoration: BoxDecoration(border: Border.all(color: Colors.black12))),
                      ),
                    ),
                    // Moving Truck Icon
                    AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return Positioned(
                          left: 100 + (150 * _animation.value),
                          top: 100 + (200 * _animation.value),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: NexusTheme.emerald900, borderRadius: BorderRadius.circular(8)),
                                child: const Text('DISPATCH_01', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                              ),
                              const Icon(Icons.local_shipping, color: NexusTheme.emerald500, size: 40),
                            ],
                          ),
                        );
                      },
                    ),
                    // Destination Marker
                    const Positioned(
                      right: 40,
                      top: 40,
                      child: Icon(Icons.location_on, color: Colors.redAccent, size: 40),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Info Panel
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('ESTIMATED ARRIVAL', style: TextStyle(color: NexusTheme.slate400, fontWeight: FontWeight.bold, fontSize: 12)),
                    Text('14 MINS', style: TextStyle(color: NexusTheme.emerald500, fontWeight: FontWeight.w900, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(widget.order.customerName.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: NexusTheme.emerald950)),
                const Text('45, Bandra Kurla Complex, Mumbai', style: TextStyle(color: NexusTheme.slate400)),
                const Divider(height: 32),
                Row(
                  children: [
                    const CircleAvatar(backgroundColor: NexusTheme.slate200, child: Icon(Icons.person, color: NexusTheme.slate400)),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('SURESH KUMAR', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('Vehicle: MH-01-AX-4521', style: TextStyle(fontSize: 12, color: NexusTheme.slate400)),
                      ],
                    ),
                    const Spacer(),
                    IconButton.filled(
                      onPressed: () {},
                      icon: const Icon(Icons.phone),
                      style: IconButton.styleFrom(backgroundColor: NexusTheme.emerald900),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
