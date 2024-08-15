import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
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

  CollectionReference posts = FirebaseFirestore.instance.collection('posts');

  try {
    // Add post details to Firestore without image URLs
    await posts.add({
      'title': _titleController.text,
      'content': _contentController.text,
      'category': _selectedCategory,
      'timestamp': FieldValue.serverTimestamp(),
      'likeNo': 0,
      'cmtNo': 0,
    });

    Navigator.pop(context); // Close the bottom sheet after successful submission
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

  String? _selectedCategory;

  Widget _buildCategoryPicker() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: () => setState(() => _selectedCategory = 'Social'),
          child: Text('Social', style: TextStyle(color: _selectedCategory == 'Social' ? Colors.white : Colors.black)),
          style: ElevatedButton.styleFrom(
            backgroundColor: _selectedCategory == 'Social' ? Colors.blue : Colors.grey[300],  // Updated from 'primary'
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
    );
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      height: max(MediaQuery.of(context).size.height * 0.75, 500),
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
