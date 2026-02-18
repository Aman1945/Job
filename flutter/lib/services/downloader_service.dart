import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

/// Simple, reliable file downloader using dart:io + http package.
/// No flutter_downloader plugin needed — avoids all callback/isolate issues.
class DownloaderService {
  static final DownloaderService _instance = DownloaderService._internal();
  factory DownloaderService() => _instance;
  DownloaderService._internal();

  // Called from main.dart — no-op now since we don't use flutter_downloader
  Future<void> initialize({Function? callback}) async {}

  Future<String?> downloadFile({
    required String url,
    required String fileName,
    BuildContext? context,
  }) async {
    try {
      // Get the downloads directory
      String? savedDir;
      if (Platform.isAndroid) {
        final externalDirs = await getExternalStorageDirectories(
          type: StorageDirectory.downloads,
        );
        if (externalDirs != null && externalDirs.isNotEmpty) {
          savedDir = externalDirs.first.path;
        } else {
          final externalDir = await getExternalStorageDirectory();
          savedDir = externalDir?.path;
        }
      } else {
        final downloadDir = await getApplicationDocumentsDirectory();
        savedDir = downloadDir.path;
      }

      if (savedDir == null) {
        print('❌ Storage directory not found');
        return null;
      }

      // Ensure directory exists
      final dir = Directory(savedDir);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      final filePath = '$savedDir/$fileName';
      print('📥 Downloading: $fileName to $filePath');

      // Download the file
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 30),
      );

      if (response.statusCode == 200) {
        // Write to file
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        print('✅ Download complete: $filePath');

        // Open the file
        final result = await OpenFile.open(filePath);
        print('📂 Open result: ${result.message}');

        return filePath;
      } else {
        print('❌ Download failed: HTTP ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Download error: $e');
      return null;
    }
  }
}
