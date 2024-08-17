import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
            title: const Text('All events'),
            onTap: () {
              Navigator.pop(context);
              // Trigger the event type filter
              Provider.of<PostFilterProvider>(context, listen: false).setFilter(null);
            },
          ),
          ListTile(
            title: const Text('IT events'),
            onTap: () {
              Navigator.pop(context);
              Provider.of<PostFilterProvider>(context, listen: false).setFilter('IT');
            },
          ),
          ListTile(
            title: const Text('Law events'),
            onTap: () {
              Navigator.pop(context);
              Provider.of<PostFilterProvider>(context, listen: false).setFilter('Law');
            },
          ),
          ListTile(
            title: const Text('Business events'),
            onTap: () {
              Navigator.pop(context);
              Provider.of<PostFilterProvider>(context, listen: false).setFilter('Business');
            },
          ),
          ListTile(
            title: const Text('Engineering events'),
            onTap: () {
              Navigator.pop(context);
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
    notifyListeners();
  }
}

