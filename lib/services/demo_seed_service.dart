//esta es una clase de servicio para generar datos de ejemplo en Firestore, útil para demostraciones o pruebas. 
//No es parte del código real. 
//es solo para la muestra.

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DemoSeedService {
  DemoSeedService._();

  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final Random _random = Random(2026);

  static Future<void> seedDemoData() async {
    final user = _auth.currentUser;
    final userEmail = user?.email ?? 'admin@sio.com';
    final userUid = user?.uid;

    final batch = _db.batch();

    final demoUsers = [
      {
        'uid': userUid ?? 'admin-principal',
        'name': user?.displayName ?? 'Admin Principal',
        'email': userEmail,
        'role': 'admin',
        'rol': 'admin',
      },
      {
        'uid': 'demo-operador-001',
        'name': 'Lucas Depósito',
        'email': 'lucas.deposito@sio.com',
        'role': 'operador',
        'rol': 'operador',
      },
      {
        'uid': 'demo-operador-002',
        'name': 'Martina Recepción',
        'email': 'martina.recepcion@sio.com',
        'role': 'operador',
        'rol': 'operador',
      },
      {
        'uid': 'demo-operador-003',
        'name': 'Nicolás Auditoría',
        'email': 'nicolas.auditoria@sio.com',
        'role': 'operador',
        'rol': 'operador',
      },
      {
        'uid': 'demo-admin-002',
        'name': 'Supervisor Stock',
        'email': 'supervisor.stock@sio.com',
        'role': 'admin',
        'rol': 'admin',
      },
      {
        'uid': 'demo-operador-004',
        'name': 'Carla Inventario',
        'email': 'carla.inventario@sio.com',
        'role': 'operador',
        'rol': 'operador',
      },
      {
        'uid': 'demo-operador-005',
        'name': 'Diego Almacén',
        'email': 'diego.almacen@sio.com',
        'role': 'operador',
        'rol': 'operador',
      },
      {
        'uid': 'demo-admin-003',
        'name': 'Jefa Operativa',
        'email': 'jefa.operativa@sio.com',
        'role': 'admin',
        'rol': 'admin',
      },
    ];

    for (final demoUser in demoUsers) {
      final uid = demoUser['uid'] as String;
      final createdAt = _randomHistoricalDate();

      batch.set(
        _db.collection('usuarios').doc(uid),
        {
          ...demoUser,
          'createdAt': Timestamp.fromDate(createdAt),
          'updatedAt': Timestamp.fromDate(_dateAfter(createdAt, maxDays: 90)),
        },
        SetOptions(merge: true),
      );
    }

    final products = _generateHardwareProducts();

    for (final product in products) {
      final barcode = product['barcode'] as String;
      final createdAt = _randomHistoricalDate();

      batch.set(
        _db.collection('products').doc(barcode),
        {
          ...product,
          'createdAt': Timestamp.fromDate(createdAt),
          'updatedAt': Timestamp.fromDate(_dateAfter(createdAt, maxDays: 120)),
        },
        SetOptions(merge: true),
      );
    }

    final receptions = _generateReceptions(products, demoUsers);

    for (int i = 0; i < receptions.length; i++) {
      batch.set(
        _db.collection('receptions').doc(
              'demo-reception-${i.toString().padLeft(3, '0')}',
            ),
        receptions[i],
        SetOptions(merge: true),
      );
    }

    final audits = _generateAudits(products, demoUsers);

    for (int i = 0; i < audits.length; i++) {
      batch.set(
        _db.collection('audits').doc(
              'demo-audit-${i.toString().padLeft(3, '0')}',
            ),
        audits[i],
        SetOptions(merge: true),
      );
    }

    final alerts = _generateAlertsFromAudits(audits);

    for (int i = 0; i < alerts.length; i++) {
      batch.set(
        _db.collection('alerts').doc(
              'demo-alert-${i.toString().padLeft(3, '0')}',
            ),
        alerts[i],
        SetOptions(merge: true),
      );
    }

    batch.set(
      _db.collection('demo_seed_control').doc('main'),
      {
        'seedName': 'SIO demo ferreteria',
        'productsCount': products.length,
        'usersCount': demoUsers.length,
        'receptionsCount': receptions.length,
        'auditsCount': audits.length,
        'alertsCount': alerts.length,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    await batch.commit();
  }

  static List<Map<String, dynamic>> _generateHardwareProducts() {
    final names = [
      'Tornillo Parker 6x1',
      'Tornillo Fix 8x1',
      'Clavo Punta París 2"',
      'Clavo Punta París 3"',
      'Tarugo Fischer S6',
      'Tarugo Fischer S8',
      'Mecha Widia 6mm',
      'Mecha Widia 8mm',
      'Mecha Acero Rápido 4mm',
      'Mecha Acero Rápido 10mm',
      'Cinta Aisladora Negra',
      'Cinta Teflón',
      'Cinta Métrica 5m',
      'Nivel de Mano 40cm',
      'Martillo Carpintero',
      'Pinza Universal',
      'Alicate Corte Diagonal',
      'Llave Francesa 8"',
      'Llave Francesa 10"',
      'Destornillador Plano',
      'Destornillador Phillips',
      'Set Destornilladores',
      'Llave Allen Set',
      'Serrucho Carpintero',
      'Sierra Metálica',
      'Disco Corte Metal',
      'Disco Corte Madera',
      'Disco Flap 115mm',
      'Lija al Agua 120',
      'Lija al Agua 220',
      'Lija Madera 80',
      'Pincel Nº10',
      'Pincel Nº20',
      'Rodillo Lana 22cm',
      'Bandeja Pintura',
      'Látex Interior Blanco 4L',
      'Esmalte Sintético Blanco 1L',
      'Convertidor Óxido 1L',
      'Aguarrás 1L',
      'Thinner 1L',
      'Silicona Transparente',
      'Sellador Acrílico',
      'Espuma Poliuretánica',
      'Pegamento Contacto',
      'Adhesivo Epoxi',
      'Bulón Hexagonal 8mm',
      'Bulón Hexagonal 10mm',
      'Tuerca Hexagonal 8mm',
      'Tuerca Hexagonal 10mm',
      'Arandela Plana 8mm',
      'Arandela Plana 10mm',
      'Bisagra Zincada 2"',
      'Bisagra Zincada 3"',
      'Pasador Zincado',
      'Candado 30mm',
      'Candado 50mm',
      'Cerradura Exterior',
      'Picaporte Aluminio',
      'Caño PVC 20mm',
      'Caño PVC 25mm',
      'Codo PVC 20mm',
      'Codo PVC 25mm',
      'Tee PVC 20mm',
      'Unión PVC 25mm',
      'Flexible Agua 40cm',
      'Canilla Esférica 1/2"',
      'Válvula Esférica 3/4"',
      'Llave de Paso 1/2"',
      'Cable Unipolar 1.5mm',
      'Cable Unipolar 2.5mm',
      'Ficha Macho 10A',
      'Ficha Hembra 10A',
      'Toma Corriente Exterior',
      'Llave Punto',
      'Caja Térmica 4 Módulos',
      'Disyuntor 25A',
      'Térmica Bipolar 16A',
      'Térmica Bipolar 25A',
      'Portalámpara E27',
      'Lámpara LED 9W',
      'Lámpara LED 12W',
      'Guante Nitrilo',
      'Guante Vaqueta',
      'Antiparra Seguridad',
      'Barbijo Polvo',
      'Casco Seguridad',
      'Escoba Industrial',
      'Pala Ancha',
      'Balde Albañil',
      'Cuchara Albañil',
      'Fratacho Madera',
      'Espátula 50mm',
      'Espátula 100mm',
      'Cutter Reforzado',
      'Repuesto Cutter',
      'Precinto 150mm',
      'Precinto 300mm',
      'Soga Polipropileno',
      'Cadena Galvanizada',
      'Lubricante Multiuso',
      'Grasa Litio',
    ];

    return List.generate(names.length, (index) {
      final barcode = '7799${(100000000 + index).toString()}';
      final conversionFactor = _randomFrom([1, 6, 10, 12, 18, 24, 50, 100]);

      final lowStockChance = _random.nextInt(100);
      final currentStock = lowStockChance < 18
          ? _random.nextInt(10) + 1
          : _random.nextInt(230) + 12;

      return {
        'barcode': barcode,
        'name': names[index],
        'conversionFactor': conversionFactor,
        'currentStock': currentStock,

        // Campo extra útil para Firestore, aunque tu modelo Product actual no lo use.
        // No rompe nada porque Product.fromMap simplemente lo ignora.
        'minimumStock': 10,
      };
    });
  }

  static List<Map<String, dynamic>> _generateReceptions(
    List<Map<String, dynamic>> products,
    List<Map<String, dynamic>> users,
  ) {
    final receptions = <Map<String, dynamic>>[];

    for (int i = 0; i < 180; i++) {
      final product = products[_random.nextInt(products.length)];
      final user = _randomUser(users);

      final conversionFactor = product['conversionFactor'] as int;
      final receivedQuantity = _random.nextInt(10) + 1;
      final totalUnits = receivedQuantity * conversionFactor;

      final previousStock = _random.nextInt(160);
      final newStock = previousStock + totalUnits;

      receptions.add({
        'barcode': product['barcode'],
        'productName': product['name'],
        'conversionFactor': conversionFactor,
        'receivedQuantity': receivedQuantity,
        'totalUnits': totalUnits,
        'previousStock': previousStock,
        'newStock': newStock,
        'receivedByUid': user['uid'],
        'receivedByEmail': user['email'],
        'receivedByName': user['name'],
        'createdAt': Timestamp.fromDate(_randomHistoricalDate()),
      });
    }

    return receptions;
  }

  static List<Map<String, dynamic>> _generateAudits(
    List<Map<String, dynamic>> products,
    List<Map<String, dynamic>> users,
  ) {
    final audits = <Map<String, dynamic>>[];

    for (int i = 0; i < 120; i++) {
      final product = products[_random.nextInt(products.length)];
      final user = _randomUser(users);

      final expectedStock = _random.nextInt(220) + 5;
      final difference = _randomFrom([
        -18,
        -12,
        -8,
        -5,
        -3,
        -1,
        0,
        0,
        0,
        0,
        2,
        4,
        6,
        9,
        12,
      ]);

      final realStock = max(0, expectedStock + difference);

      audits.add({
        'barcode': product['barcode'],
        'productName': product['name'],
        'expectedStock': expectedStock,
        'realStock': realStock,
        'difference': difference,
        'auditedByUid': user['uid'],
        'auditedByEmail': user['email'],
        'auditedByName': user['name'],
        'createdAt': Timestamp.fromDate(_randomHistoricalDate()),
      });
    }

    return audits;
  }

  static List<Map<String, dynamic>> _generateAlertsFromAudits(
    List<Map<String, dynamic>> audits,
  ) {
    final alerts = <Map<String, dynamic>>[];

    for (final audit in audits) {
      final difference = audit['difference'] as int;

      if (difference == 0) continue;
      if (alerts.length >= 65) break;

      final productName = audit['productName'];
      final expected = audit['expectedStock'];
      final real = audit['realStock'];

      alerts.add({
        'type': 'stock_difference',
        'title': 'Diferencia de stock detectada',
        'message':
            '$productName: esperado $expected, real $real. Diferencia: $difference unidades.',
        'barcode': audit['barcode'],
        'productName': productName,
        'difference': difference,
        'read': _random.nextBool(),
        'createdAt': audit['createdAt'],
      });
    }

    return alerts;
  }

  static Map<String, dynamic> _randomUser(List<Map<String, dynamic>> users) {
    return users[_random.nextInt(users.length)];
  }

  static DateTime _randomHistoricalDate() {
    final now = DateTime.now();

    // Pensado para tu caso actual:
    // datos del año completo 2025 + meses actuales de 2026.
    final start = DateTime(2025, 1, 1);
    final end = now;

    final totalDays = max(1, end.difference(start).inDays);
    final randomDays = _random.nextInt(totalDays);

    return start.add(
      Duration(
        days: randomDays,
        hours: _random.nextInt(24),
        minutes: _random.nextInt(60),
      ),
    );
  }

  static DateTime _dateAfter(DateTime base, {required int maxDays}) {
    final candidate = base.add(
      Duration(
        days: _random.nextInt(maxDays) + 1,
        hours: _random.nextInt(24),
        minutes: _random.nextInt(60),
      ),
    );

    final now = DateTime.now();

    return candidate.isAfter(now) ? now : candidate;
  }

  static T _randomFrom<T>(List<T> values) {
    return values[_random.nextInt(values.length)];
  }
}