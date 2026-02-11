import 'dart:io';
import 'package:excel/excel.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import '../models/models.dart';
import 'package:intl/intl.dart';

class ReportExporter {
  // Export to Excel
  static Future<void> exportToExcel({
    required List<Order> orders,
    required String reportType,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Report'];

      // Add Header with styling
      sheet.appendRow([
        TextCellValue('NexusOMS - $reportType'),
      ]);
      sheet.appendRow([
        TextCellValue('Period: ${DateFormat('dd MMM yyyy').format(startDate)} - ${DateFormat('dd MMM yyyy').format(endDate)}'),
      ]);
      sheet.appendRow([]); // Empty row

      // Column Headers
      final headers = [
        'Order ID',
        'Customer Name',
        'Status',
        'Total Amount',
        'Date',
        'Salesperson',
        'Items Count',
      ];

      sheet.appendRow(headers.map((h) => TextCellValue(h)).toList());

      // Add Data Rows
      for (final order in orders) {
        sheet.appendRow([
          TextCellValue(order.id),
          TextCellValue(order.customerName),
          TextCellValue(order.status),
          TextCellValue('₹${order.total.toStringAsFixed(2)}'),
          TextCellValue(DateFormat('dd MMM yyyy').format(order.createdAt)),
          TextCellValue(order.salespersonId ?? 'N/A'),
          IntCellValue(order.items.length),
        ]);
      }

      // Summary Row
      sheet.appendRow([]); // Empty row
      final totalAmount = orders.fold<double>(0, (sum, order) => sum + order.total);
      sheet.appendRow([
        TextCellValue('TOTAL'),
        TextCellValue(''),
        TextCellValue(''),
        TextCellValue('₹${totalAmount.toStringAsFixed(2)}'),
        TextCellValue(''),
        TextCellValue(''),
        IntCellValue(orders.length),
      ]);

      // Save File
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'NexusOMS_${reportType.replaceAll(' ', '_')}_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx';
      final filePath = '${directory.path}/$fileName';

      final fileBytes = excel.encode();
      if (fileBytes != null) {
        File(filePath)
          ..createSync(recursive: true)
          ..writeAsBytesSync(fileBytes);

        // Open the file
        await OpenFile.open(filePath);
      }
    } catch (e) {
      print('Excel export error: $e');
      rethrow;
    }
  }

  // Export to CSV
  static Future<void> exportToCSV({
    required List<Order> orders,
    required String reportType,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      List<List<dynamic>> rows = [];

      // Header
      rows.add(['NexusOMS - $reportType']);
      rows.add(['Period: ${DateFormat('dd MMM yyyy').format(startDate)} - ${DateFormat('dd MMM yyyy').format(endDate)}']);
      rows.add([]); // Empty row

      // Column Headers
      rows.add([
        'Order ID',
        'Customer Name',
        'Status',
        'Total Amount',
        'Date',
        'Salesperson',
        'Items Count',
      ]);

      // Data Rows
      for (final order in orders) {
        rows.add([
          order.id,
          order.customerName,
          order.status,
          '₹${order.total.toStringAsFixed(2)}',
          DateFormat('dd MMM yyyy').format(order.createdAt),
          order.salespersonId ?? 'N/A',
          order.items.length,
        ]);
      }

      // Summary
      rows.add([]); // Empty row
      final totalAmount = orders.fold<double>(0, (sum, order) => sum + order.total);
      rows.add([
        'TOTAL',
        '',
        '',
        '₹${totalAmount.toStringAsFixed(2)}',
        '',
        '',
        orders.length,
      ]);

      // Convert to CSV
      String csv = const ListToCsvConverter().convert(rows);

      // Save File
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'NexusOMS_${reportType.replaceAll(' ', '_')}_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv';
      final filePath = '${directory.path}/$fileName';

      File(filePath)
        ..createSync(recursive: true)
        ..writeAsStringSync(csv);

      // Open the file
      await OpenFile.open(filePath);
    } catch (e) {
      print('CSV export error: $e');
      rethrow;
    }
  }

  // Export to PDF (placeholder for future implementation)
  static Future<void> exportToPDF({
    required List<Order> orders,
    required String reportType,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // TODO: Implement PDF export using pdf package
    throw UnimplementedError('PDF export coming soon');
  }
}
