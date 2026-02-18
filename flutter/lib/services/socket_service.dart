import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/material.dart';
import '../config/api_config.dart';

class SocketService {
  static String get _socketUrl => ApiConfig.socketUrl;

  IO.Socket? _socket;
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  // Callbacks
  Function(Map<String, dynamic>)? onOrderCreated;
  Function(Map<String, dynamic>)? onOrderUpdated;
  Function(Map<String, dynamic>)? onOrderStatusChanged;

  /// Connect to WebSocket with JWT token
  void connect(String token) {
    _socket = IO.io(_socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'auth': {'token': token},
    });

    _socket!.connect();

    _socket!.on('connect', (_) {
      _isConnected = true;
      debugPrint('🔌 WebSocket connected');
    });

    _socket!.on('disconnect', (_) {
      _isConnected = false;
      debugPrint('🔌 WebSocket disconnected');
    });

    // Listen to events
    _socket!.on('order:created', (data) {
      debugPrint('📦 New order created: $data');
      onOrderCreated?.call(data as Map<String, dynamic>);
    });

    _socket!.on('order:updated', (data) {
      debugPrint('📦 Order updated: $data');
      onOrderUpdated?.call(data as Map<String, dynamic>);
    });

    _socket!.on('order:status-changed', (data) {
      debugPrint('📦 Order status changed: $data');
      onOrderStatusChanged?.call(data as Map<String, dynamic>);
    });
  }

  /// Disconnect from WebSocket
  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _isConnected = false;
    debugPrint('🔌 WebSocket service disposed');
  }

  /// Emit event
  void emit(String event, dynamic data) {
    if (_isConnected) {
      _socket?.emit(event, data);
    }
  }
}
