import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          SizedBox(height: 60),  // Space at the top
          ListTile(
            title: const Text('IT events'),
            onTap: () {
              Navigator.pop(context);  // Closes the drawer
            },
          ),
          ListTile(
            title: const Text('Law events'),
            onTap: () {
              Navigator.pop(context);  // Closes the drawer
            },
          ),
          ListTile(
            title: const Text('Business events'),
            onTap: () {
              Navigator.pop(context);  // Closes the drawer
            },
          ),
        ],
      ),
    );
  }
}
