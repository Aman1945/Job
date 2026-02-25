import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import '../config/api_config.dart';

/// Shared helpers for Master Data screens (Add / Import / Export)
class MasterActions {
  static final Dio _dio = Dio(BaseOptions(baseUrl: ApiConfig.baseUrl));

  // ───────────────────────────── SNACKBARS ─────────────────────────────

  static void showSuccess(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
        const SizedBox(width: 10),
        Flexible(child: Text(msg, style: const TextStyle(fontWeight: FontWeight.w600))),
      ]),
      backgroundColor: const Color(0xFF059669),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  static void showError(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.error_outline, color: Colors.white, size: 18),
        const SizedBox(width: 10),
        Flexible(child: Text(msg, style: const TextStyle(fontWeight: FontWeight.w600))),
      ]),
      backgroundColor: const Color(0xFFDC2626),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  // ───────────────────────────── IMPORT ────────────────────────────────

  /// Pick an Excel file and POST it to [uploadRoute].
  /// Calls [onSuccess] with the response message on success.
  static Future<void> importExcel({
    required BuildContext context,
    required String uploadRoute,   // e.g. '/products/bulk-import'
    required VoidCallback onSuccess,
  }) async {
    // 1. Pick file
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls', 'csv'],
      withData: false,
      withReadStream: false,
    );
    if (result == null || result.files.single.path == null) return;

    final filePath = result.files.single.path!;
    if (!context.mounted) return;

    // 2. Show uploading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              CircularProgressIndicator(),
              SizedBox(height: 14),
              Text('Importing...', style: TextStyle(fontWeight: FontWeight.w700)),
            ]),
          ),
        ),
      ),
    );

    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: filePath.split(Platform.pathSeparator).last),
      });
      final response = await _dio.post(uploadRoute, data: formData);

      if (context.mounted) Navigator.pop(context); // close loader
      if (response.statusCode == 200) {
        final msg = response.data['message'] ?? 'Import successful';
        if (context.mounted) showSuccess(context, msg);
        onSuccess();
      }
    } on DioException catch (e) {
      if (context.mounted) Navigator.pop(context);
      final msg = e.response?.data?['message'] ?? e.message ?? 'Import failed';
      if (context.mounted) showError(context, msg.toString());
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      if (context.mounted) showError(context, 'Unexpected error: $e');
    }
  }

  // ───────────────────────────── EXPORT / TEMPLATE ─────────────────────

  /// Download an Excel template or export from [templateRoute].
  static Future<void> downloadTemplate({
    required BuildContext context,
    required String templateRoute,     // e.g. '/products/import-template'
    required String fileName,          // e.g. 'Material_Master_Template.xlsx'
  }) async {
    // Let the user pick where to save
    final savePath = await FilePicker.platform.saveFile(
      dialogTitle: 'Save template as',
      fileName: fileName,
      allowedExtensions: ['xlsx'],
      type: FileType.custom,
    );
    if (savePath == null) return;
    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              CircularProgressIndicator(),
              SizedBox(height: 14),
              Text('Downloading...', style: TextStyle(fontWeight: FontWeight.w700)),
            ]),
          ),
        ),
      ),
    );

    try {
      await _dio.download(
        templateRoute,
        savePath,
        options: Options(responseType: ResponseType.bytes),
      );
      if (context.mounted) Navigator.pop(context);
      if (context.mounted) showSuccess(context, 'Saved to $savePath');
    } on DioException catch (e) {
      if (context.mounted) Navigator.pop(context);
      if (context.mounted) showError(context, e.message ?? 'Download failed');
    }
  }

  // ───────────────────────────── POST single record ────────────────────

  static Future<bool> postRecord({
    required BuildContext context,
    required String route,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _dio.post(route,
        data: data,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      }
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'Error saving';
      if (context.mounted) showError(context, msg.toString());
    }
    return false;
  }

  // ───────────────────────────── ACTION BUTTONS BAR ─────────────────────

  /// Standard 3-button action bar (Add, Import, Export Template) for master screens
  static Widget actionBar({
    required BuildContext context,
    required VoidCallback onAdd,
    required VoidCallback onImport,
    required VoidCallback onExport,
  }) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          _actionBtn(label: '+ ADD NEW', color: const Color(0xFF0F172A), icon: Icons.add, onTap: onAdd),
          const SizedBox(width: 8),
          _actionBtn(label: 'IMPORT EXCEL', color: const Color(0xFF0369A1), icon: Icons.upload_file_outlined, onTap: onImport),
          const SizedBox(width: 8),
          _actionBtn(label: 'TEMPLATE', color: const Color(0xFF059669), icon: Icons.download_outlined, onTap: onExport),
        ],
      ),
    );
  }

  static Widget _actionBtn({required String label, required Color color, required IconData icon, required VoidCallback onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: Colors.white),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5)),
            ],
          ),
        ),
      ),
    );
  }
}
