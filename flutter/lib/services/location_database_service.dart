import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sqflite/sqflite.dart';

class LocationDatabase {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await openDatabase(
      'tracking.db',
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE location_points('
          'id INTEGER PRIMARY KEY AUTOINCREMENT, '
          'drive_id TEXT, '
          'latitude REAL, '
          'longitude REAL, '
          'accuracy REAL, '
          'speed REAL, '
          'timestamp INTEGER, '
          'synced INTEGER DEFAULT 0'
          ')',
        );
      },
    );
    return _database!;
  }

  Future<void> savePoint(String driveId, Position position) async {
    final db = await database;
    await db.insert('location_points', {
      'drive_id': driveId,
      'latitude': position.latitude,
      'longitude': position.longitude,
      'accuracy': position.accuracy,
      'speed': position.speed,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'synced': 0,
    });
  }

  Future<List<LatLng>> getRoutePoints(String driveId) async {
    final db = await database;
    final results = await db.query(
      'location_points',
      where: 'drive_id = ?',
      whereArgs: [driveId],
      orderBy: 'timestamp ASC',
    );

    return results
        .map(
          (row) =>
              LatLng(row['latitude'] as double, row['longitude'] as double),
        )
        .toList();
  }

  Future<void> markAsSynced(String driveId) async {
    final db = await database;
    await db.update(
      'location_points',
      {'synced': 1},
      where: 'drive_id = ? AND synced = ?',
      whereArgs: [driveId, 0],
    );
  }

  Future<void> clearDrive(String driveId) async {
    final db = await database;
    await db.delete(
      'location_points',
      where: 'drive_id = ?',
      whereArgs: [driveId],
    );
  }
}
