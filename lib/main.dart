import 'package:app_vichack/pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/post_popup_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ProfilePage(), //first page to be home page rn instead of login
    );
  }
}
