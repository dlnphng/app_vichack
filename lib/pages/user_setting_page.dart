import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'login_page.dart';
import 'home_page.dart';

class UserSettingPage extends StatefulWidget {
  const UserSettingPage({Key? key}) : super(key: key);

  @override
  _UserSettingPageState createState() => _UserSettingPageState();
}

class _UserSettingPageState extends State<UserSettingPage> {
  String? _userName;
  String? _userImage;
  final ImagePicker _picker = ImagePicker();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _universityController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _nameController.text = _userName ?? '';
  }

  void _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>?;
        setState(() {
          _userName = data?['name'];
          _userImage = data?['userImage'];
          _nameController.text = data?['name'] ?? ''; // Set name
          _universityController.text = data?['university'] ?? ''; // Set university
          _descriptionController.text = data?['description'] ?? ''; // Set description or empty if null
        });
      }
    }
  }

    Future<void> _updateUserProfile(BuildContext context) async {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'name': _nameController.text,
        'university': _universityController.text,
        'description': _descriptionController.text
      });
      Navigator.pop(context); // Optionally refresh or pop the page
  }

  Future<void> _changeProfileImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      String userId = FirebaseAuth.instance.currentUser!.uid;
      String filePath = 'user_profiles/$userId/avatar.png';

      // Upload to Firebase Storage
      try {
        await FirebaseStorage.instance.ref(filePath).putFile(imageFile);
        String downloadUrl = await FirebaseStorage.instance.ref(filePath).getDownloadURL();

        // Update Firestore user document
        await FirebaseFirestore.instance.collection('users').doc(userId).update({'userImage': downloadUrl});

        // Update local state to reflect the new image
        setState(() {
          _userImage = downloadUrl;
        });
      } catch (e) {
        print("Error uploading image: $e");
      }
    }
  }

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      ModalRoute.withName('/'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Settings'),
        backgroundColor: const Color.fromARGB(255, 255, 193, 86),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: _changeProfileImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: _userImage != null ? NetworkImage(_userImage!) : null,
                  backgroundColor: Colors.deepOrange[300],
                  child: _userImage == null ? const Icon(Icons.add_a_photo, size: 60, color: Colors.white) : null,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextFormField(
                controller: _universityController,
                decoration: const InputDecoration(labelText: 'University'),
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _updateUserProfile(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 255, 193, 86),
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
                  shape: RoundedRectangleBorder( // Rounded corners consistent with the logout button
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text('Update Profile', style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _logout(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 255, 193, 86),
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25), // Ensure consistency in rounding
                  ),
                ),
                child: const Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

}
