import 'package:apartment_survey_app/features/main_screen/presentation/screens/survey_screens.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:apartment_survey_app/features/main_screen/application/apartment/services/apratment_services.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final firestore = await initializeFirestore();
  runApp(MyApp(apartmentServices: ApartmentServices(firestore: firestore)));
}

/// Configure Firestore before constructing any services or starting listeners.
Future<FirebaseFirestore> initializeFirestore() async {
  const useEmulator = bool.fromEnvironment(
    'USE_FIRESTORE_EMULATOR',
    defaultValue: true,
  );
  if (kDebugMode && useEmulator) {
    // A named demo app keeps the native production default app out of this path.
    final app = await Firebase.initializeApp(
      demoProjectId: 'demo-apartment-survey',
    );
    final firestore = FirebaseFirestore.instanceFor(app: app);
    firestore.settings = const Settings(persistenceEnabled: false);
    final host = !kIsWeb && defaultTargetPlatform == TargetPlatform.android
        ? '10.0.2.2'
        : '127.0.0.1';
    firestore.useFirestoreEmulator(host, 8080);
    debugPrint('Firestore emulator: demo-apartment-survey at $host:8080');
    return firestore;
  }

  final app = await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  return FirebaseFirestore.instanceFor(app: app);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.apartmentServices});

  final ApartmentServices? apartmentServices;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Color(0xFF121212),

        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF222222),
          centerTitle: true,
        ),

        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF222222),
          foregroundColor: Colors.white,
        ),
      ),
      home: SurveyScreen(apartmentServices: apartmentServices),
    );
  }
}
