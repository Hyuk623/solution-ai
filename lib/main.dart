import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'presentation/screens/diagnostic_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables for API keys
  // try-catch in case .env is missing during early dev
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Could not load .env file: $e");
  }
  
  // Firebase initialization would go here later
  // await Firebase.initializeApp();

  runApp(
    const ProviderScope(
      child: SoluAiApp(),
    ),
  );
}

class SoluAiApp extends StatelessWidget {
  const SoluAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Solution AI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const DiagnosticScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
