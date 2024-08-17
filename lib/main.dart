import 'package:app_vichack/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/post_popup_page.dart';
import 'package:provider/provider.dart';

// Import PostFilterProvider if it's in a separate file
import 'pages/custom_drawer.dart';

// Firebase initialization
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
	  options: DefaultFirebaseOptions.currentPlatform // Only incluce this if you have the firebase_options.dart file
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => PostFilterProvider()),
      ],
      child: const MyApp(),
    ),
  );
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
