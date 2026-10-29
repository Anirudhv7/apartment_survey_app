import 'package:apartment_survey_app/features/main_screen/application/apartment/apartment.dart';
import 'package:apartment_survey_app/features/main_screen/application/apartment/services/apratment_services.dart';
import 'package:apartment_survey_app/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

// No Firebase initialization or network access is allowed in this widget test.
class _UnusedFirestore implements FirebaseFirestore {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw StateError('Unexpected Firestore access in widget test');
}

class _DummyApartmentServices extends ApartmentServices {
  _DummyApartmentServices() : super(firestore: _UnusedFirestore());

  @override
  Stream<List<Apartment>> watchApartments() => Stream.value([]);
}

void main() {
  testWidgets('Survey shows its empty state without Firebase', (tester) async {
    await tester.pumpWidget(
      MyApp(
        apartmentServices: _DummyApartmentServices(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Apartment Survey'), findsOneWidget);
    expect(find.text('No Apartments Yet.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
