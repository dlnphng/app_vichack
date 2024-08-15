import 'package:flutter/material.dart';
import 'create_post_bottom_sheet.dart'; // Import your bottom sheet widget

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return const CreatePostBottomSheet(); // Use the separate widget here
      },
    );
  }

  void _navigateToSocial(BuildContext context) {
    // Implement navigation to the Social page
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 56, // Height of the AppBar
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.black),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        title: Container(
          height: 25, // Height of the search field
          child: TextField(
            decoration: InputDecoration(
              prefixIcon: SizedBox(
                width: 15, // Adjust width of the search icon
                child: Icon(Icons.search,
                    color: Colors.grey,
                    size: 24), // Adjust size of the search icon
              ),
              hintText: 'Search...',
              filled: true,
              fillColor: Colors.grey[200],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(
                  horizontal: 8), // Adjust padding inside the search field
            ),
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.black),
            onPressed: () {
              // Handle user avatar icon press
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(30.0), // Height of the TabBar
          child: TabBar(
            controller: _tabController,
            indicatorColor: Colors.black, // Color of the underline
            labelColor: Colors.black, // Text color for selected tab
            // unselectedLabelColor: Colors.grey, // Text color for unselected tabs
            tabs: [
              Tab(text: 'Club'),
              Tab(text: 'Social'),
            ],
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.black,
              ),
              child: Text('Drawer Header'),
            ),
            ListTile(
              title: const Text('Item 1'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Item 2'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Center(child: const Text('Club Page Content')),
          Center(child: const Text('Social Page Content')),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showBottomSheet(context),
        tooltip: 'Create Post',
        child: const Icon(Icons.add),
        backgroundColor: Colors.yellow,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: [
            Expanded(
              child: IconButton(
                icon: const Icon(Icons.home),
                onPressed: () {
                  // Handle home icon press
                },
              ),
            ),
            Spacer(), // Pushes the floating action button to the center
            Expanded(
              child: IconButton(
                icon: const Icon(Icons.star),
                onPressed: () {
                  // Handle star icon press
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
