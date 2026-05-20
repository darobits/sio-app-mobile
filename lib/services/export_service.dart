import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

class ExportService {
  ExportService._();

  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<void> exportCollection({
    required String collectionName,
    required String reportTitle,
    required List<String> headers,
    required List<List<dynamic>> Function(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
    ) mapper,
    required ExportFormat format,
  }) async {
    final snapshot = await _db.collection(collectionName).get();
    final rows = mapper(snapshot.docs);

    switch (format) {
      case ExportFormat.csv:
        await _exportCsv(
          fileName: reportTitle,
          headers: headers,
          rows: rows,
        );
        break;

      case ExportFormat.xlsx:
        await _exportXlsx(
          fileName: reportTitle,
          headers: headers,
          rows: rows,
        );
        break;

      case ExportFormat.pdf:
        await _exportPdf(
          fileName: reportTitle,
          title: reportTitle,
          headers: headers,
          rows: rows,
        );
        break;
    }
  }

  static Future<void> _exportCsv({
    required String fileName,
    required List<String> headers,
    required List<List<dynamic>> rows,
  }) async {
    final List<List<dynamic>> data = [
      headers,
      ...rows.map(
        (row) => row.map((value) => value?.toString() ?? '').toList(),
      ),
    ];

    final String csvData = csv.encode(data);

    final file = await _createFile('$fileName.csv');
    await file.writeAsString(csvData);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        text: 'Reporte CSV generado desde SIO',
      ),
    );
  }

  static Future<void> _exportXlsx({
    required String fileName,
    required List<String> headers,
    required List<List<dynamic>> rows,
  }) async {
    final excel = Excel.createExcel();
    final sheet = excel['Reporte'];

    sheet.appendRow(
      headers.map((value) => TextCellValue(value)).toList(),
    );

    for (final row in rows) {
      sheet.appendRow(
        row.map((value) => TextCellValue(value?.toString() ?? '')).toList(),
      );
    }

    final bytes = excel.encode();

    if (bytes == null) {
      throw Exception('No se pudo generar el archivo XLSX');
    }

    final file = await _createFile('$fileName.xlsx');
    await file.writeAsBytes(bytes);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        text: 'Reporte XLSX generado desde SIO',
      ),
    );
  }

  static Future<void> _exportPdf({
    required String fileName,
    required String title,
    required List<String> headers,
    required List<List<dynamic>> rows,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (_) => [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 22,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 16),
          pw.TableHelper.fromTextArray(
            headers: headers,
            data: rows.map((row) {
              return row.map((value) => value?.toString() ?? '').toList();
            }).toList(),
            cellStyle: const pw.TextStyle(fontSize: 9),
            headerStyle: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );

    final file = await _createFile('$fileName.pdf');
    await file.writeAsBytes(await pdf.save());

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        text: 'Reporte PDF generado desde SIO',
      ),
    );
  }

  static Future<File> _createFile(String fileName) async {
    final dir = await getTemporaryDirectory();

    final safeName = fileName
        .replaceAll(' ', '_')
        .replaceAll('/', '-')
        .replaceAll(':', '-')
        .toLowerCase();

    return File('${dir.path}/$safeName');
  }

  static String formatTimestamp(dynamic value) {
    if (value is Timestamp) {
      final date = value.toDate();

      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final year = date.year.toString();
      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');

      return '$day/$month/$year $hour:$minute';
    }

    return '';
  }
}

enum ExportFormat {
  csv,
  xlsx,
  pdf,
}