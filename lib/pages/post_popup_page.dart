import 'package:flutter/material.dart';

class PostCard extends StatelessWidget {
  final String avatarUrl;
  final String username;
  final String postImageUrl;
  final String postTitle;
  final String postDescription;
  final int commentsCount;
  final int likesCount;
  final bool isFavorite;

  const PostCard({
    required this.avatarUrl,
    required this.username,
    required this.postImageUrl,
    required this.postTitle,
    required this.postDescription,
    required this.commentsCount,
    required this.likesCount,
    required this.isFavorite,
    Key? key,
  }) : super(key: key);

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
                  backgroundImage: NetworkImage(avatarUrl),
                ),
                SizedBox(width: 12.0),
                Expanded(
                  child: Text(
                    username,
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Icon(
                  isFavorite ? Icons.star : Icons.star_border,
                  color: isFavorite ? Colors.amber : Colors.grey,
                ),
              ],
            ),
            SizedBox(height: 16.0),
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Image.network(
                postImageUrl,
                height: 200.0,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              postTitle,
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              postDescription,
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
                    Text(commentsCount.toString()),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.favorite, color: Colors.red),
                    SizedBox(width: 4.0),
                    Text(likesCount.toString()),
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

class PostListPage extends StatelessWidget {
  final List<Map<String, dynamic>> posts = [
    {
      "avatarUrl": "lib/images/iris.jpg",
      "username": "MAC",
      "postImageUrl": "lib/images/iris.jpg",
      "postTitle": "Ready to build the next big mobile app?",
      "postDescription": "Join our Mobile Development workshop and get hands-on with Flutter, Firebase, and Realtime Database...",
      "commentsCount": 118,
      "likesCount": 77,
      "isFavorite": true,
    },
    {
      "avatarUrl": "lib/images/iris.jpg",
      "username": "JohnDoe",
      "postImageUrl": "lib/images/iris.jpg",
      "postTitle": "Learn Data Science from Scratch!",
      "postDescription": "Our Data Science workshop covers all the basics and advanced topics you need to start your journey.",
      "commentsCount": 54,
      "likesCount": 120,
      "isFavorite": false,
    },
    // Add more posts here...
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Posts"),
      ),
      body: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return PostCard(
            avatarUrl: post["avatarUrl"],
            username: post["username"],
            postImageUrl: post["postImageUrl"],
            postTitle: post["postTitle"],
            postDescription: post["postDescription"],
            commentsCount: post["commentsCount"],
            likesCount: post["likesCount"],
            isFavorite: post["isFavorite"],
          );
        },
      ),
    );
  }
}
