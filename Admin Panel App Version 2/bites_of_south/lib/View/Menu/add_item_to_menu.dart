import 'dart:io';
import 'package:bites_of_south/Controller/database_services_menu.dart';
import 'package:bites_of_south/Modal/menu_item.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddItemToMenu extends StatefulWidget {
  const AddItemToMenu({super.key});

  @override
  State<AddItemToMenu> createState() => _AddItemToMenuState();
}

class _AddItemToMenuState extends State<AddItemToMenu> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _makingTimeController = TextEditingController();
  final _categoryController = TextEditingController();
  final _ratingController = TextEditingController();
  File? _image;
  UploadTask? _uploadTask;
  final _dbServices = DatabaseServicesMenu();

  Future<void> _pickImage() async {
    final picture = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picture != null) {
      setState(() {
        _image = File(picture.path);
      });
    }
  }

  Future<void> _uploadItem() async {
    if (_formKey.currentState!.validate()) {
      if (_image == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please select an image.")),
        );
        return;
      }

      try {
        final ref = FirebaseStorage.instance
            .ref()
            .child('images/testing/${DateTime.now().toString()}');
        _uploadTask = ref.putFile(_image!);
        final snapshot = await _uploadTask!.whenComplete(() => null);
        final imageUrl = await snapshot.ref.getDownloadURL();

        print("Image URL: $imageUrl");
        final newItem = MenuItem(
            title: _titleController.text,
            price: _priceController.text,
            description: _descriptionController.text,
            makingTime: _makingTimeController.text,
            rating: _ratingController.text,
            category: _categoryController.text,
            imageUrl: imageUrl);

        _dbServices.create(newItem);

        // Save item details to Firestore or other backend logic here.

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Item added successfully!")),
        );

        Navigator.pop(context);

        // Optionally clear fields and image
        _titleController.clear();
        _priceController.clear();
        _descriptionController.clear();
        _makingTimeController.clear();
        _categoryController.clear();
        setState(() {
          _image = null;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error uploading item: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add New Menu Item"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: _image == null
                    ? Container(
                        height: 200,
                        color: Colors.grey[200],
                        child: Center(child: Text("Pick Image")),
                      )
                    : Image.file(
                        _image!,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: "Title"),
                controller: _titleController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter a title.";
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: "Price"),
                controller: _priceController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter a price.";
                  }
                  if (double.tryParse(value) == null) {
                    return "Please enter a valid number.";
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: "Description"),
                controller: _descriptionController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter a description.";
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: "Making Time (mins)"),
                controller: _makingTimeController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter making time.";
                  }
                  if (int.tryParse(value) == null) {
                    return "Please enter a valid number.";
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: "Rating"),
                controller: _ratingController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter a Rating.";
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: "Category"),
                controller: _categoryController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter a category.";
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _uploadItem,
                child: Text("Add Item"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
