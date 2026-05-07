import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class RecepcionScreen extends StatefulWidget {
  const RecepcionScreen({super.key});

  @override
  State<RecepcionScreen> createState() => _RecepcionScreenState();
}

class _RecepcionScreenState extends State<RecepcionScreen> {

  final MobileScannerController controller = MobileScannerController();

  String? lastCode;
  bool scanning = true;

  void onDetect(BarcodeCapture capture) {
    if (!scanning) return;

    final barcode = capture.barcodes.first.rawValue;
    if (barcode == null) return;

    setState(() {
      scanning = false;
      lastCode = barcode;
    });

    Future.delayed(const Duration(seconds: 1), () {
      setState(() => scanning = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Recepción")),

      body: Column(
        children: [

          SizedBox(
            height: 300,
            child: MobileScanner(
              controller: controller,
              onDetect: onDetect,
            ),
          ),

          const SizedBox(height: 20),

          Text(
            lastCode ?? "Escaneá un producto",
            style: const TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}