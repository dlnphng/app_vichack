import 'package:flutter/material.dart';
import 'create_post_bottom_sheet.dart'; // Import your bottom sheet widget

// Post Model
class Post {
  final String userName;
  final String userImage;
  final String postContent;
  final int likes;
  final int comments;

  Post({
    required this.userName,
    required this.userImage,
    required this.postContent,
    required this.likes,
    required this.comments,
  });
}

// Post Widget
class PostWidget extends StatelessWidget {
  final Post post;

  // Custom color defined as a constant
  static const Color postBackgroundColor = Color(0xFFFFEEDD);

  const PostWidget({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(8),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: postBackgroundColor, // Use the custom color
        borderRadius: BorderRadius.circular(8), // Optional: for rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 4,
            offset: Offset(0, 3), // Shadow direction
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(backgroundImage: NetworkImage(post.userImage)),
            title: Text(post.userName),
            subtitle: Text(post.postContent),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('${post.likes} Likes'),
                Text('${post.comments} Comments'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Home Page
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<Post> posts = [
    Post(userName: 'Iris', userImage: 'path_to_iris_image', postContent: 'Are you Ready to build the next big mobile app? Join our Mobile Development workshop.', likes: 77, comments: 118),
    Post(userName: 'Rosé', userImage: 'path_to_rose_image', postContent: 'Learn to create stunning UIs, handle logins, and model with Firebase and Realtime Database.', likes: 77, comments: 118),
    Post(userName: 'Alex', userImage: 'path_to_alex_image', postContent: 'Join our new workshop on Flutter and Dart.', likes: 53, comments: 45),
    Post(userName: 'Jamie', userImage: 'path_to_jamie_image', postContent: 'Tips and tricks for effective state management in Flutter.', likes: 89, comments: 67),
    Post(userName: 'Jordan', userImage: 'path_to_jordan_image', postContent: 'Explore new features in the latest Flutter release.', likes: 112, comments: 80),
    Post(userName: 'Taylor', userImage: 'path_to_taylor_image', postContent: 'Creating responsive designs with Flutter.', likes: 94, comments: 90),
    // Add more posts here if needed
  ];

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
          ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              return PostWidget(post: posts[index]);
            },
          ),
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
