import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'screens/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyCAClmWl3zhveas41n6IIeUE7NQZiGxgoE",
          appId: "1:835797285711:android:74ad3d98e23f01e046e33a",
          messagingSenderId: "",
          projectId: ""));
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Machat',
        theme: ThemeData(
            appBarTheme: const AppBarTheme(
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(color: Colors.black, fontSize: 30),
          backgroundColor: Colors.amber,
        )
            // useMaterial3: true,
            ),
        home: const LoginScreen());
  }
}
