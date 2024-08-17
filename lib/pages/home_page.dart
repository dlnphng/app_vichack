import 'package:flutter/material.dart';
import 'savedpost_page.dart';
import 'login_page.dart';
import 'custom_drawer.dart';  // Import your custom drawer widget
import 'create_post_bottom_sheet.dart'; // Import your bottom sheet widget
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';


// Post Model
class Post {
  final String id;
  final String userId;
  final String userName;
  final String userImage;
  final String postTitle;
  final String postContent;
  final String postImageUrl;
  final String category;
  final int likes;
  final int comments;
  final List<String> eventTypes;  // Add this line

  Post({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userImage,
    required this.postTitle,
    required this.postContent,
    required this.postImageUrl,
    required this.category,
    required this.likes,
    required this.comments,
    required this.eventTypes,  // Add this line
  });

  factory Post.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Post(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Unknown User',
      userImage: data['userImage'] ?? 'default_avatar.png',
      postTitle: data['title'] ?? 'No Title',
      postContent: data['content'] ?? '',
      postImageUrl: data['imageUrl'] ?? 'default_post_image.png',
      category: data['category'] ?? 'General',
      likes: data['likeNo'] ?? 0,
      comments: data['cmtNo'] ?? 0,
      eventTypes: List<String>.from(data['eventTypes'] ?? []),  // Parse the list
    );
  }
}

class PostCard extends StatelessWidget {
  final Post post;

  const PostCard({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 24.0,
                  backgroundImage: NetworkImage(post.userImage),
                ),
                SizedBox(width: 12.0),
                Expanded(
                  child: Text(
                    post.userName,
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Icon(
                  Icons.star
                  // post.isFavorite ? Icons.star : Icons.star_border,
                  // color: post.isFavorite ? Colors.amber : Colors.grey,
                ),
              ],
            ),
            SizedBox(height: 16.0),
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Image.network(
                post.postImageUrl,
                height: 200.0,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              post.postTitle,
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              post.postContent,
              style: TextStyle(
                fontSize: 14.0,
              ),
            ),
            SizedBox(height: 8.0),
            TextButton(
              onPressed: () {
                // Implement "More" functionality here
              },
              child: Text("More"),
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.comment, color: Colors.grey),
                    SizedBox(width: 4.0),
                    Text(post.comments.toString()),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.favorite, color: Colors.red),
                    SizedBox(width: 4.0),
                    Text(post.likes.toString()),
                  ],
                ),
              ],
            ),
          ],
        ),
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
  List<Post> allPosts = []; // Holds all fetched posts
  List<Post> displayedPosts = []; // Posts to display based on filter

  int _currentPage = 0; 

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabSelection);
    fetchPosts();
    // Listen to filter changes
    Provider.of<PostFilterProvider>(context, listen: false).addListener(_applyFilter);
  }

    void _applyFilter() {
    String? filterType = Provider.of<PostFilterProvider>(context, listen: false).filterType;
    if (_tabController.index == 0 && filterType != null) { // Only apply filter to "Club" posts
      setState(() {
        displayedPosts = allPosts.where((post) =>
          post.category == "Club" && post.eventTypes.contains(filterType)).toList();
      });
    } else {
      // Reset or apply different filters based on tab
      setState(() {
        displayedPosts = allPosts.where((post) => post.category == (_tabController.index == 0 ? "Club" : "Social")).toList();
      });
    }
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      applyFilter(_tabController.index == 0 ? "Club" : "Social");
    }
  }

  void applyFilter(String? filterType) {
    setState(() {
      if (filterType == null) {
        displayedPosts = allPosts; // No filter, show all posts
      } else {
        displayedPosts = allPosts.where((post) => post.category == filterType).toList();
      }
    });
  }

  void _navigateToSocial() {
    setState(() {
      _currentPage = 1; // Set to 1 for your new page
    });
  }

  // void fetchPosts() async {
  //   try {
  //     var firestorePosts = await FirebaseFirestore.instance.collection('posts').get();
  //     List<Post> fetchedPosts = firestorePosts.docs.map((doc) => Post.fromFirestore(doc)).toList();
  //     setState(() {
  //       allPosts = fetchedPosts;
  //       applyFilter(_tabController.index == 0 ? "Club" : "Social"); // Apply filter based on the current tab
  //     });
  //   } catch (e) {
  //     print('Error fetching posts: $e');
  //   }
  // }

  void fetchPosts() async {
    try {
      var firestorePosts = await FirebaseFirestore.instance.collection('posts').get();
      setState(() {
        allPosts = firestorePosts.docs.map((doc) => Post.fromFirestore(doc)).toList();
        applyFilter(_tabController.index == 0 ? "Club" : "Social"); // Apply initial filter based on the current tab
      });
    } catch (e) {
      print('Error fetching posts: $e');
    }
  }


  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    Provider.of<PostFilterProvider>(context, listen: false).removeListener(_applyFilter);
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
      drawer: const CustomDrawer(),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Display the filtered list of posts for "Club"
          ListView.builder(
            itemCount: displayedPosts.length,
            itemBuilder: (context, index) {
              return PostCard(post: displayedPosts[index]);
            },
          ),
          // Display the filtered list of posts for "Social"
          ListView.builder(
            itemCount: displayedPosts.length,
            itemBuilder: (context, index) {
              return PostCard(post: displayedPosts[index]);
            },
          ),
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
                  Navigator.push(context,
                    MaterialPageRoute(builder: (context) => YourNewPage()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}