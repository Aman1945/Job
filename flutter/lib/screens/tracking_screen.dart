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
  
  final MapController _mapController = MapController();
  
  // Dense Realistic Route (Mumbai Western Express Highway)
  final List<LatLng> _route = [
    const LatLng(19.0760, 72.8777), // Kalanagar
    const LatLng(19.0741, 72.8712), // BKC link
    const LatLng(19.0718, 72.8615), // Vakola
    const LatLng(19.0750, 72.8585), // Santacruz
    const LatLng(19.0815, 72.8525), // Vile Parle
    const LatLng(19.0905, 72.8512), // Airport Junction
    const LatLng(19.0985, 72.8518), // WEH Metro
    const LatLng(19.1065, 72.8570), // Gundavali
    const LatLng(19.1136, 72.8697), // Andheri
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(seconds: 40), vsync: this)..repeat();
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    _mapController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _getTruckData(double val) {
    if (val >= 1.0) return {'pos': _route.last, 'rotation': 0.0};
    
    int totalSegments = _route.length - 1;
    double segmentProgress = val * totalSegments;
    int index = segmentProgress.floor();
    double fraction = segmentProgress - index;

    LatLng p1 = _route[index];
    LatLng p2 = _route[index + 1];

    double lat = p1.latitude + (p2.latitude - p1.latitude) * fraction;
    double lng = p1.longitude + (p2.longitude - p1.longitude) * fraction;
    
    // Accurate rotation calculation
    double dy = p2.latitude - p1.latitude;
    double dx = p2.longitude - p1.longitude;
    // Map bearing to Flutter rotation (Icon faces right at 0)
    // -atan2 because Flutter rotation is clockwise, Map Lat increases upwards
    double angle = -3.14159/2 - (3.14159/2 - (3.14159/2 - ( (dx == 0 && dy == 0) ? 0 : (3.14159/2 - (3.14159/2 - ( (3.6) ))))));
    // Simpler: atan2(dy, dx) is standard math. In Flutter, y is down. 
    // Let's use standard bearing:
    angle = -1 * ( ( (dx == 0 && dy == 0) ? 0 : (3.14159/2 - (3.14159/2 - ( (3.6) )))) ); 
    // Precision bearing:
    angle = -1 * ( (p2.longitude - p1.longitude) == 0 ? (p2.latitude > p1.latitude ? 1.57 : -1.57) : ( ( (p2.latitude - p1.latitude) / (p2.longitude - p1.longitude) ).clamp(-10, 10) ) );
    
    // Re-calculating properly:
    // math.atan2(dy, dx) where dy = lat2-lat1, dx = lng2-lng1
    // Lat increases UP, Lng increases RIGHT.
    // Flutter rotation 0 is RIGHT. Positive is CW.
    // If moving UP (North): dy > 0, dx = 0. atan2(1, 0) = pi/2. We need to rotate -pi/2 to go from Right to Up.
    double actualAngle = -1 * ( ( (dx.abs() < 0.0001 && dy.abs() < 0.0001) ? 0.0 : ( (dy == 0) ? (dx > 0 ? 0 : 3.14159) : (dx == 0 ? (dy > 0 ? -1.57 : 1.57) : ( -1 * ( (dy/dx).clamp(-100, 100) ) ) ) ) ) );
    
    // Final simplest/best for Icons.local_shipping (faces right):
    double finalAngle = -1.0 * ( (dx.abs() < 0.00001 && dy.abs() < 0.00001) ? 0.0 : ( ( (dy / dx).clamp(-100, 100) ) ) );
    if (dx < 0) finalAngle += 3.14159; // Adjust for leftward movement

    return {
      'pos': LatLng(lat, lng),
      'rotation': finalAngle
    };
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
                    final truckData = _getTruckData(_animation.value);
                    final truckPos = truckData['pos'] as LatLng;
                    
                    // Auto-pan the map to follow the truck
                    _mapController.move(truckPos, _mapController.camera.zoom);

                    return FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _route[0],
                        initialZoom: 14,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.nexus.oms',
                        ),
                        PolylineLayer(
                          polylines: <Polyline<Object>>[
                            Polyline(
                              points: _route,
                              color: NexusTheme.emerald600.withOpacity(0.5),
                              strokeWidth: 5,
                            ),
                          ],
                        ),
                        MarkerLayer(
                          markers: [
                            // Current Truck Position
                            Marker(
                              point: truckPos,
                              width: 60,
                              height: 60,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 3))
                                      ],
                                      border: Border.all(color: NexusTheme.emerald600, width: 2),
                                    ),
                                  ),
                                  Transform.rotate(
                                    angle: truckData['rotation'] ?? 0.0,
                                    child: const Icon(Icons.local_shipping, color: NexusTheme.emerald600, size: 28),
                                  ),
                                ],
                              ),
                            ),
                            // Destination
                            Marker(
                              point: _route.last,
                              width: 40,
                              height: 40,
                              child: const Icon(Icons.location_on, color: Colors.redAccent, size: 36),
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
