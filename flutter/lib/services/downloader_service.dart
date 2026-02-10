import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'notification_service.dart';

class DownloaderService {
  static final DownloaderService _instance = DownloaderService._internal();
  factory DownloaderService() => _instance;
  DownloaderService._internal();

  final ReceivePort _port = ReceivePort();
  final Map<String, String> _downloadTasks = {}; // taskId -> fileName

  Future<void> initialize() async {
    if (!Platform.isAndroid && !Platform.isIOS) return;
    
    await FlutterDownloader.initialize(debug: true, ignoreSsl: true);
    
    IsolateNameServer.removePortNameMapping('downloader_port');
    IsolateNameServer.registerPortWithName(_port.sendPort, 'downloader_port');
    
    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = DownloadTaskStatus.values[data[1]];
      int progress = data[2];
      
      final fileName = _downloadTasks[id];
      if (fileName != null) {
        _handleDownloadUpdate(id, status, progress, fileName);
      }
    });

    FlutterDownloader.registerCallback(downloadCallback);
  }

  void _handleDownloadUpdate(String id, DownloadTaskStatus status, int progress, String fileName) {
    print('Download Update - File: $fileName, Status: $status, Progress: $progress%');
    
    switch (status) {
      case DownloadTaskStatus.running:
        NotificationService().updateDownloadProgress(fileName, progress);
        break;
      case DownloadTaskStatus.complete:
        NotificationService().showDownloadComplete(fileName, 'Download/$fileName');
        _downloadTasks.remove(id);
        break;
      case DownloadTaskStatus.failed:
        NotificationService().showDownloadFailed(fileName, 'Download failed');
        _downloadTasks.remove(id);
        break;
      case DownloadTaskStatus.canceled:
        NotificationService().showDownloadFailed(fileName, 'Download canceled');
        _downloadTasks.remove(id);
        break;
      default:
        break;
    }
  }

  @pragma('vm:entry-point')
  static void downloadCallback(String id, int status, int progress) {
    final SendPort? send = IsolateNameServer.lookupPortByName('downloader_port');
    send?.send([id, status, progress]);
  }

  Future<String?> downloadFile({
    required String url,
    required String fileName,
  }) async {
    try {
      // Check and request permissions
      if (Platform.isAndroid) {
        final androidInfo = await Permission.storage.request();
        if (androidInfo != PermissionStatus.granted) {
          await Permission.notification.request();
          await Permission.manageExternalStorage.request();
        }
      }

      String? savedDir;
      if (Platform.isAndroid) {
        // Try to use Downloads folder
        savedDir = '/storage/emulated/0/Download';
        final dir = Directory(savedDir);
        if (!await dir.exists()) {
          final externalDir = await getExternalStorageDirectory();
          savedDir = externalDir?.path;
        }
      } else {
        final downloadDir = await getApplicationDocumentsDirectory();
        savedDir = downloadDir.path;
      }

      if (savedDir == null) {
        NotificationService().showDownloadFailed(fileName, 'Storage not available');
        return null;
      }

      // Show initial notification
      await NotificationService().showDownloadStarted(fileName);

      final taskId = await FlutterDownloader.enqueue(
        url: url,
        savedDir: savedDir,
        fileName: fileName,
        showNotification: false, // We handle notifications ourselves
        openFileFromNotification: false,
        saveInPublicStorage: true,
      );

      if (taskId != null) {
        _downloadTasks[taskId] = fileName;
        print('Download started: $fileName (Task ID: $taskId)');
        return taskId;
      } else {
        NotificationService().showDownloadFailed(fileName, 'Failed to start download');
        return null;
      }
    } catch (e) {
      print('Download error: $e');
      NotificationService().showDownloadFailed(fileName, e.toString());
      return null;
    }
  }

  Future<void> cancelDownload(String taskId) async {
    await FlutterDownloader.cancel(taskId: taskId);
  }

  Future<void> retryDownload(String taskId) async {
    await FlutterDownloader.retry(taskId: taskId);
  }

  Future<List<DownloadTask>> getAllDownloads() async {
    final tasks = await FlutterDownloader.loadTasks();
    return tasks ?? [];
  }
}
