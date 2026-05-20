import 'package:flutter/material.dart';

import '../core/router/app_router.dart';
import '../services/export_service.dart';
import '../widgets/sio_bottom_nav.dart';

class ExportReportsScreen extends StatefulWidget {
  const ExportReportsScreen({super.key});

  @override
  State<ExportReportsScreen> createState() => _ExportReportsScreenState();
}

class _ExportReportsScreenState extends State<ExportReportsScreen> {
  bool loading = false;

  Future<void> _exportReport({
    required String collectionName,
    required String reportTitle,
    required List<String> headers,
    required List<List<dynamic>> Function(List docs) mapper,
    required ExportFormat format,
  }) async {
    setState(() => loading = true);

    try {
      await ExportService.exportCollection(
        collectionName: collectionName,
        reportTitle: reportTitle,
        headers: headers,
        mapper: (docs) => mapper(docs),
        format: format,
      );

      if (!mounted) return;

      _showSnack(
        'Reporte exportado correctamente',
        success: true,
      );
    } catch (e) {
      if (!mounted) return;

      _showSnack(
        'No se pudo exportar el reporte',
        success: false,
      );
    }

    if (mounted) {
      setState(() => loading = false);
    }
  }

  void _showSnack(String message, {required bool success}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor:
            success ? const Color(0xFF16A085) : Colors.redAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Row(
          children: [
            Icon(
              success ? Icons.check_circle_rounded : Icons.error_rounded,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openFormatSelector({
    required String title,
    required String collectionName,
    required List<String> headers,
    required List<List<dynamic>> Function(List docs) mapper,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111827),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const SizedBox(height: 22),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Elegí el formato del reporte que querés compartir.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white54,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 22),
              _formatButton(
                icon: Icons.table_chart_rounded,
                title: 'Exportar CSV',
                subtitle: 'Archivo liviano compatible con Excel',
                color: const Color(0xFF16A085),
                onTap: () {
                  Navigator.pop(context);
                  _exportReport(
                    collectionName: collectionName,
                    reportTitle: title,
                    headers: headers,
                    mapper: mapper,
                    format: ExportFormat.csv,
                  );
                },
              ),
              _formatButton(
                icon: Icons.grid_on_rounded,
                title: 'Exportar XLSX',
                subtitle: 'Planilla Excel con estructura profesional',
                color: const Color(0xFFFFC857),
                onTap: () {
                  Navigator.pop(context);
                  _exportReport(
                    collectionName: collectionName,
                    reportTitle: title,
                    headers: headers,
                    mapper: mapper,
                    format: ExportFormat.xlsx,
                  );
                },
              ),
              _formatButton(
                icon: Icons.picture_as_pdf_rounded,
                title: 'Exportar PDF',
                subtitle: 'Reporte listo para presentar o enviar',
                color: const Color(0xFFFF5C70),
                onTap: () {
                  Navigator.pop(context);
                  _exportReport(
                    collectionName: collectionName,
                    reportTitle: title,
                    headers: headers,
                    mapper: mapper,
                    format: ExportFormat.pdf,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _formatButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: loading ? null : onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.32)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.white38,
            ),
          ],
        ),
      ),
    );
  }

