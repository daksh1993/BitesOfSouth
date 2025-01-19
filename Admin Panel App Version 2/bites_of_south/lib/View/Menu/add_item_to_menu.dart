// import 'dart:io';

import 'package:bites_of_south/Controller/menu_provider.dart';
// import 'package:bites_of_south/Modal/menu_item.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:provider/provider.dart';

// class AddItemToMenuScreen extends StatefulWidget {
//   const AddItemToMenuScreen({super.key});

//   @override
//   State<AddItemToMenuScreen> createState() => _AddItemToMenuScreenState();
// }

// class _AddItemToMenuScreenState extends State<AddItemToMenuScreen> {

//   final _formKey = GlobalKey< FormState>();
//   final _picker = ImagePicker();
//   File? _image;
//   String _title = '';
//   String _price = '';
//   String _description = '';
//   String _makingTime = '';
//   String _category = '';

// Future<void> _pickImage() async {
//     final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         _image = File(pickedFile.path);
//       });
//     }
//   }

//     Future<void> _addItemToFirestore(MenuProvider menuProvider) async {
//     final imageUrl = await menuProvider.uploadImageToStorage(_image!);

//     final newItem = MenuItem(
//       title: _title,
//       price: _price,
//       description: _description,
//       makingTime: _makingTime,
//       category: _category,
//       imageUrl: imageUrl,
//     );

//     await menuProvider.addMenuItem(newItem);  // Use provider to update the list
//     Navigator.pop(context);
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Add New Menu Item"),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: ListView(
//             children: [

//               GestureDetector(
//                 onTap: _pickImage,
//                 child: _image == null
//                     ? Container(
//                         height: 200,
//                         color: Colors.grey[200],
//                         child: Center(child: Text("Pick Image")),
//                       )
//                     : Image.file(
//                         _image!,
//                         height: 200,
//                         fit: BoxFit.cover,
//                       ),
//               ),
//               SizedBox(height: 16),
//               // Title Field
//               TextFormField(
//                 decoration: InputDecoration(labelText: "Title"),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter a title';
//                   }
//                   return null;
//                 },
//                 onChanged: (value) => _title = value,
//               ),
//               SizedBox(height: 16),
//               // Price Field
//               TextFormField(
//                 decoration: InputDecoration(labelText: "Price"),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter a price';
//                   }
//                   return null;
//                 },
//                 onChanged: (value) => _price = value,
//               ),
//               SizedBox(height: 16),
//               // Description Field
//               TextFormField(
//                 decoration: InputDecoration(labelText: "Description"),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter a description';
//                   }
//                   return null;
//                 },
//                 onChanged: (value) => _description = value,
//               ),
//               SizedBox(height: 16),
//               // Making Time Field
//               TextFormField(
//                 decoration: InputDecoration(labelText: "Making Time (mins)"),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter making time';
//                   }
//                   return null;
//                 },
//                 onChanged: (value) => _makingTime = value,
//               ),
//               SizedBox(height: 16),
//               // Category Field
//               TextFormField(
//                 decoration: InputDecoration(labelText: "Category"),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter a category';
//                   }
//                   return null;
//                 },
//                 onChanged: (value) => _category = value,
//               ),
//               SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: () {
//                   if (_formKey.currentState!.validate() && _image != null) {
//                     final menuProvider = Provider.of<MenuProvider>(context, listen: false);
//                     _addItemToFirestore(menuProvider);
//                   } else {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(content: Text("Please fill all fields and pick an image")),
//                     );
//                   }

//                 },
//                 child: Text("Add Item"),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:io';
import 'package:bites_of_south/Controller/database_services_menu.dart';
import 'package:bites_of_south/Modal/menu_item.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

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
            .child('images/menuItem/${DateTime.now().toString()}');
        _uploadTask = ref.putFile(_image!);
        final snapshot = await _uploadTask!.whenComplete(() => null);
        final imageUrl = await snapshot.ref.getDownloadURL();

        print("Image URL: $imageUrl");
        final newItem = MenuItem(
            title: _titleController.text,
            price: _priceController.text,
            description: _descriptionController.text,
            makingTime: _makingTimeController.text,
            category: _categoryController.text,
            imageUrl: imageUrl);

        _dbServices.create(newItem);

        // Save item details to Firestore or other backend logic here.

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Item added successfully!")),
        );

        final menuProvider = Provider.of<MenuProvider>(context, listen: false);
        await menuProvider.addMenuItem(newItem);
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
