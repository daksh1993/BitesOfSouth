import 'package:bites_of_south/Controller/menu_provider.dart';
import 'package:bites_of_south/View/add_item_to_menu.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MenuManagementScreen extends StatefulWidget {
  @override
  _MenuManagementScreenState createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends State<MenuManagementScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch menu items from Firestore when the screen is initialized
    Provider.of<MenuProvider>(context, listen: false).fetchMenuItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Menu Management"),
      ),
      body: Consumer<MenuProvider>(
        builder: (context, menuProvider, child) {
          if (menuProvider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: menuProvider.menuItems.length,
            itemBuilder: (context, index) {
              final menuItem = menuProvider.menuItems[index];
              return GestureDetector(
                onTap: () {
                  // Navigate to details screen (not implemented here)
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    image: DecorationImage(
                      image: NetworkImage(menuItem.imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: GridTile(
                    child: Container(
                      color: Colors.black.withOpacity(0.5),
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          menuItem.title,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ),
                ),
              ));
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddItemToMenuScreen()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}