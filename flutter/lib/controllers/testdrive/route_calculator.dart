import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math' as math;

class RouteCalculator {
  // All external SmartAssist APIs removed. 
  // Calculating distance and duration locally using Haversine formula.

  Future<Map<String, dynamic>> calculateRouteFromPoints(List<LatLng> points) async {
    if (points.isEmpty) throw Exception('No points provided');
    if (points.length == 1) {
      return {'distance': 0.0, 'duration': 0.0};
    }

    try {
      return _calculateLocalRoute(points);
    } catch (e) {
      print('Error in route calculation: $e');
      return {'distance': 0.0, 'duration': 0.0};
    }
  }

  Map<String, dynamic> _calculateLocalRoute(List<LatLng> points) {
    double totalDistance = 0.0;
    for (int i = 0; i < points.length - 1; i++) {
      totalDistance += _calculateDistance(points[i], points[i + 1]);
    }
    
    // Convert to Kilometers
    double distanceKm = totalDistance / 1000.0;
    
    // Estimate duration: assume average speed of 30 km/h (0.5 km per minute)
    double durationMin = distanceKm * 2.0; 

    return {
      'distance': distanceKm,
      'duration': durationMin,
    };
  }

  double _calculateDistance(LatLng start, LatLng end) {
    const earthRadius = 6371000.0; // in meters
    final lat1 = start.latitude * math.pi / 180;
    final lat2 = end.latitude * math.pi / 180;
    final deltaLat = (end.latitude - start.latitude) * math.pi / 180;
    final deltaLng = (end.longitude - start.longitude) * math.pi / 180;

    final a = math.sin(deltaLat / 2) * math.sin(deltaLat / 2) +
        math.cos(lat1) * math.cos(lat2) * math.sin(deltaLng / 2) * math.sin(deltaLng / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }
}
