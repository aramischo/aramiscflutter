import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import '../../../config/app_config.dart';
import '../message/snack_bars.dart';

@pragma('vm:entry-point')
class FileDownloadUtils {
  final ReceivePort _port = ReceivePort();

  FileDownloadUtils() {
    // Remove previous mapping to avoid conflicts
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    IsolateNameServer.registerPortWithName(
      _port.sendPort,
      'downloader_send_port',
    );

    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];

      if (status == DownloadTaskStatus.complete) {
        debugPrint('✅ Download completed for task ID: $id');
      } else {
        debugPrint('⬇️ Download in progress: $progress%');
      }
    });

    FlutterDownloader.registerCallback(downloadCallback);
  }

  /// Download file in app-specific storage (Play Store compliant)
  Future<void> downloadFiles({
    required String url,
    required String title,
  }) async {
    debugPrint('Download URL: $url');

    final directory = await _getDirectoryPath();
    if (directory.isEmpty) {
      showBasicSuccessSnackBar(message: "Failed to get storage directory".tr);
      return;
    }

    final fileName = '$title${AppConfig.getExtension(url)}';
    final filePath = '$directory/$fileName';

    try {
      // Remove any existing tasks for this URL to avoid HTTP 416 (Range Not Satisfiable)
      final tasks = await FlutterDownloader.loadTasksWithRawQuery(
        query: "SELECT * FROM task WHERE url = '$url'",
      );
      if (tasks != null && tasks.isNotEmpty) {
        for (final task in tasks) {
          await FlutterDownloader.cancel(taskId: task.taskId);
          await FlutterDownloader.remove(
              taskId: task.taskId, shouldDeleteContent: false);
        }
      }

      // Delete partial/corrupt file if it exists
      final existingFile = File(filePath);
      if (await existingFile.exists()) {
        await existingFile.delete();
        debugPrint('🗑️ Deleted existing partial file: $filePath');
      }

      final taskId = await FlutterDownloader.enqueue(
        url: url,
        savedDir: directory,
        fileName: fileName,
        showNotification: true,
        openFileFromNotification: true,
        saveInPublicStorage: false, // ✅ Scoped storage
        headers: {HttpHeaders.acceptEncodingHeader: "*"},
      );

      if (taskId != null) {
        showBasicSuccessSnackBar(message: "Download Started".tr);
      }
    } catch (e, t) {
      Get.snackbar(
        'Error!'.tr,
        'No file found on server'.tr,
        colorText: Colors.white,
        backgroundColor: Colors.red,
        snackPosition: SnackPosition.TOP,
        barBlur: 0.5,
      );
      debugPrint(e.toString());
      debugPrint(t.toString());
    }
  }

  /// FlutterDownloader background callback
  @pragma('vm:entry-point')
  static void downloadCallback(String id, int status, int progress) {
    final taskStatus = DownloadTaskStatus.values[status];
    final SendPort? send =
    IsolateNameServer.lookupPortByName('downloader_send_port');
    send?.send([id, taskStatus, progress]);
  }

  /// Get app-specific directory for downloads
  Future<String> _getDirectoryPath() async {
    if (Platform.isAndroid) {
      final sdkVersion = await _getAndroidVersion();
      if (sdkVersion >= 29) {
        // Use scoped storage directories
        final dir = await getDownloadsDirectory();
        if (dir != null) return dir.path;

        final docs = await getApplicationDocumentsDirectory();
        return docs.path;
      } else {
        // Legacy support for Android < 10
        return "/sdcard/Download/";
      }
    } else if (Platform.isIOS) {
      final docs = await getApplicationDocumentsDirectory();
      return docs.path;
    } else {
      final supportDir = await getApplicationSupportDirectory();
      return supportDir.path;
    }
  }

  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }
}

/// Safely get Android SDK version
Future<int> _getAndroidVersion() async {
  final deviceInfo = DeviceInfoPlugin();
  try {
    final androidInfo = await deviceInfo.androidInfo;
    return androidInfo.version.sdkInt;
  } catch (e) {
    debugPrint('Failed to get Android version: $e');
    return 0;
  }
}
