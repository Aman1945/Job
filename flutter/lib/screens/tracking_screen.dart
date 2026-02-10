import 'dart:ui' as ui;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../utils/theme.dart';
import '../models/models.dart';
import '../controllers/testdrive/background_location_service.dart';
import '../controllers/testdrive/drive_state_manager.dart';
import '../controllers/testdrive/route_calculator.dart';
import '../services/location_database_service.dart';

class TrackingScreen extends StatefulWidget {
  final Order order;
  const TrackingScreen({super.key, required this.order});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  GoogleMapController? _mapController;
  Marker? _truckMarker;
  Marker? _destinationMarker;
  List<LatLng> _routePoints = [];
  Polyline? _routePolyline;
  BitmapDescriptor? _customTruckIcon;
  
  bool _isLoading = true;
  double _totalDistance = 0.0;
  String _estimatedTime = "Calculating...";
  LatLng? _currentPosition;
  
  final BackgroundLocationService _bgService = BackgroundLocationService();
  final LocationDatabase _db = LocationDatabase();
  final RouteCalculator _routeCalc = RouteCalculator();

  @override
  void initState() {
    super.initState();
    _loadCustomTruckIcon();
    _initializeTracking();
  }

  Future<void> _loadCustomTruckIcon() async {
    final iconData = Icons.local_shipping;
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    const size = ui.Size(120, 120);
    
    // Draw background circle
    final paint = Paint()..color = NexusTheme.indigo600;
    canvas.drawCircle(const Offset(60, 60), 60, paint);
    
    // Draw icon
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: String.fromCharCode(iconData.codePoint),
      style: TextStyle(
        fontSize: 70,
        fontFamily: iconData.fontFamily,
        color: Colors.white,
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, const Offset(25, 25));

    final picture = pictureRecorder.endRecording();
    final image = await picture.toImage(size.width.toInt(), size.height.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    
    if (bytes != null) {
      setState(() {
        _customTruckIcon = BitmapDescriptor.fromBytes(bytes.buffer.asUint8List());
      });
    }
  }

  Future<void> _initializeTracking() async {
    setState(() => _isLoading = true);

    try {
      // 1. Check & Request Permissions with a better UI
      bool hasPermission = await _requestLocationPermission();
      if (!hasPermission) {
        if (mounted) {
          setState(() => _isLoading = false);
        }
        return;
      }

      // 2. Check if we have an active drive state to resume
      if (DriveStateManager.hasActiveDrive && DriveStateManager.eventId == widget.order.id) {
        _totalDistance = DriveStateManager.totalDistance;
        _routePoints = await _db.getRoutePoints(widget.order.id);
        _currentPosition = DriveStateManager.lastLocation;
      } else {
        // Start fresh
        Position pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        _currentPosition = LatLng(pos.latitude, pos.longitude);
        _routePoints = [_currentPosition!];
        
        await DriveStateManager.startDrive(
          eventId: widget.order.id,
          leadId: widget.order.customerId,
          startLocation: _currentPosition!,
        );
      }

      _updateMarkers();
      _updatePolyline();

      // 3. Start Background Service
      await _bgService.initialize();
      await _bgService.startTracking();
      _bgService.sendDriveId(widget.order.id);
      
      // 4. Listen for updates
      _bgService.listenToUpdates((data) {
        if (mounted) {
          _handleLocationUpdate(data);
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tracking Error: $e'),
            backgroundColor: NexusTheme.rose600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<bool> _requestLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        _showErrorDialog(
          "Location Service Disabled",
          "Please enable GPS to start live tracking.",
          Icons.location_off,
        );
      }
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // Show custom explanation dialog first
      bool? proceed = await _showPermissionExplainer();
      if (proceed != true) return false;

      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          _showErrorDialog(
            "Permission Denied",
            "Location access is mandatory for freight tracking.",
            Icons.security_update_warning,
          );
        }
        return false;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        _showErrorDialog(
          "Permanent Denial",
          "Location permissions are permanently blocked. Please enable them in system settings.",
          Icons.settings_suggest,
          showSettings: true,
        );
      }
      return false;
    }

    return true;
  }

  Future<bool?> _showPermissionExplainer() {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: NexusTheme.indigo50, shape: BoxShape.circle),
              child: const Icon(Icons.location_on, color: NexusTheme.indigo600, size: 48),
            ),
            const SizedBox(height: 32),
            const Text("Location Access", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: NexusTheme.slate900)),
            const SizedBox(height: 16),
            const Text(
              "We need your location to track freight movement and calculate delivery ETAs in real-time.",
              textAlign: TextAlign.center,
              style: TextStyle(color: NexusTheme.slate500, fontWeight: FontWeight.w500, fontSize: 14),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: NexusTheme.indigo600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text("GRANT ACCESS", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1)),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("NOT NOW", style: TextStyle(color: NexusTheme.slate400, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorDialog(String title, String message, IconData icon, {bool showSettings = false}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Icon(icon, color: NexusTheme.rose600, size: 64),
            const SizedBox(height: 24),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: NexusTheme.slate900)),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: NexusTheme.slate500, fontWeight: FontWeight.w500)),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  if (showSettings) Geolocator.openAppSettings();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: NexusTheme.slate900,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(showSettings ? "OPEN SETTINGS" : "OKAY", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleLocationUpdate(Map<String, dynamic> data) async {
    final newPos = LatLng(data['latitude'], data['longitude']);
    
    if (_currentPosition != null) {
      double distance = Geolocator.distanceBetween(
        _currentPosition!.latitude, _currentPosition!.longitude,
        newPos.latitude, newPos.longitude
      );

      if (distance > 5) { // Only update if moved significantly
        setState(() {
          _totalDistance += distance / 1000;
          _currentPosition = newPos;
          _routePoints.add(newPos);
          _updateMarkers();
          _updatePolyline();
        });

        await DriveStateManager.updateDriveState(
          totalDistance: _totalDistance,
          lastLocation: newPos,
        );
        
        _mapController?.animateCamera(CameraUpdate.newLatLng(newPos));
      }
    }
  }

  void _updateMarkers() {
    if (_currentPosition == null) return;

    _truckMarker = Marker(
      markerId: const MarkerId('truck'),
      position: _currentPosition!,
      icon: _customTruckIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
      rotation: DriveStateManager.lastLocation != null ? 0 : 0, // Could add rotation based on heading
      anchor: const Offset(0.5, 0.5),
      infoWindow: const InfoWindow(title: "Truck Location"),
    );

    // Using a sample destination (Andheri if current is Mumbai)
    _destinationMarker = Marker(
      markerId: const MarkerId('destination'),
      position: const LatLng(19.1136, 72.8697), 
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow: const InfoWindow(title: "Destination"),
    );
  }

  void _updatePolyline() {
    _routePolyline = Polyline(
      polylineId: const PolylineId('route'),
      points: _routePoints,
      color: NexusTheme.emerald600,
      width: 5,
      geodesic: true,
    );
  }

  @override
  void dispose() {
    _bgService.stopTracking();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NexusTheme.slate50,
      appBar: AppBar(
        title: Text('LIVE TRACKING: ${widget.order.id}'),
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _initializeTracking(),
          )
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      )
                    ],
                    border: Border.all(color: NexusTheme.slate200, width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(26),
                    child: GoogleMap(
                      onMapCreated: (controller) => _mapController = controller,
                      initialCameraPosition: CameraPosition(
                        target: _currentPosition ?? const LatLng(19.0760, 72.8777),
                        zoom: 15,
                      ),
                      markers: {
                        if (_truckMarker != null) _truckMarker!,
                        if (_destinationMarker != null) _destinationMarker!,
                      },
                      polylines: {
                        if (_routePolyline != null) _routePolyline!,
                      },
                      myLocationButtonEnabled: false,
                      mapToolbarEnabled: false,
                    ),
                  ),
                ),
              ),
              _buildBottomPanel(),
            ],
          ),
    );
  }

  Widget _buildBottomPanel() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, -5),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem("DISTANCE", "${_totalDistance.toStringAsFixed(2)} KM", FontAwesomeIcons.route),
              _buildStatItem("EST. TIME", _estimatedTime, FontAwesomeIcons.clock),
            ],
          ),
          const SizedBox(height: 24),
          LinearPercentIndicator(
            lineHeight: 8,
            percent: 0.6, // Sample progress
            backgroundColor: NexusTheme.slate100,
            progressColor: NexusTheme.emerald500,
            barRadius: const Radius.circular(10),
            padding: EdgeInsets.zero,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const CircleAvatar(
                radius: 28,
                backgroundColor: NexusTheme.slate100,
                child: Icon(Icons.person, color: NexusTheme.slate400, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.order.customerName.toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: NexusTheme.slate900),
                    ),
                    const Text('Vehicle: MH-01-AX-4521', style: TextStyle(color: NexusTheme.slate500, fontSize: 13, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: NexusTheme.emerald600,
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
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: NexusTheme.emerald50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: NexusTheme.emerald600, size: 18),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: NexusTheme.slate400, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
            Text(value, style: const TextStyle(color: NexusTheme.slate900, fontSize: 16, fontWeight: FontWeight.w900)),
          ],
        ),
      ],
    );
  }
}
