import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'login_page.dart'; // Assuming the UserProvider and UserModel are defined here
import 'home_page.dart'; // Import your Post and Comment models

class Comment {
  final String userId;
  String userName; // Made mutable
  String userImage; // Made mutable
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
      'userImage': userImage,
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
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  Future<void> _fetchComments() async {
    setState(() {
      isLoading = true;
    });

    try {
      DocumentSnapshot postSnapshot = await FirebaseFirestore.instance.collection('posts').doc(widget.post.id).get();
      if (postSnapshot.exists) {
        List<dynamic> commentsData = postSnapshot['commentList'] ?? [];
        List<Comment> fetchedComments = [];

        for (var commentData in commentsData) {
          Comment comment = Comment.fromMap(commentData);
          DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').doc(comment.userId).get();
          if (userSnapshot.exists) {
            comment.userName = userSnapshot['name'] ?? 'Unknown User';
            comment.userImage = userSnapshot['userImage'] ?? 'default_avatar.png';
          }
          fetchedComments.add(comment);
        }

        setState(() {
          _comments = fetchedComments;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load comments: ${e.toString()}"))
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _postComment() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("You must be logged in to comment."))
      );
      return;
    }

    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Comment cannot be empty"))
      );
      return;
    }

    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (!userSnapshot.exists) {
        throw Exception("User not found!");
      }

      Comment newComment = Comment(
        userId: user.uid,
        userName: userSnapshot['name'] ?? "Anonymous",
        userImage: userSnapshot['userImage'] ?? 'path/to/default_avatar.png',
        comment: _commentController.text.trim(),
        timestamp: DateTime.now()
      );

      DocumentReference postRef = FirebaseFirestore.instance.collection('posts').doc(widget.post.id);
      FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot postSnapshot = await transaction.get(postRef);
        if (!postSnapshot.exists) {
          throw Exception("Post not found!");
        }
        List<dynamic> comments = List.from(postSnapshot['commentList'] ?? []);
        comments.add(newComment.toMap());
        transaction.update(postRef, {
          'commentList': comments,
          'cmtNo': FieldValue.increment(1) // Increment the comment count
        });
      });

      setState(() {
        _comments.add(newComment);
        _commentController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Comment posted successfully!"))
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to post comment: ${e.toString()}"))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData) {
          return Scaffold(
            body: Center(
              child: Text("Please log in to view and post comments."),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('Comments'),
          ),
          body: Column(
            children: [
              if (isLoading) const LinearProgressIndicator(),
              Expanded(child: buildCommentsSection()),
              buildCommentInputField(),
            ],
          ),
        );
      },
    );
  }

  Widget buildCommentsSection() {
    if (_comments.isEmpty) {
      return Center(child: Text("No comments yet. Be the first to comment!"));
    }

    return ListView.builder(
      itemCount: _comments.length,
      itemBuilder: (context, index) {
        final comment = _comments[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(comment.userImage),
            backgroundColor: Colors.grey[200],
          ),
          title: Text(
            comment.userName,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(comment.comment),
          trailing: Text(
            TimeOfDay.fromDateTime(comment.timestamp).format(context),
            style: TextStyle(fontSize: 12.0, color: Colors.grey),
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
