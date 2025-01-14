import 'dart:io';

import 'package:bite_of_south/View/add_item_to_menu.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MenuManagementScreen extends StatefulWidget {
  const MenuManagementScreen({super.key});

  @override
  State<MenuManagementScreen> createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends State<MenuManagementScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[300],
      ),
      body: Center(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => AddItemToMenu()));
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
