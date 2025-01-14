import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddItemToMenu extends StatefulWidget {
  const AddItemToMenu({super.key});

  @override
  State<AddItemToMenu> createState() => _AddItemToMenuState();
}

class _AddItemToMenuState extends State<AddItemToMenu> {
  File? image;
  final formkey = GlobalKey<FormState>();
  final picker = ImagePicker();
  String title = '';
  String price = '';
  String description = '';
  String makingTime = '';
  String category = '';

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Form(
            key: formkey,
            child: ListView(
              children: [
                GestureDetector(
                  onTap: () {
                    pickImage();
                  },
                  child: image == null
                      ? Container(
                          height: 200,
                          color: Colors.grey[200],
                          child: Center(child: Text("Pick Image")))
                      : Image.file(
                          image!,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: "Title"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                  onChanged: (value) => title = value,
                ),
                SizedBox(
                  height: 16,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: "Price"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a price';
                    }
                    return null;
                  },
                  onChanged: (value) => price = value,
                ),
                SizedBox(
                  height: 16,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: "Description"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                  onChanged: (value) => description = value,
                ),
                SizedBox(
                  height: 16,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: "Making Time (mins)"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the making time';
                    }
                    return null;
                  },
                  onChanged: (value) => makingTime = value,
                ),
                SizedBox(
                  height: 16,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: "Category"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the Category';
                    }
                    return null;
                  },
                  onChanged: (value) => category = value,
                ),
                SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                    onPressed: () {
                      if (formkey.currentState!.validate() && image != null) {
                        print("Item added");
                        print("Name " + title);
                        print("price " + price);
                        print("desc " + description);
                        print("Makin " + makingTime);
                        print("cat " + category);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  "Please fill all fields and pick an image")),
                        );
                      }
                    },
                    child: Text(
                      "Add Item",
                    ))
              ],
            )),
      ),
    );
  }
}
