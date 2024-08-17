import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_page.dart';
import 'home_page.dart';

class UserSettingPage extends StatefulWidget {
  const UserSettingPage({Key? key}) : super(key: key);

  @override
  _UserSettingPageState createState() => _UserSettingPageState();
}

class _UserSettingPageState extends State<UserSettingPage> {
  String? _userName;
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
  User? user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

    if (userDoc.exists) {
      final data = userDoc.data() as Map<String, dynamic>?;  // Cast data to Map<String, dynamic>
      print("User data: $data");  // Debug output

      setState(() {
        _userName = data?['name'] ?? 'User Name';
        _avatarUrl = data?['avatarUrl'];
      });

      print("Loaded userName: $_userName, avatarUrl: $_avatarUrl");  // Debug output
    } else {
      print("User document does not exist.");
    }
  } else {
    print("No authenticated user found.");
  }
}



  void _logout(BuildContext context) async {
    // Sign out from Firebase
    await FirebaseAuth.instance.signOut();

    // Clear the stored user credentials
    UserRepository.clearUserCredential();

    // After signing out, redirect to the login page
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) => false, // Removes all the previous routes
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Settings'),
        backgroundColor: const Color.fromARGB(255, 255, 193, 86), // Customize the color if needed
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 20),
              Column(
                children: [
                  // Display the user avatar
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: _avatarUrl != null 
                        ? NetworkImage(_avatarUrl!) 
                        : null,  // If _avatarUrl is not null, display the image
                    backgroundColor: Color.fromARGB(255, 252, 186, 85),
                    child: _avatarUrl == null 
                        ? const Icon(
                            Icons.account_circle, 
                            size: 120, 
                            color: Colors.white,
                          ) 
                        : null,  // If _avatarUrl is null, display a default icon
                  ),
                  const SizedBox(height: 20),
                  // Display the user name
                  Text(
                    _userName ?? 'User Name',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Logout button at the bottom, full width
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _logout(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 255, 193, 86), // Customize the button color
                    padding: const EdgeInsets.symmetric(vertical: 15), // Adjust the padding for height
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
