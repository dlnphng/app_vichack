import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _userName = "Initial Name"; // Initial user name
  String _userDescription = "Description: Iris, third year Monash student! balabalabalabalbalablabalblablbalbalablababbbbbbalabalbalablablablablablabalabla";

  void updateUserName(String newName) {
    setState(() {
      _userName = newName; // Update the user name
    });
  }

  void updateUserDescription(String newDescription) {
    setState(() {
      _userDescription = newDescription;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Stack(
        children: [
          // Scrollable content
          SingleChildScrollView(
            child: Column(
              children: [
                // Stack to overlap CircleAvatar on background image
                Stack(
                  clipBehavior: Clip.none, // Ensure overflow is visible
                  alignment: Alignment.center, // Align center
                  children: [
                    // User page background image
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
                    // CircleAvatar overlapping the background image
                    Positioned(
                      bottom: -20, // Position the CircleAvatar to overlap
                      child: GestureDetector(
                        onTap: () {
                          // Define action when the avatar is tapped
                          print("Avatar tapped!");
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
                
                // Padding to account for the overlap
                Padding(
                  padding: const EdgeInsets.only(
                    top: 30, left: 25, right: 25, bottom: 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row to position the UserName and edit icon
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

                          // Edit username button
                          IconButton(
                            icon: const Icon(
                              Icons.edit, 
                              color: Colors.grey, 
                              size: 15, // Set icon size
                            ),
                            onPressed: () {
                              // Show dialog to edit the username
                              _showEditUserNameDialog(context);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Description
                      Text(
                        _userDescription,
                        style: const TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 15,
                        ),
                      ),

                      // Edit user description button with alignment in Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end, // Align icon to the end (right)
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.edit, 
                              color: Colors.grey, 
                              size: 15, // Set icon size
                            ),
                            onPressed: () {
                              // Show dialog to edit the description
                              _showEditDescriptionDialog(context);
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // Posts section
                      ...List.generate(
                        30, // Generate 30 posts for demonstration
                        (index) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            "Post $index",
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Fixed back button that does not scroll
          Positioned(
            top: 40, // Adjust this based on the device's status bar height
            left: 10,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Color.fromARGB(255, 222, 162, 72),
                size: 32,
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Go back to previous page
              },
            ),
          ),
        ],
      ),
    );
  }

  // Function to show the pop-up page for editing username
  void _showEditUserNameDialog(BuildContext context) {
    final TextEditingController userNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit User Name'),
          content: TextField(
            controller: userNameController,
            decoration: const InputDecoration(hintText: "Enter new User Name"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Update the userName and close the dialog
                print("New Username saved");
                updateUserName(userNameController.text);
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Function to show the pop-up page for editing description
  void _showEditDescriptionDialog(BuildContext context) {
    final TextEditingController userDeescriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Description'),
          content: TextField(
            controller: userDeescriptionController,
            decoration: const InputDecoration(hintText: "Enter new description"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Save the new description
                print("New description saved");
                updateUserDescription(userDeescriptionController.text);
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}

// The full-screen pop-up page
class AvatarEditPage extends StatelessWidget {
  const AvatarEditPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Avatar'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('This is the full-screen page where you can edit your avatar.'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the pop-up screen
              },
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}
