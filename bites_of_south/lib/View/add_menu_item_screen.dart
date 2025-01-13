import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:bites_of_south/Controller/menu_provider.dart';
import 'package:bites_of_south/Modal/menu_item.dart';

class AddMenuItemScreen extends StatefulWidget {
  @override
  _AddMenuItemScreenState createState() => _AddMenuItemScreenState();
}

class _AddMenuItemScreenState extends State<AddMenuItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  File? _image;
  String _title = '';
  String _price = '';
  String _description = '';
  String _makingTime = '';
  String _category = '';

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _addItemToFirestore(MenuProvider menuProvider) async {
    final imageUrl = await menuProvider.uploadImageToStorage(_image!);

    final newItem = MenuItem(
      title: _title,
      price: _price,
      description: _description,
      makingTime: _makingTime,
      category: _category,
      imageUrl: imageUrl,
    );

    await menuProvider.addMenuItem(newItem);  // Use provider to update the list
    Navigator.pop(context);
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
              // Image Picker
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
              // Title Field
              TextFormField(
                decoration: InputDecoration(labelText: "Title"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
                onChanged: (value) => _title = value,
              ),
              SizedBox(height: 16),
              // Price Field
              TextFormField(
                decoration: InputDecoration(labelText: "Price"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  return null;
                },
                onChanged: (value) => _price = value,
              ),
              SizedBox(height: 16),
              // Description Field
              TextFormField(
                decoration: InputDecoration(labelText: "Description"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
                onChanged: (value) => _description = value,
              ),
              SizedBox(height: 16),
              // Making Time Field
              TextFormField(
                decoration: InputDecoration(labelText: "Making Time (mins)"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter making time';
                  }
                  return null;
                },
                onChanged: (value) => _makingTime = value,
              ),
              SizedBox(height: 16),
              // Category Field
              TextFormField(
                decoration: InputDecoration(labelText: "Category"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a category';
                  }
                  return null;
                },
                onChanged: (value) => _category = value,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate() && _image != null) {
                    final menuProvider = Provider.of<MenuProvider>(context, listen: false);
                    _addItemToFirestore(menuProvider);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Please fill all fields and pick an image")),
                    );
                  }
                },
                child: Text("Add Item"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}