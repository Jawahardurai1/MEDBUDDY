import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';

class PostAdvertisementPage extends StatefulWidget {
  @override
  _PostAdvertisementPageState createState() => _PostAdvertisementPageState();
}

class _PostAdvertisementPageState extends State<PostAdvertisementPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _specialistController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  List<Uint8List?> _imageBytesList = [];
  final picker = ImagePicker();

  Future<void> _pickImages() async {
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      setState(() {
        _imageBytesList.clear();
        for (var pickedFile in pickedFiles) {
          pickedFile.readAsBytes().then((bytes) {
            setState(() {
              _imageBytesList.add(bytes);
            });
          });
        }
      });
    }
  }

  Future<void> _postAdvertisement() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final String apiUrl = "http://127.0.0.1:8000/api/data/";
    final request = http.MultipartRequest('POST', Uri.parse(apiUrl));

    for (int i = 0; i < _imageBytesList.length; i++) {
      if (_imageBytesList[i] != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'image${i + 1}',
          _imageBytesList[i]! ,
          filename: 'image${i + 1}.jpg',
          contentType: MediaType('image', 'jpeg'),
        ));
      }
    }

    request.fields['title'] = _titleController.text;
    request.fields['name'] = _nameController.text;
    request.fields['specialist'] = _specialistController.text;
    request.fields['description'] = _descriptionController.text;

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        _showSuccessDialog(' posted successfully!');
        _clearFields();
      } else {
        _showErrorDialog('Failed to post ', 'Please Enter All Details');
      }
    } catch (e) {
      _showErrorDialog('Error', e.toString());
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title: const Text('Success', style: TextStyle(color: Colors.white)),
          content: Text(message, style: TextStyle(color: Colors.white)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK', style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title: Text(title, style: TextStyle(color: Colors.white)),
          content: Text(message, style: TextStyle(color: Colors.white)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _clearFields() {
    _titleController.clear();
    _nameController.clear();
    _specialistController.clear();
    _descriptionController.clear();
    setState(() {
      _imageBytesList.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Upload', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 6, 5, 5)    ,
         leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),  ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              GestureDetector(
                onTap: _pickImages,
                child: _imageBytesList.isNotEmpty
                    ? Wrap(
                        spacing: 8.0,
                        children: _imageBytesList.map((imageBytes) {
                          return Container(
                            height: 150,
                            width: 150,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: MemoryImage(imageBytes!),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          );
                        }).toList(),
                      )
                    : Container(
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.add, size: 50, color: Colors.white),
                      ),
              ),
              const SizedBox(height: 16),
              _buildTextField(_titleController, 'Title'),
              const SizedBox(height: 16),
              _buildTextField(_nameController, 'Name'),
              const SizedBox(height: 16),
              _buildTextField(_specialistController, 'Specialist'),
              const SizedBox(height: 16),
              _buildTextField(_descriptionController, 'Your Thoughts', maxLines: 4),
              const SizedBox(height: 16),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[800]),
                onPressed: _postAdvertisement,
                child: const Text('Submit', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white60),
        filled: true,
        fillColor: Colors.grey[900],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      maxLines: maxLines,
      keyboardType: maxLines > 1 ? TextInputType.multiline : TextInputType.text,
    );
  }
}