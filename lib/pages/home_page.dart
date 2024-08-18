import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'custom_drawer.dart';
import 'create_post_bottom_sheet.dart';
import 'savedpost_page.dart';
import 'profile_page.dart';
import 'comment.dart';
import 'user_setting_page.dart';
import 'login_page.dart';

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
  int currentLikes = 0;  // Local state to track likes count

  @override
  void initState() {
    super.initState();
    currentLikes = widget.post.likes;  // Initialize with the post's likes count from the widget
    checkIfSaved();
  }

  void checkIfSaved() async {
    final userId = UserRepository.getCurrentUser()?.uid;
    if (userId == null) return;

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    final savedPostIds = List<String>.from(userDoc['savedPosts'] ?? []);

    setState(() {
      isSaved = savedPostIds.contains(widget.post.id);
    });
  }

  Future<void> toggleSavePost() async {
    final userId = UserRepository.getCurrentUser()?.uid;
    if (userId == null) return;

    final userDocRef = FirebaseFirestore.instance.collection('users').doc(userId);
    final postDocRef = FirebaseFirestore.instance.collection('posts').doc(widget.post.id);

    bool wasSaved = isSaved;  // Track the initial saved state

    setState(() {  // Update the local state immediately for responsive UI
      if (isSaved) {
        isSaved = false;
        currentLikes--;  // Decrement likes if un-saved
      } else {
        isSaved = true;
        currentLikes++;  // Increment likes if saved
      }
    });

    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot userDocSnapshot = await transaction.get(userDocRef);
      DocumentSnapshot postDocSnapshot = await transaction.get(postDocRef);

      if (!userDocSnapshot.exists || !postDocSnapshot.exists) {
        throw Exception("User or Post not found!");
      }

      List<dynamic> savedPosts = userDocSnapshot['savedPosts'] ?? [];

      if (wasSaved) {
        // Remove from saved posts and decrement likes
        transaction.update(userDocRef, {
          'savedPosts': FieldValue.arrayRemove([widget.post.id])
        });
        transaction.update(postDocRef, {
          'likeNo': FieldValue.increment(-1)
        });
      } else {
        // Add to saved posts and increment likes
        transaction.update(userDocRef, {
          'savedPosts': FieldValue.arrayUnion([widget.post.id])
        });
        transaction.update(postDocRef, {
          'likeNo': FieldValue.increment(1)
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

  TextEditingController _searchController = TextEditingController();

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
      MaterialPageRoute(builder: (context) => SavedPostsPage()),
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
        title: TextField(
          controller: _searchController,  // Use the TextEditingController here
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
          onSubmitted: (query) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SearchResultsPage(searchQuery: query)),
            );
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.black),
            onPressed: () {
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



//Search Bar Page
class SearchResultsPage extends StatefulWidget {
  final String searchQuery;

  SearchResultsPage({Key? key, required this.searchQuery}) : super(key: key);

  @override
  _SearchResultsPageState createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Results'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Users'),
            Tab(text: 'Posts'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          UserResults(searchQuery: widget.searchQuery),
          PostResults(searchQuery: widget.searchQuery),
        ],
      ),
    );
  }
}

class UserResults extends StatelessWidget {
  final String searchQuery;

  UserResults({required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('name', isGreaterThanOrEqualTo: searchQuery)
          .where('name', isLessThanOrEqualTo: searchQuery + '\uf8ff')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No users found.'));
        }
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            SearchUserModel user = SearchUserModel.fromDocumentSnapshot(snapshot.data!.docs[index]);
            return UserCard(user: user);
          },
        );
      },
    );
  }
}

class PostResults extends StatelessWidget {
  final String searchQuery;

  PostResults({required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    Stream<QuerySnapshot> stream;

    if (searchQuery.isEmpty) {
      stream = FirebaseFirestore.instance.collection('posts').snapshots();
    } else {
      // This adjusts the query to look for titles that start with the search query
      stream = FirebaseFirestore.instance
          .collection('posts')
          .orderBy('title') // Ensure 'postTitle' is indexed in your Firestore
          .startAt([searchQuery])
          .endAt([searchQuery + '\uf8ff'])
          .snapshots();
    }

    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No posts found.'));
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot doc = snapshot.data!.docs[index];
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('users').doc(doc['userId']).get(),
              builder: (context, userSnapshot) {
                if (!userSnapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                Post post = Post.fromFirestoreWithUser(doc, userSnapshot.data!.data() as Map<String, dynamic>);
                return PostCard(post: post);
              },
            );
          },
        );
      },
    );
  }
}




class UserCard extends StatelessWidget {
  final SearchUserModel user;

  const UserCard({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 24.0,
              backgroundImage: NetworkImage(user.userImage),
              backgroundColor: Colors.transparent,
            ),
            SizedBox(width: 12.0),
            Expanded(
              child: Text(
                user.name,
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class SearchUserModel {
  final String id;
  final String name;
  final String userImage;

  SearchUserModel({
    required this.id,
    required this.name,
    required this.userImage,
  });

  factory SearchUserModel.fromDocumentSnapshot(DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;
    return SearchUserModel(
      id: doc.id,
      name: data['name'] ?? 'Unknown',
      userImage: data['userImage'] ?? 'default_avatar.png',
    );
  }
}

