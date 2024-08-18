import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_page.dart'; // Make sure this path is correct and imports the necessary provider

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
            title: const Text('All Club Events'),
            onTap: () {
              Navigator.pop(context);  // Close the drawer
              Provider.of<PostFilterProvider>(context, listen: false).setFilter(null);
            },
          ),
          ListTile(
            title: const Text('IT Events'),
            onTap: () {
              Navigator.pop(context);  // Close the drawer
              Provider.of<PostFilterProvider>(context, listen: false).setFilter('IT');
            },
          ),
          ListTile(
            title: const Text('Law Events'),
            onTap: () {
              Navigator.pop(context);  // Close the drawer
              Provider.of<PostFilterProvider>(context, listen: false).setFilter('Law');
            },
          ),
          ListTile(
            title: const Text('Business Events'),
            onTap: () {
              Navigator.pop(context);  // Close the drawer
              Provider.of<PostFilterProvider>(context, listen: false).setFilter('Business');
            },
          ),
          ListTile(
            title: const Text('Engineering Events'),
            onTap: () {
              Navigator.pop(context);  // Close the drawer
              Provider.of<PostFilterProvider>(context, listen: false).setFilter('Engineering');
            },
          ),
        ],
      ),
    );
  }
}

class PostFilterProvider with ChangeNotifier {
  String? _filterType;

  String? get filterType => _filterType;

  void setFilter(String? type) {
    _filterType = type;
    notifyListeners();  // Notify listeners about the change
  }
}
