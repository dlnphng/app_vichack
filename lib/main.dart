import 'package:app_vichack/pages/login_page.dart';
import 'package:app_vichack/pages/signup_page.dart';
import 'package:app_vichack/pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/post_popup_page.dart';
import 'package:provider/provider.dart';


//Firebase initialization
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );

  runApp(
    ChangeNotifierProvider(
      create: (context) => UserProvider(),
      child: const MyApp(),
    ),
  );
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // home: const SignupPage(), 
      home: SignupPage(), //first page to be home page rn instead of login
    );
  }
}

