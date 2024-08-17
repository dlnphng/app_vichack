import 'package:flutter/material.dart';
import 'home_page.dart';
import 'login_page.dart';
import 'custom_drawer.dart';
import 'create_post_bottom_sheet.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

class YourNewPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('This is the saved page'),
      ),
    );
  }
}
