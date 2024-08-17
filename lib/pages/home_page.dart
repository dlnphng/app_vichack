import 'package:app_vichack/pages/profile_page.dart';
import 'package:app_vichack/pages/user_setting_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'custom_drawer.dart';
import 'create_post_bottom_sheet.dart';
import 'savedpost_page.dart';
import 'login_page.dart';
import 'comment.dart';

class Post {
  final String id;
  final String userId;
  final String userName;
  final String userImage;
  final String postTitle;
  final String postContent;
  final List<String> postImageUrls;
  final String category;
  final int likes;
  final int comments;
  final List<String> eventTypes;
  final List<Comment> commentList;

  Post({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userImage,
    required this.postTitle,
    required this.postContent,
    required this.postImageUrls,
    required this.category,
    required this.likes,
    required this.comments,
    required this.eventTypes,
    required this.commentList,
  });

  factory Post.fromFirestoreWithUser(DocumentSnapshot postDoc, Map<String, dynamic> userData) {
    var postData = postDoc.data() as Map<String, dynamic>;
    return Post(
      id: postDoc.id,
      userId: postData['userId'] ?? '',
      userName: userData['name'] ?? 'Unknown User',
      userImage: userData['userImage'] ?? 'default_avatar.png',
      postTitle: postData['title'] ?? 'No Title',
      postContent: postData['content'] ?? '',
      postImageUrls: List<String>.from(postData['imageUrls'] ?? []),
      category: postData['category'] ?? 'General',
      likes: int.parse(postData['likeNo']?.toString() ?? '0'),
      comments: int.parse(postData['cmtNo']?.toString() ?? '0'),
      eventTypes: List<String>.from(postData['eventTypes'] ?? []),
      commentList: List<Comment>.from(postData['commentsList']?.map((commentData) => Comment.fromMap(commentData)) ?? []),
    );
  }
}

class PostCard extends StatefulWidget {
  final Post post;

  const PostCard({Key? key, required this.post}) : super(key: key);

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isSaved = false;

  @override
  void initState() {
    super.initState();
    checkIfSaved();
  }

  void checkIfSaved() async {
    final userId = Provider.of<UserProvider>(context, listen: false).user?.id;
    if (userId == null) return;

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    final savedPostIds = List<String>.from(userDoc['savedPosts'] ?? []);

    setState(() {
      isSaved = savedPostIds.contains(widget.post.id);
    });
  }

