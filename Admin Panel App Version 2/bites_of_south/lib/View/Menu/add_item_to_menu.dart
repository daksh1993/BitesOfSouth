import 'dart:io';
import 'package:bites_of_south/Controller/database_services_menu.dart';
import 'package:bites_of_south/Modal/menu_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  final _makingPriceController = TextEditingController(); // New controller
  final _descriptionController = TextEditingController();
  final _makingTimeController = TextEditingController();
  final _ratingController = TextEditingController();
  File? _image;
  UploadTask? _uploadTask;
  final _dbServices = DatabaseServicesMenu();
  bool _isLoading = false;
  bool _availability = true;

  // Category options for the dropdown
  final List<String> _categories = [
    'Dosa',
    'Uttapam',
    'Idli & Vada',
    'Thali',
    'Special Dosa',
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
          SnackBar(
            content: const Text("Please select an image"),
            backgroundColor: Colors.red[400],
          ),
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

        final newItem = MenuItem(
          title: _titleController.text,
          price: _priceController.text,
          makingPrice:
              double.parse(_makingPriceController.text), // Include new field
          description: _descriptionController.text,
          makingTime: _makingTimeController.text,
          rating: _ratingController.text,
          category: _selectedCategory ?? 'Uncategorized',
          imageUrl: imageUrl,
          availability: _availability,
        );

        await _dbServices.create(newItem);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Item added successfully!"),
            backgroundColor: Colors.green[600],
          ),
        );

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error uploading item: $e"),
            backgroundColor: Colors.red[400],
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
          _image = null;
          _titleController.clear();
          _priceController.clear();
          _makingPriceController.clear();
          _descriptionController.clear();
          _makingTimeController.clear();
          _ratingController.clear();
          _selectedCategory = null;
          _availability = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final minDimension =
        screenWidth < screenHeight ? screenWidth : screenHeight;
    final padding = (minDimension * 0.04).clamp(12.0, 20.0);
    final fontSize = (minDimension * 0.045).clamp(14.0, 16.0);

    return OrientationBuilder(
      builder: (context, orientation) {
        final isLandscape = orientation == Orientation.landscape;
        final fieldWidth = isLandscape
            ? (screenWidth - padding * 4) / 2
            : screenWidth - padding * 2;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(
              "Add New Item",
              style: TextStyle(
                fontSize: (minDimension * 0.055).clamp(18.0, 22.0),
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            backgroundColor: Colors.green[600],
            elevation: 2,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: _isLoading ? null : () => Navigator.pop(context),
            ),
          ),
          body: SafeArea(
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Lottie.asset(
                          'assets/loadin.json',
                          width: (minDimension * 0.3).clamp(100.0, 150.0),
                          height: (minDimension * 0.3).clamp(100.0, 150.0),
                        ),
                        SizedBox(height: padding),
                        Text(
                          "Adding Item...",
                          style: TextStyle(
                            fontSize: fontSize,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    padding: EdgeInsets.all(padding),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image Picker
                          GestureDetector(
                            onTap: _isLoading ? null : _pickImage,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              height: (minDimension * 0.5).clamp(150.0, 200.0),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _image == null
                                      ? Colors.grey[400]!
                                      : Colors.green[600]!,
                                  width: 2,
                                ),
                              ),
                              child: _image == null
                                  ? Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.image,
                                          size: (minDimension * 0.1)
                                              .clamp(40.0, 50.0),
                                          color: Colors.grey[600],
                                        ),
                                        Text(
                                          "Tap to select image",
                                          style: TextStyle(
                                            fontSize: fontSize,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    )
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.file(
                                        _image!,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                      ),
                                    ),
                            ),
                          ),
                          SizedBox(height: padding),

                          // Title
                          TextFormField(
                            controller: _titleController,
                            decoration: InputDecoration(
                              labelText: "Title",
                              labelStyle: TextStyle(color: Colors.grey[600]),
                              prefixIcon:
                                  Icon(Icons.title, color: Colors.green[600]),
                              filled: true,
                              fillColor: Colors.grey[50],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    BorderSide(color: Colors.green[600]!),
                              ),
                            ),
                            style: TextStyle(fontSize: fontSize),
                            validator: (value) => value == null || value.isEmpty
                                ? "Enter a title"
                                : null,
                            enabled: !_isLoading,
                          ),
                          SizedBox(height: padding),

                          // Price and Making Price
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _priceController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: "Price",
                                    labelStyle:
                                        TextStyle(color: Colors.grey[600]),
                                    prefixIcon: Icon(Icons.currency_rupee,
                                        color: Colors.green[600]),
                                    filled: true,
                                    fillColor: Colors.grey[50],
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide:
                                          BorderSide(color: Colors.grey[300]!),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide:
                                          BorderSide(color: Colors.green[600]!),
                                    ),
                                  ),
                                  style: TextStyle(fontSize: fontSize),
                                  validator: (value) {
                                    if (value == null || value.isEmpty)
                                      return "Enter a price";
                                    if (double.tryParse(value) == null)
                                      return "Enter a valid number";
                                    return null;
                                  },
                                  enabled: !_isLoading,
                                ),
                              ),
                              SizedBox(width: padding),
                              Expanded(
                                child: TextFormField(
                                  controller: _makingPriceController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: "Making Price",
                                    labelStyle:
                                        TextStyle(color: Colors.grey[600]),
                                    prefixIcon: Icon(Icons.currency_rupee,
                                        color: Colors.green[600]),
                                    filled: true,
                                    fillColor: Colors.grey[50],
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide:
                                          BorderSide(color: Colors.grey[300]!),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide:
                                          BorderSide(color: Colors.green[600]!),
                                    ),
                                  ),
                                  style: TextStyle(fontSize: fontSize),
                                  validator: (value) {
                                    if (value == null || value.isEmpty)
                                      return "Enter making price";
                                    if (double.tryParse(value) == null)
                                      return "Enter a valid number";
                                    return null;
                                  },
                                  enabled: !_isLoading,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: padding),

                          // Description
                          TextFormField(
                            controller: _descriptionController,
                            minLines: 3,
                            maxLines: 5,
                            decoration: InputDecoration(
                              labelText: "Description",
                              labelStyle: TextStyle(color: Colors.grey[600]),
                              prefixIcon: Icon(Icons.description,
                                  color: Colors.green[600]),
                              filled: true,
                              fillColor: Colors.grey[50],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    BorderSide(color: Colors.green[600]!),
                              ),
                            ),
                            style: TextStyle(fontSize: fontSize),
                            validator: (value) => value == null || value.isEmpty
                                ? "Enter a description"
                                : null,
                            enabled: !_isLoading,
                          ),
                          SizedBox(height: padding),

                          // Making Time and Rating
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _makingTimeController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: "Making Time (mins)",
                                    labelStyle:
                                        TextStyle(color: Colors.grey[600]),
                                    prefixIcon: Icon(Icons.timer,
                                        color: Colors.green[600]),
                                    filled: true,
                                    fillColor: Colors.grey[50],
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide:
                                          BorderSide(color: Colors.grey[300]!),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide:
                                          BorderSide(color: Colors.green[600]!),
                                    ),
                                  ),
                                  style: TextStyle(fontSize: fontSize),
                                  validator: (value) {
                                    if (value == null || value.isEmpty)
                                      return "Enter time";
                                    if (int.tryParse(value) == null)
                                      return "Enter a valid number";
                                    return null;
                                  },
                                  enabled: !_isLoading,
                                ),
                              ),
                              SizedBox(width: padding),
                              Expanded(
                                child: TextFormField(
                                  controller: _ratingController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  decoration: InputDecoration(
                                    labelText: "Rating (0-5)",
                                    labelStyle:
                                        TextStyle(color: Colors.grey[600]),
                                    prefixIcon: Icon(Icons.star,
                                        color: Colors.green[600]),
                                    filled: true,
                                    fillColor: Colors.grey[50],
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide:
                                          BorderSide(color: Colors.grey[300]!),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide:
                                          BorderSide(color: Colors.green[600]!),
                                    ),
                                  ),
                                  style: TextStyle(fontSize: fontSize),
                                  validator: (value) {
                                    if (value == null || value.isEmpty)
                                      return "Enter a rating";
                                    final rating = double.tryParse(value);
                                    if (rating == null ||
                                        rating < 0 ||
                                        rating > 5) {
                                      return "Enter 0-5";
                                    }
                                    return null;
                                  },
                                  enabled: !_isLoading,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: padding),

                          // Category
                          DropdownButtonFormField<String>(
                            value: _selectedCategory,
                            decoration: InputDecoration(
                              labelText: "Category",
                              labelStyle: TextStyle(color: Colors.grey[600]),
                              prefixIcon: Icon(Icons.category,
                                  color: Colors.green[600]),
                              filled: true,
                              fillColor: Colors.grey[50],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    BorderSide(color: Colors.green[600]!),
                              ),
                            ),
                            style: TextStyle(
                                fontSize: fontSize, color: Colors.grey[800]),
                            items: _categories.map((category) {
                              return DropdownMenuItem(
                                value: category,
                                child: Text(category),
                              );
                            }).toList(),
                            onChanged: _isLoading
                                ? null
                                : (value) {
                                    setState(() {
                                      _selectedCategory = value;
                                    });
                                  },
                            validator: (value) =>
                                value == null ? "Select a category" : null,
                          ),
                          SizedBox(height: padding),

                          // Availability Toggle
                          Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: SwitchListTile(
                              title: Text(
                                "Available",
                                style: TextStyle(
                                  fontSize: fontSize,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[800],
                                ),
                              ),
                              value: _availability,
                              activeColor: Colors.green[600],
                              onChanged: _isLoading
                                  ? null
                                  : (value) {
                                      setState(() {
                                        _availability = value;
                                      });
                                    },
                            ),
                          ),
                          SizedBox(height: padding * 2),

                          Container(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _uploadItem,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green[600],
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  horizontal: padding * 2,
                                  vertical: padding,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 3,
                              ),
                              child: Text(
                                "Add Item",
                                style: TextStyle(
                                  fontSize: fontSize,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _makingPriceController.dispose();
    _descriptionController.dispose();
    _makingTimeController.dispose();
    _ratingController.dispose();
    super.dispose();
  }
}
