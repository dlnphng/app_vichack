import 'package:app_vichack/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'pages/home_page.dart';

// Firebase initialization
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  // 1. 初始化 Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _handleAuthState(), // hadle first scrren 
    );
  }

  Widget _handleAuthState() {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

    if (user != null) {
      // user already login => HomePage
      return HomePage();
    } else {
      // user have't login => LoginPage
      return LoginPage();
    }
  }
}
