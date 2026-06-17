import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart' hide FirebaseService;
import 'firebase_options.dart';
import 'theme/accessible_theme.dart';
import 'screens/home_screen.dart';
import 'services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Sign in anonymously on startup
  final firebaseService = FirebaseService();
  await firebaseService.signInAnonymously();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Accessible Story Chatbot',
      theme: AccessibleTheme.lightTheme,
      darkTheme: AccessibleTheme.darkTheme,
      themeMode: ThemeMode.dark,
      showSemanticsDebugger: false, // Turn this to false when you are done testing!
      home: HomeScreen(),
    );
  }
}
