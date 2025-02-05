import 'dart:io';
import 'package:bites_of_south/Controller/database_services_menu.dart';
import 'package:bites_of_south/Modal/menu_item.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';

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
  final _ratingController = TextEditingController();
  File? _image;
  UploadTask? _uploadTask;
  final _dbServices = DatabaseServicesMenu();
  bool _isLoading = false;

  // Category options for the dropdown
  List<String> _categories = [
    'Dosa',
    'Uttapam',
    'Idli & Vada',
    'Thali',
    'Special Dosa',
    'Rasam Rice',
    'Beverage'
  ];
  String? _selectedCategory;

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
      setState(() {
        _isLoading = true;
      });

      try {
        final ref = FirebaseStorage.instance
            .ref()
            .child('images/menu/${DateTime.now().toString()}');
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
            category:
                _selectedCategory ?? 'Uncategorized', // Use selected category
            imageUrl: imageUrl);

        _dbServices.create(newItem);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Item added successfully!")),
        );

        Navigator.pop(context);

        _titleController.clear();
        _priceController.clear();
        _descriptionController.clear();
        _makingTimeController.clear();
        _ratingController.clear();
        setState(() {
          _image = null;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error uploading item: $e")),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add New Menu Item"),
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.2,
                    width: MediaQuery.of(context).size.height * 0.2,
                    child: Lottie.asset('assets/loadin.json'),
                  ),
                  Text("Adding Item..."),
                ],
              ),
            )
          : Padding(
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
                      enabled: !_isLoading,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      keyboardType: TextInputType.number,
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
                      enabled: !_isLoading,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      minLines: 2,
                      maxLines: 4,
                      decoration: InputDecoration(labelText: "Description"),
                      controller: _descriptionController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter a description.";
                        }
                        return null;
                      },
                      enabled: !_isLoading,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      decoration:
                          InputDecoration(labelText: "Making Time (mins)"),
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
                      enabled: !_isLoading,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(labelText: "Rating"),
                      controller: _ratingController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter a Rating.";
                        }
                        return null;
                      },
                      enabled: !_isLoading,
                    ),
                    SizedBox(height: 16),
                    // Dropdown for category
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(labelText: "Category"),
                      value: _selectedCategory,
                      onChanged: (newValue) {
                        setState(() {
                          _selectedCategory = newValue;
                        });
                      },
                      items: _categories
                          .map((category) => DropdownMenuItem(
                                value: category,
                                child: Text(category),
                              ))
                          .toList(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please select a category.";
                        }
                        return null;
                      },
                      enableFeedback: !_isLoading,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _uploadItem,
                      child: Text("Add Item"),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
