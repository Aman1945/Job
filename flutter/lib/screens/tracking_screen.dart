import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
  GoogleMapController? _mapController;
  
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
    
    _controller.addListener(() {
      if (mounted) {
        final truckData = _getTruckData(_animation.value);
        final truckPos = truckData['pos'] as LatLng;
        _mapController?.animateCamera(CameraUpdate.newLatLng(truckPos));
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _mapController?.dispose();
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
    
    double dy = p2.latitude - p1.latitude;
    double dx = p2.longitude - p1.longitude;
    
    double finalAngle = 0.0;
    if (dx != 0 || dy != 0) {
      finalAngle = ( ( (dy / dx).clamp(-100, 100) ) );
      if (dx < 0) finalAngle += 3.14159;
    }

    return {
      'pos': LatLng(lat, lng),
      'rotation': finalAngle * 180 / 3.14159 // Google Maps uses degrees
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
                    final rotation = truckData['rotation'] as double;
                    
                    return GoogleMap(
                      onMapCreated: (controller) => _mapController = controller,
                      initialCameraPosition: CameraPosition(
                        target: _route[0],
                        zoom: 15,
                      ),
                      polylines: {
                        Polyline(
                          polylineId: const PolylineId('route'),
                          points: _route,
                          color: NexusTheme.emerald600.withOpacity(0.6),
                          width: 5,
                        ),
                      },
                      markers: {
                        Marker(
                          markerId: const MarkerId('truck'),
                          position: truckPos,
                          rotation: rotation,
                          anchor: const Offset(0.5, 0.5),
                          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
                        ),
                        Marker(
                          markerId: const MarkerId('destination'),
                          position: _route.last,
                          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                        ),
                      },
                    );
                  },
                ),
              ),
            ),
          ),
          // Info Panel (Same as before)
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
