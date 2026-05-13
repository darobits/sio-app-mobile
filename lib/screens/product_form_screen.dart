import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProductFormScreen extends StatefulWidget {
  final String barcode;

  const ProductFormScreen({
    super.key,
    required this.barcode,
  });

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final nameCtrl = TextEditingController();
  final conversionFactorCtrl = TextEditingController(text: '1');
  final receivedQuantityCtrl = TextEditingController(text: '1');

  bool loading = false;

  Future<void> saveProduct() async {
    final name = nameCtrl.text.trim();
    final conversionFactor =
        int.tryParse(conversionFactorCtrl.text.trim()) ?? 0;
    final receivedQuantity =
        int.tryParse(receivedQuantityCtrl.text.trim()) ?? 0;

    final errors = <String>[];

    if (name.isEmpty) {
      errors.add('• Ingresá el nombre del producto');
    }

    if (conversionFactor <= 0) {
      errors.add('• La cantidad por caja debe ser mayor a 0');
    }

    if (receivedQuantity <= 0) {
      errors.add('• La cantidad recibida debe ser mayor a 0');
    }

    if (errors.isNotEmpty) {
      showResultDialog(
        title: 'Revisá los datos',
        message: errors.join('\n'),
        success: false,
      );
      return;
    }

    setState(() => loading = true);

    try {
      final totalUnits = conversionFactor * receivedQuantity;
      final currentUser = FirebaseAuth.instance.currentUser;

      final db = FirebaseFirestore.instance;

      final productRef = db.collection('products').doc(widget.barcode);
      final productSnapshot = await productRef.get();

      final batch = db.batch();

      if (productSnapshot.exists) {
        batch.update(productRef, {
          'name': name,
          'conversionFactor': conversionFactor,
          'currentStock': FieldValue.increment(totalUnits),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        batch.set(productRef, {
          'barcode': widget.barcode,
          'name': name,
          'conversionFactor': conversionFactor,
          'currentStock': totalUnits,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      final receptionRef = db.collection('receptions').doc();

      batch.set(receptionRef, {
        'barcode': widget.barcode,
        'productName': name,
        'conversionFactor': conversionFactor,
        'receivedQuantity': receivedQuantity,
        'totalUnits': totalUnits,
        'receivedByUid': currentUser?.uid,
        'receivedByEmail': currentUser?.email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      if (!mounted) return;

      setState(() => loading = false);

      showResultDialog(
        title: 'Producto guardado',
        message:
            '$name\n\nCódigo: ${widget.barcode}\nStock recibido: $totalUnits unidades\nOperador: ${currentUser?.email ?? "Sin usuario"}',
        success: true,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => loading = false);

      showResultDialog(
        title: 'Error',
        message: 'No se pudo guardar el producto.\n\nIntentá nuevamente.',
        success: false,
      );
    }
  }

  void showResultDialog({
    required String title,
    required String message,
    required bool success,
  }) {
    showDialog(
      context: context,
      barrierDismissible: !success,
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
                  color: success
                      ? Colors.green.withOpacity(0.15)
                      : Colors.red.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  success ? Icons.check_rounded : Icons.close_rounded,
                  color: success ? Colors.green : Colors.red,
                  size: 42,
                ),
              ),
              const SizedBox(height: 20),
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
                  onPressed: () {
                    Navigator.pop(context);

                    if (success) {
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A085),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(success ? 'Volver a recepción' : 'Entendido'),
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
    nameCtrl.dispose();
    conversionFactorCtrl.dispose();
    receivedQuantityCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF071827),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111827),
        title: const Text('Alta de producto'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Código escaneado',
                style: TextStyle(color: Colors.white60),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF111827),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF22C55E)),
                ),
                child: Text(
                  widget.barcode,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Datos del producto',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Ej: Tornillos autoperforantes 6x1',
                  prefixIcon: const Icon(Icons.inventory_2_rounded),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: conversionFactorCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Cantidad por caja / paquete',
                  prefixIcon: const Icon(Icons.all_inbox_rounded),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: receivedQuantityCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Cantidad recibida',
                  prefixIcon: const Icon(Icons.add_box_rounded),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: loading ? null : saveProduct,
                  icon: loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.save_rounded),
                  label: Text(loading ? 'Guardando...' : 'Guardar producto'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A085),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
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