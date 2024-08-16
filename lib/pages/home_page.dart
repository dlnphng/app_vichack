import 'package:flutter/material.dart';
import 'custom_drawer.dart';  // Import your custom drawer widget
import 'create_post_bottom_sheet.dart'; // Import your bottom sheet widget
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';


// Post Model
class Post {
  final String id;
  final String userName;
  final String userImage;
  final String postTitle;
  final String postContent;
  final String postImageUrl;
  final String category;
  final int likes;
  final int comments;
  final bool isFavorite;  // Ensure this is properly initialized

  Post({
    required this.id,
    required this.userName,
    required this.userImage,
    required this.postTitle,
    required this.postContent,
    required this.postImageUrl,
    required this.category,
    required this.likes,
    required this.comments,
    this.isFavorite = false,  // Provide a default value
  });

  factory Post.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Post(
      id: doc.id,
      userName: data['userName'] ?? 'Unknown User',  // Provide a default username if none is found
      userImage: data['userImage'] ?? 'default_avatar.png',  // Provide a default user image path
      postTitle: data['title'] ?? 'No Title',
      postContent: data['content'] ?? '',
      postImageUrl: data['imageUrl'] ?? 'default_post_image.png',  // Provide a default post image path
      category: data['category'] ?? 'Club',
      likes: data['likeNo'] ?? 0,
      comments: data['cmtNo'] ?? 0,
      isFavorite: data['isFavorite'] as bool? ?? false,  // Explicitly handle null with a fallback
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
                  post.isFavorite ? Icons.star : Icons.star_border,
                  color: post.isFavorite ? Colors.amber : Colors.grey,
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


// // Post Widget
// class PostWidget extends StatelessWidget {
//   final Post post;

//   const PostWidget({Key? key, required this.post}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: EdgeInsets.all(8),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           ListTile(
//             leading: CircleAvatar(backgroundImage: NetworkImage(post.userImage)),
//             title: Text(post.userName),
//             subtitle: Text(post.postContent),
//           ),
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 16),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 Text('${post.likes} Likes'),
//                 Text('${post.comments} Comments'),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// Home Page
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Post> socialPosts = [];
  List<Post> clubPosts = [];
      // Demo posts
    // List<Post> demoPosts = [
    //   Post(id: '1', userName: 'Iris', userImage: 'path_to_iris_image', postContent: 'Are you Ready to build the next big mobile app? Join our Mobile Development workshop.', likes: 77, comments: 118),
    //   Post(id: '2', userName: 'Rosé', userImage: 'path_to_rose_image', postContent: 'Learn to create stunning UIs, handle logins, and model with Firebase and Realtime Database.', likes: 77, comments: 118),
    // ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchPosts();
  }

  void fetchPosts() async {
    var firestorePosts = await FirebaseFirestore.instance.collection('posts').get();
    var fetchedPosts = firestorePosts.docs.map((doc) => Post.fromFirestore(doc)).toList();
    
    setState(() {
      socialPosts = fetchedPosts.where((post) => post.category == 'Social').toList();
      clubPosts = fetchedPosts.where((post) => post.category != 'Social').toList();
    });
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
      drawer: const CustomDrawer(),
      body: TabBarView(
        controller: _tabController,
        children: [
          ListView.builder(
            itemCount: clubPosts.length,
            itemBuilder: (context, index) {
              return PostCard(post: clubPosts[index]);
            },
          ),
          ListView.builder(
            itemCount: socialPosts.length,
            itemBuilder: (context, index) {
              return PostCard(post: socialPosts[index]);
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
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}