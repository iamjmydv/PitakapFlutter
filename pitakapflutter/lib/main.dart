import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pitakapflutter/core/resources/strings.dart';
import 'package:pitakapflutter/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const PitakapApp());
}

class PitakapApp extends StatelessWidget {
  const PitakapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Strings.appName,
      debugShowCheckedModeBanner: false,
      home: const Scaffold(
        body: Center(child: Text(Strings.appName)),
      ),
    );
  }
}