  Widget _reportCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: loading ? null : onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12.5,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.file_download_rounded,
              color: Colors.white38,
            ),
          ],
        ),
      ),
    );
  }

  List<List<dynamic>> _mapProducts(List docs) {
    return docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;

      return [
        data['barcode'] ?? '',
        data['name'] ?? '',
        data['conversionFactor'] ?? 0,
        data['currentStock'] ?? 0,
        ExportService.formatTimestamp(data['createdAt']),
        ExportService.formatTimestamp(data['updatedAt']),
      ];
    }).toList();
  }

  List<List<dynamic>> _mapReceptions(List docs) {
    return docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;

      return [
        data['barcode'] ?? '',
        data['productName'] ?? '',
        data['conversionFactor'] ?? 0,
        data['receivedQuantity'] ?? 0,
        data['totalUnits'] ?? 0,
        data['previousStock'] ?? '',
        data['newStock'] ?? '',
        data['receivedByEmail'] ?? '',
        ExportService.formatTimestamp(data['createdAt']),
      ];
    }).toList();
  }

  List<List<dynamic>> _mapAudits(List docs) {
    return docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;

      return [
        data['barcode'] ?? '',
        data['productName'] ?? '',
        data['expectedStock'] ?? 0,
        data['realStock'] ?? 0,
        data['difference'] ?? 0,
        data['auditedByEmail'] ?? '',
        ExportService.formatTimestamp(data['createdAt']),
      ];
    }).toList();
  }

  List<List<dynamic>> _mapAlerts(List docs) {
    return docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;

      return [
        data['type'] ?? '',
        data['title'] ?? '',
        data['message'] ?? '',
        data['barcode'] ?? '',
        data['productName'] ?? '',
        data['difference'] ?? '',
        data['read'] == true ? 'Leída' : 'Pendiente',
        ExportService.formatTimestamp(data['createdAt']),
      ];
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF071827),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111827),
        title: const Text('Exportar reportes'),
      ),
      bottomNavigationBar: const SioBottomNav(
        currentRoute: AppRouter.home,
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(18),
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF16396E),
                      Color(0xFF071827),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(color: Colors.white10),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.file_download_rounded,
                      color: Colors.white,
                      size: 38,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Centro de reportes',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Exportá información operativa en CSV, Excel o PDF para análisis, respaldo o presentación.',
                      style: TextStyle(
                        color: Colors.white70,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              _reportCard(
                icon: Icons.inventory_2_rounded,
                title: 'Productos',
                subtitle: 'Stock actual, código de barras y unidades por caja.',
                color: const Color(0xFF16A085),
                onTap: () {
                  _openFormatSelector(
                    title: 'Reporte de productos',
                    collectionName: 'products',
                    headers: const [
                      'Código',
                      'Producto',
                      'Unidades por caja',
                      'Stock actual',
                      'Creado',
                      'Actualizado',
                    ],
                    mapper: _mapProducts,
                  );
                },
              ),
              _reportCard(
                icon: Icons.local_shipping_rounded,
                title: 'Recepciones',
                subtitle:
                    'Historial de ingresos, operador, cantidades y stock resultante.',
                color: const Color(0xFF4F7BFF),
                onTap: () {
                  _openFormatSelector(
                    title: 'Reporte de recepciones',
                    collectionName: 'receptions',
                    headers: const [
                      'Código',
                      'Producto',
                      'Unidades por caja',
                      'Cantidad recibida',
                      'Total unidades',
                      'Stock anterior',
                      'Stock nuevo',
                      'Operador',
                      'Fecha',
                    ],
                    mapper: _mapReceptions,
                  );
                },
              ),
              _reportCard(
                icon: Icons.fact_check_rounded,
                title: 'Auditorías',
                subtitle:
                    'Comparación entre stock esperado, stock real y diferencias.',
                color: const Color(0xFF8B5CF6),
                onTap: () {
                  _openFormatSelector(
                    title: 'Reporte de auditorías',
                    collectionName: 'audits',
                    headers: const [
                      'Código',
                      'Producto',
                      'Stock esperado',
                      'Stock real',
                      'Diferencia',
                      'Auditor',
                      'Fecha',
                    ],
                    mapper: _mapAudits,
                  );
                },
              ),
              _reportCard(
                icon: Icons.warning_amber_rounded,
                title: 'Alertas',
                subtitle:
                    'Eventos críticos generados por diferencias, stock bajo o cargas anormales.',
                color: const Color(0xFFFF5C70),
                onTap: () {
                  _openFormatSelector(
                    title: 'Reporte de alertas',
                    collectionName: 'alerts',
                    headers: const [
                      'Tipo',
                      'Título',
                      'Mensaje',
                      'Código',
                      'Producto',
                      'Diferencia',
                      'Estado',
                      'Fecha',
                    ],
                    mapper: _mapAlerts,
                  );
                },
              ),
            ],
          ),
          if (loading)
            Container(
              color: Colors.black.withOpacity(0.45),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}