import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../services/location_database_service.dart';

class BackgroundLocationService {
  static final BackgroundLocationService _instance =
      BackgroundLocationService._internal();
  factory BackgroundLocationService() => _instance;
  BackgroundLocationService._internal();

  final FlutterBackgroundService _service = FlutterBackgroundService();
  bool _isInitialized = false;
  bool _isInitializing = false;
  final Completer<bool> _initCompleter = Completer<bool>();
  bool get isInitialized => _isInitialized;

  void sendDriveId(String driveId) {
    _service.invoke('setDriveId', {'driveId': driveId});
  }

  Future<void> _createNotificationChannel() async {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'nexus_tracking',
      'Nexus Live Tracking',
      description: 'Tracks delivery location in real-time',
      importance: Importance.low,
      enableVibration: false,
      playSound: false,
      showBadge: false,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  Future<bool> _ensurePermissions() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return false;
      }

      if (await Permission.notification.isDenied) {
        await Permission.notification.request();
      }

      if (await Permission.locationAlways.isDenied) {
        await Permission.locationAlways.request();
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> initialize() async {
    if (_isInitializing) return await _initCompleter.future;
    if (_isInitialized) return true;

    _isInitializing = true;

    try {
      await _createNotificationChannel();
      final hasPermissions = await _ensurePermissions();
      if (!hasPermissions) {
        throw Exception('Required permissions not granted');
      }

      await _service.configure(
        iosConfiguration: IosConfiguration(
          autoStart: false,
          onForeground: onStart,
          onBackground: onIosBackground,
        ),
        androidConfiguration: AndroidConfiguration(
          onStart: onStart,
          isForegroundMode: true,
          autoStart: false,
          autoStartOnBoot: false,
          notificationChannelId: 'nexus_tracking',
          initialNotificationTitle: 'Nexus Tracking Active',
          initialNotificationContent: 'Initializing location tracking...',
          foregroundServiceNotificationId: 888,
          foregroundServiceTypes: [AndroidForegroundType.location],
        ),
      );

      _isInitialized = true;
      _isInitializing = false;
      _initCompleter.complete(true);
      return true;
    } catch (e) {
      _isInitializing = false;
      _isInitialized = false;
      _initCompleter.complete(false);
      return false;
    }
  }

  Future<bool> startTracking() async {
    try {
      if (!_isInitialized) {
        final initialized = await initialize();
        if (!initialized) return false;
      }

      final isRunning = await _service.isRunning();
      if (isRunning) return true;

      return await _service.startService();
    } catch (e) {
      return false;
    }
  }

  Future<void> stopTracking() async {
    _service.invoke('stopService');
  }

  void listenToUpdates(Function(Map<String, dynamic>) onUpdate) {
    _service.on('location_update').listen((event) {
      if (event != null) {
        onUpdate(event as Map<String, dynamic>);
      }
    });
  }
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  final locationDb = LocationDatabase();
  String? currentDriveId;

  if (service is AndroidServiceInstance) {
    service.setAsForegroundService();
    service.on('setAsBackground').listen((event) => service.setAsBackgroundService());
  }

  service.on('setDriveId').listen((event) {
    if (event != null && event is Map) {
      currentDriveId = event['driveId'] as String?;
    }
  });

  service.on('stopService').listen((event) async {
    service.stopSelf();
  });

  Timer.periodic(const Duration(seconds: 5), (timer) async {
    if (service is AndroidServiceInstance) {
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 10),
        );

        if (currentDriveId != null) {
          await locationDb.savePoint(currentDriveId!, position);
        }

        await service.setForegroundNotificationInfo(
          title: 'Tracking Active',
          content: 'The tracking is in progress and being handled seamlessly in the background.',
        );

        service.invoke('location_update', {
          'latitude': position.latitude,
          'longitude': position.longitude,
          'accuracy': position.accuracy,
          'speed': position.speed,
          'timestamp': DateTime.now().toIso8601String(),
        });
      } catch (e) {
        // Handle error quietly
      }
    }
  });
}
