import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';

@pragma('vm:entry-point')
void downloadCallback(String id, int status, int progress) {
  final SendPort? send = IsolateNameServer.lookupPortByName('downloader_port');
  send?.send([id, status, progress]);
}

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
      DownloadTaskStatus status = DownloadTaskStatus.values[data[2] is int ? data[1] : 0]; // Note: data[1] is status
      // Flutter downloader status is int, progress is int
      // Status enum values: undefined(0), enqueued(1), running(2), complete(3), failed(4), canceled(5), paused(6)
      
      final intStatus = data[1] as int;
      final progress = data[2] as int;
      DownloadTaskStatus taskStatus = DownloadTaskStatus.values[intStatus];
      
      final fileName = _downloadTasks[id];
      if (fileName != null) {
        _handleDownloadUpdate(id, taskStatus, progress, fileName);
      }
    });

    FlutterDownloader.registerCallback(downloadCallback);
  }

  void _handleDownloadUpdate(String id, DownloadTaskStatus status, int progress, String fileName) {
    print('Download Update - File: $fileName, Status: $status, Progress: $progress%');
    
    switch (status) {
      case DownloadTaskStatus.running:
        print('Downloading: $fileName - $progress%');
        break;
      case DownloadTaskStatus.complete:
        print('Download Complete: $fileName');
        _downloadTasks.remove(id);
        // Automatically try to open the file upon completion
        _openFileByTaskId(id);
        break;
      case DownloadTaskStatus.failed:
        print('Download Failed: $fileName');
        _downloadTasks.remove(id);
        break;
      case DownloadTaskStatus.canceled:
        print('Download Canceled: $fileName');
        _downloadTasks.remove(id);
        break;
      default:
        break;
    }
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
        // More reliable way to get Download directory on Android
        final externalDirs = await getExternalStorageDirectories(type: StorageDirectory.downloads);
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
        print('Storage directory not found');
        return null;
      }

      final dir = Directory(savedDir);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      print('Starting download: $fileName to $savedDir');

      final taskId = await FlutterDownloader.enqueue(
        url: url,
        savedDir: savedDir,
        fileName: fileName,
        showNotification: true,
        openFileFromNotification: true,
        saveInPublicStorage: true,
      );

      if (taskId != null) {
        _downloadTasks[taskId] = fileName;
        print('Download started: $fileName (Task ID: $taskId)');
        return taskId;
      } else {
        print('Failed to start download');
        return null;
      }
    } catch (e) {
      print('Download error: $e');
      return null;
    }
  }

  Future<void> _openFileByTaskId(String taskId) async {
    final tasks = await FlutterDownloader.loadTasks();
    if (tasks == null) return;

    try {
      final task = tasks.firstWhere((t) => t.taskId == taskId);
      final filePath = "${task.savedDir}${Platform.pathSeparator}${task.filename}";
      final file = File(filePath);
      
      if (await file.exists()) {
        await OpenFile.open(filePath);
      } else {
        print('File not found for opening: $filePath');
      }
    } catch (e) {
      print('Error finding/opening task: $e');
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
