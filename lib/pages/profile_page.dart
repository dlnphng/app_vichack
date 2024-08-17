import 'dart:io';
import 'package:app_vichack/pages/home_page.dart';
import 'package:app_vichack/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _userName = "Loading...";
  String _userDescription = "Mystery person...";
  String? _avatarUrl; // URL of the avatar image
  String? _backgroundUrl; // URL of the background image
  File? _selectedImage; // File to store the selected image before cropping
  File? _selectedBackgroundImage; // File to store the selected background image before cropping
  List<Post> userPosts = [];

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserData();
    fetchUserPosts();
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
          String? avatarUrl = data?['avatarUrl'];
          String? backgroundUrl = data?['backgroundUrl'];

          setState(() {
            _userName = userName;
            _userDescription = userDescription;
            _avatarUrl = avatarUrl;
            _backgroundUrl = backgroundUrl;
          });
        } else {
          await _firestore.collection('users').doc(user.uid).set({
            'name': "No User Data Found",
            'description': _userDescription,
          });

          setState(() {
            _userName = "No User Data Found";
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

  Future<void> _cropImage(File imageFile, bool isAvatar) async {
    final croppedImage = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      aspectRatio: const CropAspectRatio(ratioX: 1.0, ratioY: 1.0),  // Set to square crop
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: isAvatar ? 'Crop Avatar' : 'Crop Background',
          toolbarColor: Colors.blue,
          toolbarWidgetColor: Colors.white,
          lockAspectRatio: true,  // Lock the aspect ratio to enforce square crop
          hideBottomControls: true,  // Hide controls to enforce crop
        ),
        IOSUiSettings(
          minimumAspectRatio: 1.0,
          aspectRatioLockEnabled: true,  // Lock the aspect ratio on iOS
        ),
      ],
    );

    if (croppedImage != null) {
      File croppedFile = File(croppedImage.path);
      if (isAvatar) {
        await _updateAvatar(croppedFile);  // Save the cropped image to Firebase
      } else {
        await _updateBackground(croppedFile);  // Save the cropped background to Firebase
      }
    }
  }

  Future<void> _updateAvatar(File file) async {
    User? user = UserRepository.getCurrentUser();
    if (user != null) {
      String fileName = 'avatars/${user.uid}.jpg';
      Reference ref = _storage.ref().child(fileName);

      try {
        await ref.putFile(file);
        String avatarUrl = await ref.getDownloadURL();

        await _firestore.collection('users').doc(user.uid).update({
          'avatarUrl': avatarUrl,
        });

        setState(() {
          _avatarUrl = avatarUrl;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Avatar updated successfully!")),
        );
      } catch (e) {
        print("Error uploading avatar: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to upload avatar: $e")),
        );
      }
    }
  }

  Future<void> _updateBackground(File file) async {
    User? user = UserRepository.getCurrentUser();
    if (user != null) {
      String fileName = 'backgrounds/${user.uid}.jpg';
      Reference ref = _storage.ref().child(fileName);

      try {
        await ref.putFile(file);
        String backgroundUrl = await ref.getDownloadURL();

        await _firestore.collection('users').doc(user.uid).update({
          'backgroundUrl': backgroundUrl,
        });

        setState(() {
          _backgroundUrl = backgroundUrl;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Background updated successfully!")),
        );
      } catch (e) {
        print("Error uploading background: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to upload background: $e")),
        );
      }
    }
  }

  Future<void> _selectAvatar() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      _cropImage(File(image.path), true);
    }
  }

  Future<void> _selectBackground() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      _cropImage(File(image.path), false);
    }
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
                    GestureDetector(
                      onTap: _selectBackground,  // Allow the user to change the background
                      child: SizedBox(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height * 0.33,
                        child: _backgroundUrl != null
                            ? Image.network(
                                _backgroundUrl!,
                                fit: BoxFit.cover,
                              )
                            : Image.asset(
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
                    ),
                    Positioned(
                      bottom: -20,
                      child: GestureDetector(
                        onTap: _selectAvatar,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: _avatarUrl != null
                              ? NetworkImage(_avatarUrl!)
                              : const AssetImage('lib/images/iris.jpg') as ImageProvider,
                          backgroundColor: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(25),
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
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          child: Container(
            padding: const EdgeInsets.all(20.0),
            width: MediaQuery.of(context).size.width * 0.8,
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
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: "Enter new User Name",
                    hintStyle: const TextStyle(color: Colors.black54),
                    filled: true,
                    fillColor: const Color.fromARGB(255, 255, 246, 218),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
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
                        ),
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
                        ),
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
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          child: Container(
            padding: const EdgeInsets.all(20.0),
            width: MediaQuery.of(context).size.width * 0.8,
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
                  maxLength: 100,
                  maxLines: 5,
                  minLines: 5,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: "Enter new description",
                    hintStyle: const TextStyle(color: Colors.black54),
                    filled: true,
                    fillColor: const Color.fromARGB(255, 255, 246, 218),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                    counterStyle: const TextStyle(color: Colors.black54),
                  ),
                ),
                const SizedBox(height: 20),
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
                        ),
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
                        ),
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
