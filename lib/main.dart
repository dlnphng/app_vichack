import 'package:app_vichack/pages/login_page.dart';
import 'package:app_vichack/pages/signup_page.dart';
import 'package:app_vichack/pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/post_popup_page.dart';

//Firebase initialization
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
	// 1. Need this so we can initialise Firebase in the main function
  WidgetsFlutterBinding.ensureInitialized(); 
  
  // 2. Intialise Firebase
  await Firebase.initializeApp(
	  options: DefaultFirebaseOptions.currentPlatform // Only incluce this if you have the firebase_options.dart file
  );
  
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // home: const SignupPage(), 
      home: HomePage(), //first page to be home page rn instead of login
    );
  }
}