  Future<void> toggleSavePost() async {
    final userId = Provider.of<UserProvider>(context, listen: false).user?.id;
    if (userId == null) return;

    final userDocRef = FirebaseFirestore.instance.collection('users').doc(userId);

    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot userDocSnapshot = await transaction.get(userDocRef);
      if (!userDocSnapshot.exists) {
        throw Exception("User not found!");
      }

      List<dynamic> savedPosts = userDocSnapshot['savedPosts'] ?? [];

      if (savedPosts.contains(widget.post.id)) {
        transaction.update(userDocRef, {
          'savedPosts': FieldValue.arrayRemove([widget.post.id])
        });
        setState(() {
          isSaved = false;
        });
      } else {
        transaction.update(userDocRef, {
          'savedPosts': FieldValue.arrayUnion([widget.post.id])
        });
        setState(() {
          isSaved = true;
        });
      }
    });
  }

  void _navigateToComments() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommentScreen(post: widget.post),
      ),
    );
  }

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
                  backgroundImage: NetworkImage(widget.post.userImage),
                ),
                SizedBox(width: 12.0),
                Expanded(
                  child: Text(
                    widget.post.userName,
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isSaved ? Icons.star : Icons.star_border,
                    color: isSaved ? Colors.yellow : Colors.grey,
                  ),
                  onPressed: toggleSavePost,
                ),
              ],
            ),
            SizedBox(height: 16.0),
            buildImageDisplay(context),
            SizedBox(height: 16.0),
            Text(
              widget.post.postTitle,
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              widget.post.postContent,
              style: TextStyle(
                fontSize: 14.0,
              ),
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: _navigateToComments,
                  child: Row(
                    children: [
                      Icon(Icons.comment, color: Colors.grey),
                      SizedBox(width: 4.0),
                      Text(widget.post.comments.toString()),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.favorite, color: Colors.red),
                    SizedBox(width: 4.0),
                    Text(widget.post.likes.toString()),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildImageDisplay(BuildContext context) {
    int imageCount = widget.post.postImageUrls.length;

    if (imageCount == 0) {
      return Container();
    }

    switch (imageCount) {
      case 1:
        return GestureDetector(
          onTap: () => showImageGallery(context, widget.post.postImageUrls, 0),
          child: Image.network(widget.post.postImageUrls.first, fit: BoxFit.cover, width: double.infinity, height: 200),
        );
      case 2:
        return Row(
          children: widget.post.postImageUrls.map((url) {
            return Expanded(
              child: GestureDetector(
                onTap: () => showImageGallery(context, widget.post.postImageUrls, widget.post.postImageUrls.indexOf(url)),
                child: Image.network(url, fit: BoxFit.cover, height: 200),
              ),
            );
          }).toList(),
        );
      case 3:
        return Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => showImageGallery(context, widget.post.postImageUrls, 0),
                child: Image.network(widget.post.postImageUrls[0], fit: BoxFit.cover, height: 300),
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => showImageGallery(context, widget.post.postImageUrls, 1),
                    child: Image.network(widget.post.postImageUrls[1], fit: BoxFit.cover, height: 150),
                  ),
                  GestureDetector(
                    onTap: () => showImageGallery(context, widget.post.postImageUrls, 2),
                    child: Image.network(widget.post.postImageUrls[2], fit: BoxFit.cover, height: 150),
                  ),
                ],
              ),
            ),
          ],
        );
      default:
        return Stack(
          alignment: Alignment.bottomRight,
          children: [
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => showImageGallery(context, widget.post.postImageUrls, 0),
                        child: Image.network(widget.post.postImageUrls[0], fit: BoxFit.cover, height: 300),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () => showImageGallery(context, widget.post.postImageUrls, 1),
                            child: Image.network(widget.post.postImageUrls[1], fit: BoxFit.cover, height: 150),
                          ),
                          GestureDetector(
                            onTap: () => showImageGallery(context, widget.post.postImageUrls, 2),
                            child: Image.network(widget.post.postImageUrls[2], fit: BoxFit.cover, height: 150),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (imageCount > 3)
              Container(
                width: 165,
                height: 150,
                color: Colors.black45,
                child: Center(
                  child: Text(
                    '+${imageCount - 3}',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ),
              ),
          ],
        );
    }
  }

  void showImageGallery(BuildContext context, List<String> imageUrls, int initialPage) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.black,
          ),
          backgroundColor: Colors.black,
          body: PageView.builder(
            itemCount: imageUrls.length,
            controller: PageController(initialPage: initialPage),
            itemBuilder: (context, index) => InteractiveViewer(
              child: Image.network(imageUrls[index], fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Post> allPosts = [];
  List<Post> displayedPosts = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabSelection);
    fetchPosts();
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      applyFilter(_tabController.index == 0 ? "Club" : "Social");
    }
  }

  void applyFilter(String? filterType) {
    setState(() {
      if (filterType == null) {
        displayedPosts = allPosts;
      } else {
        displayedPosts = allPosts.where((post) => post.category == filterType).toList();
      }
    });
  }

  void _navigateToSavedPosts() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SavedPostsPage()), // Navigate to SavedPostsPage
    );
  }

  void fetchPosts() async {
    setState(() {
      isLoading = true;
    });
    try {
      var firestorePosts = await FirebaseFirestore.instance.collection('posts').get();
      List<Post> fetchedPosts = [];

      for (var doc in firestorePosts.docs) {
        var postData = doc.data() as Map<String, dynamic>;
        if (postData.containsKey('userId') && postData['userId'] != null) {
          var userDoc = await FirebaseFirestore.instance.collection('users').doc(postData['userId']).get();
          var userData = userDoc.data() as Map<String, dynamic>;

          fetchedPosts.add(Post.fromFirestoreWithUser(doc, userData));
        }
      }

      setState(() {
        allPosts = fetchedPosts;
        applyFilter(_tabController.index == 0 ? "Club" : "Social");
      });
    } catch (e) {
      print('Error fetching posts: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return const CreatePostBottomSheet();
      },
    );
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
              // Navigate to the ProfileSettingPage when the avatar icon is pressed
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UserSettingPage()),
              );
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
              Tab(text: 'Club'),
              Tab(text: 'Social'),
            ],
          ),
        ),
      ),
      drawer: const CustomDrawer(),
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            children: [
              ListView.builder(
                itemCount: displayedPosts.length,
                itemBuilder: (context, index) {
                  return PostCard(post: displayedPosts[index]);
                },
              ),
              ListView.builder(
                itemCount: displayedPosts.length,
                itemBuilder: (context, index) {
                  return PostCard(post: displayedPosts[index]);
                },
              ),
            ],
          ),
          if (isLoading)
            Center(
              child: CircularProgressIndicator(),
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
                  print("home button pressed");
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfilePage()),
                  );
                },
              ),
            ),
            Spacer(),
            Expanded(
              child: IconButton(
                icon: const Icon(Icons.star),
                onPressed: _navigateToSavedPosts,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
