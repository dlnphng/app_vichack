import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'login_page.dart'; // Assuming the UserProvider and UserModel are defined here
import 'home_page.dart'; // Import your Post and Comment models

class Comment {
  final String userId;
  final String userName;
  final String userImage;
  final String comment;
  final DateTime timestamp;

  Comment({
    required this.userId,
    required this.userName,
    required this.userImage,
    required this.comment,
    required this.timestamp,
  });

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'Unknown User',
      userImage: map['userImage'] ?? 'default_avatar.png',
      comment: map['comment'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      // 'userImage': userImage,
      'comment': comment,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}

class CommentScreen extends StatefulWidget {
  final Post post;

  const CommentScreen({Key? key, required this.post}) : super(key: key);

  @override
  _CommentScreenState createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  final TextEditingController _commentController = TextEditingController();
  List<Comment> _comments = [];
  int _commentCount = 0;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _comments = List.from(widget.post.commentList); // Initialize with existing comments
    _commentCount = widget.post.comments; // Initialize with the current comment count
  }

  Future<void> _postComment() async {
    final userId =     UserRepository.getCurrentUser()?.uid;
    final userName =      UserRepository.getCurrentUser()?.name;
    // final userImage =     UserRepository.getCurrentUser()?.usserI;


    if (userId == null || userName == null|| _commentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to send comment: Missing user information or comment text")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final postRef = FirebaseFirestore.instance.collection('posts').doc(widget.post.id);

    try {
      Comment newComment = Comment(
        userId: userId,
        userName: userName,
        userImage: 'default_avatar.png',
        comment: _commentController.text,
        timestamp: DateTime.now(),
      );

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot postSnapshot = await transaction.get(postRef);
        if (!postSnapshot.exists) {
          throw Exception("Post not found!");
        }

        List<dynamic> comments = postSnapshot['commentsList'] ?? [];
        comments.add(newComment.toMap());

        transaction.update(postRef, {
          'commentsList': comments,
          'cmtNo': FieldValue.increment(1),
        });
      });

      setState(() {
        _comments.add(newComment); // Add to the local state list
        _commentCount += 1;  // Increment the local comment count
        _commentController.clear(); // Clear the text field
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Comment sent successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to send comment: ${e.toString()}")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comments'),
      ),
      body: Column(
        children: [
          if (isLoading)
            const LinearProgressIndicator(),
          Expanded(child: buildCommentsSection()),
          buildCommentInputField(),
        ],
      ),
    );
  }

  Widget buildCommentsSection() {
    if (_comments.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Center(
          child: Text(
            "No comments yet. Be the first to comment!",
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: _comments.length,
      itemBuilder: (context, index) {
        final comment = _comments[index];
        return ListTile(
          // leading: CircleAvatar(
          //   backgroundImage: NetworkImage(comment.userImage),
          // ),
          title: Text(comment.userName),
          subtitle: Text(comment.comment),
          trailing: Text(
            TimeOfDay.fromDateTime(comment.timestamp).format(context),
            style: TextStyle(fontSize: 12.0),
          ),
        );
      },
    );
  }

  Widget buildCommentInputField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: 'Write a comment...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send, color: Colors.blue),
            onPressed: _postComment,
          ),
        ],
      ),
    );
  }
}

extension on User? {
   get name => null;
}
