import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_page.dart';  // Import the Post model and PostCard widget
import 'custom_drawer.dart';  // Import your custom drawer widget
import 'create_post_bottom_sheet.dart';  // Import your create post bottom sheet widget
import 'login_page.dart';  // Assuming the UserProvider and UserModel are defined in login_page.dart
import 'package:provider/provider.dart';  // For managing state with Provider

class SavedPostsPage extends StatefulWidget {
  @override
  _SavedPostsPageState createState() => _SavedPostsPageState();
}

class _SavedPostsPageState extends State<SavedPostsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Post> savedPosts = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // Mimicking the HomePage TabBar
    fetchSavedPosts();
  }

  void fetchSavedPosts() async {
    final userId = Provider.of<UserProvider>(context, listen: false).user?.id;
    if (userId == null) return;

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    final savedPostIds = List<String>.from(userDoc['savedPosts'] ?? []);

    List<Post> fetchedPosts = [];
    for (var postId in savedPostIds) {
      var postDoc = await FirebaseFirestore.instance.collection('posts').doc(postId).get();
      if (postDoc.exists) {
        var postData = postDoc.data() as Map<String, dynamic>;
        var userDoc = await FirebaseFirestore.instance.collection('users').doc(postData['userId']).get();
        var userData = userDoc.data() as Map<String, dynamic>;

        fetchedPosts.add(Post.fromFirestoreWithUser(postDoc, userData));
      }
    }

    setState(() {
      savedPosts = fetchedPosts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 56,
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
          height: 25,
          child: TextField(
            decoration: InputDecoration(
              prefixIcon: SizedBox(
                width: 15,
                child: Icon(Icons.search, color: Colors.grey, size: 24),
              ),
              hintText: 'Search...',
              filled: true,
              fillColor: Colors.grey[200],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 8),
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
          preferredSize: const Size.fromHeight(30.0),
          child: TabBar(
            controller: _tabController,
            indicatorColor: Colors.black,
            labelColor: Colors.black,
            tabs: [
              Tab(text: 'Saved Club Posts'),
              Tab(text: 'Saved Social Posts'),
            ],
          ),
        ),
      ),
      drawer: const CustomDrawer(),  // Reuse the CustomDrawer
      body: TabBarView(
        controller: _tabController,
        children: [
          ListView.builder(
            itemCount: savedPosts.length,
            itemBuilder: (context, index) {
              final post = savedPosts[index];
              if (post.category == "Club") {
                return PostCard(post: post);
              }
              return Container(); // Empty container for non-club posts
            },
          ),
          ListView.builder(
            itemCount: savedPosts.length,
            itemBuilder: (context, index) {
              final post = savedPosts[index];
              if (post.category == "Social") {
                return PostCard(post: post);
              }
              return Container(); // Empty container for non-social posts
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => CreatePostBottomSheet(),
          );
        },
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
                  Navigator.pop(context); // Navigate back to HomePage
                },
              ),
            ),
            Spacer(),
            Expanded(
              child: IconButton(
                icon: const Icon(Icons.star),
                onPressed: () {
                  // Stay on the current page since we're already on the saved posts page
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
