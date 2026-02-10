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
    _initializeTracking();
  }

  Future<void> _initializeTracking() async {
    setState(() => _isLoading = true);

    // 1. Check if we have an active drive state to resume
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

    // 2. Start Background Service
    await _bgService.initialize();
    await _bgService.startTracking();
    _bgService.sendDriveId(widget.order.id);
    
    // 3. Listen for updates
    _bgService.listenToUpdates((data) {
      if (mounted) {
        _handleLocationUpdate(data);
      }
    });

    setState(() => _isLoading = false);
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
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
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
