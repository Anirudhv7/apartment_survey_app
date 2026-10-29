import 'package:apartment_survey_app/features/main_screen/application/apartment/apartment.dart';
import 'package:apartment_survey_app/features/main_screen/application/apartment/services/apratment_services.dart';
import 'package:apartment_survey_app/main.dart' show initializeFirestore;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kDebugMode ||
      !const bool.fromEnvironment(
        'USE_FIRESTORE_EMULATOR',
        defaultValue: true,
      )) {
    throw StateError('Smoke tests require debug mode and the emulator.');
  }
  final firestore = await initializeFirestore();
  if (firestore.app.options.projectId != 'demo-apartment-survey' ||
      firestore.settings.host != '10.0.2.2:8080') {
    throw StateError('Refusing to test outside the Android/local demo setup.');
  }
  final service = ApartmentServices(firestore: firestore);
  final apartment = Apartment(
    block: 'DUMMY-${DateTime.now().microsecondsSinceEpoch}',
    doorNumber: 9999,
    status: 'pending',
    interests: 'Synthetic test data',
    job: 'Dummy',
  );
  final doc = firestore
      .collection('apartments')
      .doc(
        '${apartment.block}-${apartment.doorNumber}',
      );
  try {
    await service.addApartment(apartment).timeout(const Duration(seconds: 20));
    var duplicateRejected = false;
    try {
      await service.addApartment(apartment);
    } on StateError {
      duplicateRejected = true;
    }
    if (!duplicateRejected) throw StateError('Duplicate was accepted.');
    final updated = Apartment(
      block: apartment.block,
      doorNumber: apartment.doorNumber,
      status: 'completed',
      interests: apartment.interests,
      job: apartment.job,
    );
    await service.updateApartment(apartment, updated);
    final snapshot = await doc.get(const GetOptions(source: Source.server));
    if (snapshot.data()?['status'] != 'completed') {
      throw StateError('Update was not stored on the server.');
    }
    await service
        .watchApartments()
        .firstWhere(
          (items) => items.any((item) => item.block == apartment.block),
        )
        .timeout(const Duration(seconds: 10));
    await service.deleteApartment(updated);
    if ((await doc.get(const GetOptions(source: Source.server))).exists) {
      throw StateError('Delete failed.');
    }
    debugPrint(
      'FIRESTORE_SMOKE_PASS: create, duplicate, update, stream, delete',
    );
    runApp(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: Text('Firestore local smoke test passed')),
        ),
      ),
    );
  } finally {
    await doc.delete().timeout(const Duration(seconds: 10));
  }
}
