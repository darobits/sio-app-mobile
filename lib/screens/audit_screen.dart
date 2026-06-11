import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../core/router/app_router.dart';
import '../providers/audit_provider.dart';
import '../providers/alert_provider.dart';
import '../services/alert_service.dart';
import '../widgets/sio_bottom_nav.dart';

class AuditScreen extends ConsumerStatefulWidget {
  const AuditScreen({super.key});

  @override
  ConsumerState<AuditScreen> createState() => _AuditScreenState();
}

class _AuditScreenState extends ConsumerState<AuditScreen> {
  final MobileScannerController scannerController = MobileScannerController();
  final realStockCtrl = TextEditingController();

  String? scannedBarcode;
  bool scanning = true;

  Future<void> onDetect(BarcodeCapture capture) async {
    if (!scanning) return;
    if (capture.barcodes.isEmpty) return;

    final barcode = capture.barcodes.first.rawValue;

    if (barcode == null || barcode.trim().isEmpty) return;

    setState(() {
      scanning = false;
      scannedBarcode = barcode.trim();
    });

    await searchProduct(barcode.trim());

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() => scanning = true);
    });
  }

  Future<void> searchProduct(String barcode) async {
    ref.read(auditLoadingProvider.notifier).setLoading(true);

    final repository = ref.read(auditRepositoryProvider);
    final product = await repository.getProductByBarcode(barcode);

    ref.read(auditProductProvider.notifier).setProduct(product);
    ref.read(auditLoadingProvider.notifier).setLoading(false);

    if (product == null && mounted) {
      showProductNotFoundDialog(barcode);
    }
  }

  Future<void> saveAudit() async {
    final product = ref.read(auditProductProvider);
    final realStock = int.tryParse(realStockCtrl.text.trim());

    if (product == null) {
      showMessage('Primero escaneá un producto válido');
      return;
    }

    if (realStock == null || realStock < 0) {
      showMessage('Ingresá un stock real válido');
      return;
    }

    ref.read(auditLoadingProvider.notifier).setLoading(true);

    try {
      final repository = ref.read(auditRepositoryProvider);
      final settings = ref.read(alertSettingsProvider);

      final expectedStock = product.currentStock;
      final difference = realStock - expectedStock;

      await repository.saveAudit(
        product: product,
        realStock: realStock,
      );

      // NOTIFICACIÓN REAL DE SIO:
      // Si la auditoría detecta diferencia, se crea una alerta en Firestore
      // y se muestra una notificación local en el celular.
      if (difference != 0) {
        try {
          await AlertService.checkAuditDifference(
            barcode: product.barcode,
            productName: product.name,
            expectedStock: expectedStock,
            realStock: realStock,
            sendNotification: settings.auditDifferences,
          );

          ref.invalidate(alertsProvider);
        } catch (alertError) {
          if (mounted) {
            showMessage(
              'La auditoría se guardó, pero no se pudo generar la alerta.',
            );
          }
        }
      }

      ref.read(auditProductProvider.notifier).clear();
      realStockCtrl.clear();

      if (!mounted) return;

      showResultDialog(
        title: 'Auditoría guardada',
        message:
            'Producto: ${product.name}\nStock esperado: $expectedStock\nStock real: $realStock\nDiferencia: $difference',
        success: true,
      );
    } catch (e) {
      if (!mounted) return;

      showResultDialog(
        title: 'Error',
        message: 'No se pudo guardar la auditoría',
        success: false,
      );
    }

    ref.read(auditLoadingProvider.notifier).setLoading(false);
  }

  void showProductNotFoundDialog(String barcode) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF121E2D),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.45),
                blurRadius: 28,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  color: Colors.orangeAccent,
                  size: 44,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Producto no encontrado',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'El código $barcode no está registrado.\n\n¿Querés darlo de alta como nueva recepción?',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: const BorderSide(color: Colors.white24),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);

                        Navigator.pushNamed(
                          context,
                          AppRouter.productForm,
                          arguments: barcode,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16A085),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Dar de alta'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(message),
      ),
    );
  }

  void showResultDialog({
    required String title,
    required String message,
    required bool success,
  }) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF121E2D),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                success ? Icons.check_circle_rounded : Icons.error_rounded,
                color: success ? Colors.green : Colors.redAccent,
                size: 52,
              ),
              const SizedBox(height: 18),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Entendido'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    scannerController.dispose();
    realStockCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final product = ref.watch(auditProductProvider);
    final loading = ref.watch(auditLoadingProvider);

    final expectedStock = product?.currentStock ?? 0;
    final realStock = int.tryParse(realStockCtrl.text.trim());
    final difference = realStock == null ? null : realStock - expectedStock;

    return Scaffold(
      backgroundColor: const Color(0xFF071827),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111827),
        title: const Text('Auditoría de stock'),
        actions: [
          IconButton(
            onPressed: () => scannerController.toggleTorch(),
            icon: const Icon(
              Icons.flash_on_rounded,
              color: Color(0xFF22C55E),
            ),
          ),
          IconButton(
            onPressed: () => scannerController.switchCamera(),
            icon: const Icon(Icons.cameraswitch_rounded),
          ),
        ],
      ),
      bottomNavigationBar: const SioBottomNav(
        currentRoute: AppRouter.audit,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 26),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 260,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFF4F7BFF),
                    width: 2,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    MobileScanner(
                      controller: scannerController,
                      onDetect: onDetect,
                    ),
                    Center(
                      child: Container(
                        width: 240,
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: const Color(0xFF4F7BFF),
                            width: 3,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Producto auditado',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF111827),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white10),
                ),
                child: loading
                    ? const Center(child: CircularProgressIndicator())
                    : product == null
                        ? Text(
                            scannedBarcode == null
                                ? 'Escaneá un producto para auditar'
                                : 'Código escaneado: $scannedBarcode\nProducto no encontrado',
                            style: const TextStyle(color: Colors.white70),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Código: ${product.barcode}',
                                style: const TextStyle(color: Colors.white54),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Stock esperado: ${product.currentStock} unidades',
                                style: const TextStyle(
                                  color: Color(0xFF22C55E),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: realStockCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Stock real contado',
                  prefixIcon: const Icon(Icons.fact_check_rounded),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              if (difference != null && product != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: difference == 0
                        ? Colors.green.withOpacity(0.12)
                        : Colors.red.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: difference == 0
                          ? Colors.green.withOpacity(0.4)
                          : Colors.red.withOpacity(0.4),
                    ),
                  ),
                  child: Text(
                    difference == 0
                        ? 'Stock correcto. No hay diferencias.'
                        : 'Diferencia detectada: $difference unidades',
                    style: TextStyle(
                      color: difference == 0
                          ? Colors.greenAccent
                          : Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: loading ? null : saveAudit,
                  icon: const Icon(Icons.save_rounded),
                  label: const Text('Guardar auditoría'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F7BFF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}