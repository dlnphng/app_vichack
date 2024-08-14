import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      height: max(MediaQuery.of(context).size.height * 0.75, 500),  // Adjusted height
      child: SingleChildScrollView(  // Ensure the entire content is scrollable
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
              onPressed: () {
                // Handle submission logic here
                Navigator.pop(context);
              },
              child: const Text('Submit Post'),
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
