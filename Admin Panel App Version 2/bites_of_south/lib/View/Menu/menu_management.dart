import 'package:bites_of_south/Controller/menu_provider.dart';
import 'package:bites_of_south/Modal/menu_item.dart';
import 'package:bites_of_south/View/Menu/add_item_to_menu.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MenuManagementScreen extends StatefulWidget {
  @override
  _MenuManagementScreenState createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends State<MenuManagementScreen> {
  List<MenuItem> _menuItems = [];
  bool _isLoading = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchMenuItems();
  }

  Future<void> _fetchMenuItems() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('menu').get();
      setState(() {
        _menuItems =
            snapshot.docs.map((doc) => MenuItem.fromFirestore(doc)).toList();
      });
    } catch (e) {
      print("Error fetching items: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Menu Management"),
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _menuItems.isEmpty
                ? Center(child: Text("No items available"))
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: _menuItems.length,
                      itemBuilder: (context, index) {
                        final menuItem = _menuItems[index];
                        return GestureDetector(
                          onTap: () {
                            // Navigate to details screen (not implemented here)
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
                              image: DecorationImage(
                                image: NetworkImage(menuItem.imageUrl),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: GridTile(
                              child: Stack(
                                children: [
                                  Positioned(
                                    top: 10,
                                    child: Container(
                                      color: Colors.black.withOpacity(0.5),
                                      height: 50,
                                    ),
                                  ),
                                  Container(
                                    child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            menuItem.title,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            "₹" + menuItem.price,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddItemToMenu()),
            ).then((_) {
              _fetchMenuItems();
            });
          },
          child: Icon(Icons.add),
        ));
  }
}
