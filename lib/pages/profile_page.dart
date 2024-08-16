import 'package:app_vichack/pages/login_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'home_page.dart'; // Import to use Post and PostCard

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _userName = "Loading..."; // Initial user name
  String _userDescription = "Mystery person...";
  List<Post> userPosts = [];

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    fetchUserPosts();  // Fetch posts related to the current user
  }

  Future<void> _loadUserData() async {
    try {
      User? user = UserRepository.getCurrentUser();

      if (user != null) {
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();

        if (userDoc.exists) {
          Map<String, dynamic>? data = userDoc.data() as Map<String, dynamic>?;

          String userName = data?['name'] ?? "No Name";
          String userDescription = data?['description'] ?? "Mystery person...";

          // 如果 description 字段不存在，将当前 _userDescription 保存到 Firestore
          if (data != null && !data.containsKey('description')) {
            userDescription = "Mystery person...";
            await _firestore.collection('users').doc(user.uid).set({
              'description': userDescription,
            }, SetOptions(merge: true));
          }

          // 更新状态
          setState(() {
            _userName = userName;
            _userDescription = userDescription;
          });

        } else {
          // 如果用户文档不存在，创建一个新的文档并存储当前 _userDescription
          String defaultUserName = "No User Data Found";
          String defaultUserDescription = _userDescription;

          await _firestore.collection('users').doc(user.uid).set({
            'name': defaultUserName,
            'description': defaultUserDescription,
          });

          setState(() {
            _userName = defaultUserName;
            _userDescription = defaultUserDescription;
          });
        }
      } else {
        setState(() {
          _userName = "Guest";
        });
      }
    } catch (e) {
      print("Error loading user data: $e");
      setState(() {
        _userName = "Error loading user data";
      });
    }
  }

  void fetchUserPosts() async {
    User? user = UserRepository.getCurrentUser();
    if (user != null) {
      var userPostsSnapshot = await _firestore.collection('posts')
          .where('userId', isEqualTo: user.uid)
          .get();
      var fetchedPosts = userPostsSnapshot.docs.map((doc) => Post.fromFirestore(doc)).toList();

      setState(() {
        userPosts = fetchedPosts;
      });
    }
  }

  void firebaseUpdateUserDescription(String newDescription) async {
    setState(() {
      _userDescription = newDescription;
    });

    // Save the new description to Firestore
    User? user = UserRepository.getCurrentUser();
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).set({
        'description': newDescription,
      }, SetOptions(merge: true));
    }
  }

  void firebaseUpdateUserName(String newName) async {
    setState(() {
      _userName = newName;
    });

    // Save the new name to Firestore
    User? user = UserRepository.getCurrentUser();
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).set({
        'name': newName,
      }, SetOptions(merge: true));
    }
  }

  void updateUserName(String newName) {
    setState(() {
      _userName = newName; // Update the user name
      firebaseUpdateUserName(newName);
    });
  }

  void updateUserDescription(String newDescription) {
    setState(() {
      _userDescription = newDescription;
      firebaseUpdateUserDescription(newDescription);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.33,
                      child: Image.asset(
                        'lib/images/iris.jpg',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey,
                            child: const Center(
                              child: Text(
                                'Background Image Not Found',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Positioned(
                      bottom: -20,
                      child: GestureDetector(
                        onTap: () {
                          _showEditDescriptionDialog(context);
                        },
                        child: const CircleAvatar(
                          radius: 50,
                          backgroundImage: AssetImage('lib/images/iris.jpg'),
                          backgroundColor: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 30, left: 25, right: 25, bottom: 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _userName,
                            style: const TextStyle(
                              fontFamily: 'Arial',
                              fontSize: 20,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.grey,
                              size: 15,
                            ),
                            onPressed: () {
                              _showEditUserNameDialog(context);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _userDescription,
                        style: const TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 15,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.grey,
                              size: 15,
                            ),
                            onPressed: () {
                              _showEditDescriptionDialog(context);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Use the PostCard widget to display user posts
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: userPosts.length,
                        itemBuilder: (context, index) {
                          return PostCard(post: userPosts[index]);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 40,
            left: 10,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Color.fromARGB(255, 222, 162, 72),
                size: 32,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showEditUserNameDialog(BuildContext context) {
    final TextEditingController userNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          backgroundColor: const Color.fromARGB(255, 255, 255, 255), // 设置整个对话框的背景颜色为白色
          child: Container(
            padding: const EdgeInsets.all(20.0),
            width: MediaQuery.of(context).size.width * 0.8, // 设置固定宽度为屏幕宽度的80%
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Edit User Name',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: userNameController,
                  style: const TextStyle(color: Colors.black), // 输入文本的颜色
                  decoration: InputDecoration(
                    hintText: "Enter new User Name",
                    hintStyle: const TextStyle(color: Colors.black54), // 提示文本颜色
                    filled: true,
                    fillColor: const Color.fromARGB(255, 255, 246, 218), // 淡芒果黄背景色
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20), // 添加一点间距
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Color.fromARGB(255, 255, 206, 57),
                          fontSize: 20,
                        ), // 设置文本颜色为芒果黄，字体大小为20
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        updateUserName(userNameController.text);
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'Save',
                        style: TextStyle(
                          color: Color.fromARGB(255, 255, 206, 57),
                          fontSize: 20,
                        ), // 设置文本颜色为芒果黄，字体大小为20
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditDescriptionDialog(BuildContext context) {
    final TextEditingController userDescriptionController = TextEditingController(text: _userDescription);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          backgroundColor: const Color.fromARGB(255, 255, 255, 255), // 设置整个对话框的背景颜色为芒果黄
          child: Container(
            padding: const EdgeInsets.all(20.0),
            width: MediaQuery.of(context).size.width * 0.8, // 设置固定宽度为屏幕宽度的80%
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Edit Description',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: userDescriptionController,
                  maxLength: 100, // 限制输入的最大字符数
                  maxLines: 5, // 限制输入框最多显示的行数
                  minLines: 5, // 限制输入框最少显示的行数
                  style: const TextStyle(color: Colors.black), // 输入文本的颜色
                  decoration: InputDecoration(
                    hintText: "Enter new description",
                    hintStyle: const TextStyle(color: Colors.black54), // 提示文本颜色
                    filled: true,
                    fillColor: const Color.fromARGB(255, 255, 246, 218), // 淡芒果黄背景色
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                    counterStyle: const TextStyle(color: Colors.black54), // 计数器文本颜色
                  ),
                ),
                const SizedBox(height: 20), // 添加一点间距
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Color.fromARGB(255, 255, 206, 57),
                          fontSize: 20,
                        ), // 设置文本颜色为黑色，字体大小为20
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        updateUserDescription(userDescriptionController.text);
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'Save',
                        style: TextStyle(
                          color: Color.fromARGB(255, 255, 206, 57),
                          fontSize: 20,
                        ), // 设置文本颜色为黑色，字体大小为20
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
