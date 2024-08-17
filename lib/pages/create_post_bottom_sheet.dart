import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';
import 'login_page.dart';
import 'home_page.dart';
import 'dart:math'; // For max function

class CreatePostBottomSheet extends StatefulWidget {
  const CreatePostBottomSheet({Key? key}) : super(key: key);

  @override
  _CreatePostBottomSheetState createState() => _CreatePostBottomSheetState();
}

class _CreatePostBottomSheetState extends State<CreatePostBottomSheet> {
  final ImagePicker _picker = ImagePicker();
  List<XFile> _images = [];
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  String? _selectedCategory;
  List<String> _selectedEventTypes = []; // For multiple event types
  final List<String> _clubTypes = ['IT', 'Law', 'Business', 'Engineering'];

  Future<void> _pickImage() async {
    final List<XFile>? pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      setState(() {
        for (var file in pickedFiles) {
          if (!_images.any((x) => x.path == file.path)) {
            _images.add(file);
          }
        }
      });
    }
  }

  void _deleteImage(XFile file) {
    setState(() {
      _images.remove(file);
    });
  }

void _submitPost() async {
  if (_titleController.text.isEmpty || _contentController.text.isEmpty || _selectedCategory == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please fill in all fields and select a category.")));
    return;
  }

  var currentUser = Provider.of<UserProvider>(context, listen: false).user;
  if (currentUser == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("No user logged in")));
    return;
  }

  try {
    List<String> imageUrls = [];
    for (var image in _images) {
      // Upload each image and store the download URLs
      var fileRef = FirebaseStorage.instance.ref('post_images/${image.name}');
      await fileRef.putFile(File(image.path));
      String downloadUrl = await fileRef.getDownloadURL();
      imageUrls.add(downloadUrl);
    }

    CollectionReference posts = FirebaseFirestore.instance.collection('posts');
    await posts.add({
      'userId': currentUser.id,
      'title': _titleController.text,
      'content': _contentController.text,
      'category': _selectedCategory,
      'eventTypes': _selectedEventTypes,
      'timestamp': FieldValue.serverTimestamp(),
      'likeNo': 0,
      'cmtNo': 0,
      'imageUrls': imageUrls,  // Store image URLs in an array
    });

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Post uploaded successfully!")));
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to upload post: ${e.toString()}")));
    print("Error during post submission: $e");
  }
}

  Widget _buildImageList() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _images.map((file) => Stack(
          alignment: Alignment.topRight,
          children: [
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Image.file(File(file.path), width: 100, height: 100),
            ),
            IconButton(
              icon: Icon(Icons.remove_circle, color: Colors.red),
              onPressed: () => _deleteImage(file),
            ),
          ],
        )).toList(),
      ),
    );
  }

  Widget _buildCategoryPicker() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () => setState(() => _selectedCategory = 'Social'),
              child: Text('Social', style: TextStyle(color: _selectedCategory == 'Social' ? Colors.white : Colors.black)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedCategory == 'Social' ? Colors.blue : Colors.grey[300],
              ),
            ),
            ElevatedButton(
              onPressed: () => setState(() => _selectedCategory = 'Club'),
              child: Text('Club', style: TextStyle(color: _selectedCategory == 'Club' ? Colors.white : Colors.black)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedCategory == 'Club' ? Colors.blue : Colors.grey[300],
              ),
            ),
          ],
        ),
        if (_selectedCategory == 'Club')
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: _buildEventTypesPicker(),
          ),
      ],
    );
  }

  Widget _buildEventTypesPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _clubTypes.map((type) {
        return CheckboxListTile(
          title: Text(type),
          value: _selectedEventTypes.contains(type),
          onChanged: (bool? value) {
            setState(() {
              if (value == true) {
                _selectedEventTypes.add(type);
              } else {
                _selectedEventTypes.remove(type);
              }
            });
          },
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      height: max(MediaQuery.of(context).size.height * 0.85, 550), // Increased height
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text('Create a Post', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
                hintText: 'Enter the title of your post',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Content',
                border: OutlineInputBorder(),
                hintText: 'Enter your post content',
              ),
              keyboardType: TextInputType.multiline,
              maxLines: 4,
            ),
            const SizedBox(height: 10),
            _buildCategoryPicker(),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Choose Pictures'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            _images.isNotEmpty ? _buildImageList() : const Text("No images selected."),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitPost,
              child: const Text('Upload'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}

