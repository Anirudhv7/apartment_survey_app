import 'package:apartment_survey_app/features/main_screen/application/apartment/apartment.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// import 'package:flutter/material.dart';

class ApartmentServices {
  ApartmentServices({FirebaseFirestore? firestore})
    : firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore firestore;

  Future<void> addApartment(Apartment apartment) async {
    final apartmentsCollection = firestore.collection("apartments");
    final String apartmentId = "${apartment.block}-${apartment.doorNumber}";
    final apartmentDocument = apartmentsCollection.doc(apartmentId);

    await firestore.runTransaction((transaction) async {
      final documentSnapshot = await transaction.get(apartmentDocument);

      if (documentSnapshot.exists) {
        throw StateError("This Apartment alredy exists");
      } else {
        transaction.set(apartmentDocument, apartment.toMap());
      }
    });
  }

  Stream<List<Apartment>> watchApartments() {
    return firestore.collection("apartments").snapshots().map((snapShot) {
      return snapShot.docs.map((doc) {
        return Apartment.fromMap(doc.data());
      }).toList();
    });
  }

  Future<void> updateApartment(
    Apartment originalApartment,
    Apartment updatedApartment,
  ) async {
    final String apartmentId =
        "${originalApartment.block}-${originalApartment.doorNumber}";

    if (originalApartment.block != updatedApartment.block ||
        originalApartment.doorNumber != updatedApartment.doorNumber) {
      throw StateError("Block and Door Number cannot be changed.");
    }

    final apartmentDocument = firestore
        .collection("apartments")
        .doc(apartmentId);

    await apartmentDocument.update(updatedApartment.toMap());
  }

  Future<void> deleteApartment(Apartment apartment) async {
    final apartmentsDoc = firestore.collection("apartments");
    final String deletingId = "${apartment.block}-${apartment.doorNumber}";
    final deletedDoc = apartmentsDoc.doc(deletingId);

    await deletedDoc.delete();
  }
}
