import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
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
  
  // Simulated coordinates (Mumbai area)
  final LatLng _startPoint = const LatLng(19.0760, 72.8777); // Mumbai
  final LatLng _endPoint = const LatLng(19.1136, 72.8697); // Andheri

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(seconds: 20), vsync: this)..repeat(reverse: true);
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  LatLng _getCurrentTruckPos(double val) {
    double lat = _startPoint.latitude + (_endPoint.latitude - _startPoint.latitude) * val;
    double lng = _startPoint.longitude + (_endPoint.longitude - _startPoint.longitude) * val;
    return LatLng(lat, lng);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NexusTheme.slate50,
      appBar: AppBar(
        title: Text('LIVE TRACKING: ${widget.order.id}'),
        surfaceTintColor: Colors.transparent,
      ),
      body: Column(
        children: [
          // Proper Interactive Map
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 15, offset: Offset(0, 5))],
                border: Border.all(color: NexusTheme.slate200, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    final truckPos = _getCurrentTruckPos(_animation.value);
                    return FlutterMap(
                      options: MapOptions(
                        initialCenter: const LatLng(19.0948, 72.8737),
                        initialZoom: 13,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.nexus.oms',
                        ),
                        PolylineLayer(
                          polylines: [
                            Polyline(
                              points: [_startPoint, _endPoint],
                              color: NexusTheme.emerald500.withValues(alpha: 0.3),
                              strokeWidth: 4,
                            ),
                          ],
                        ),
                        MarkerLayer(
                          markers: [
                            // Destination
                            Marker(
                              point: _endPoint,
                              width: 80,
                              height: 80,
                              child: const Icon(Icons.location_on, color: Colors.redAccent, size: 40),
                            ),
                            // Moving Truck
                            Marker(
                              point: truckPos,
                              width: 120,
                              height: 120,
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: NexusTheme.emerald900,
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                                    ),
                                    child: const Text(
                                      'DISPATCH_01', 
                                      style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)
                                    ),
                                  ),
                                  const Icon(Icons.local_shipping, color: NexusTheme.emerald600, size: 40),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
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
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('ESTIMATED ARRIVAL', style: TextStyle(color: NexusTheme.slate400, fontWeight: FontWeight.bold, fontSize: 12)),
                    Text('14 MINS', style: TextStyle(color: NexusTheme.emerald600, fontWeight: FontWeight.w900, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  widget.order.customerName.toUpperCase(), 
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: NexusTheme.emerald950, letterSpacing: -0.5)
                ),
                const Text('45, Bandra Kurla Complex, Mumbai', style: TextStyle(color: NexusTheme.slate500, fontWeight: FontWeight.w500)),
                const Divider(height: 32, thickness: 1),
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 24,
                      backgroundColor: NexusTheme.slate100, 
                      child: Icon(Icons.person, color: NexusTheme.slate400, size: 30)
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('SURESH KUMAR', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                        Text('Vehicle: MH-01-AX-4521', style: TextStyle(fontSize: 12, color: NexusTheme.slate500, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      decoration: BoxDecoration(
                        color: NexusTheme.emerald900,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.phone, color: Colors.white),
                      ),
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
