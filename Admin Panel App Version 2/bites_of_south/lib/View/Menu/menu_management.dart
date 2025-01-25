import 'package:bites_of_south/Modal/item_details_modal.dart';
import 'package:bites_of_south/View/Menu/add_item_to_menu.dart';
import 'package:bites_of_south/View/Menu/item_detail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MenuManagementScreen extends StatefulWidget {
  @override
  _MenuManagementScreenState createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends State<MenuManagementScreen> {
  List<ItemDetailsModal> _itemDetails = [];
  bool _isLoading = false;
  bool _isSelectionMode = false;
  Set<String> _selectedItems = {};

  @override
  void initState() {
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
        _itemDetails = snapshot.docs
            .map((doc) => ItemDetailsModal.fromFirestore(doc))
            .toList();
      });
    } catch (e) {
      print("Error fetching items: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteSelectedItems() async {
    setState(() {
      _isLoading = true;
    });

    try {
      for (String itemId in _selectedItems) {
        await FirebaseFirestore.instance
            .collection('menu')
            .doc(itemId)
            .delete();
      }
      _selectedItems.clear();
      _fetchMenuItems();
    } catch (e) {
      print("Error deleting items: $e");
    } finally {
      setState(() {
        _isLoading = false;
        _isSelectionMode = false;
      });
    }
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    _fetchMenuItems();
  }

  @override
  void didUpdateWidget(covariant MenuManagementScreen oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    _fetchMenuItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Menu Management"),
        actions: [
          if (_isSelectionMode)
            IconButton(
              icon: Icon(Icons.delete_forever),
              onPressed: _selectedItems.isEmpty
                  ? null
                  : () {
                      _deleteSelectedItems();
                    },
            ),
          // IconButton(
          //   icon: Icon(_isSelectionMode ? Icons.close : Icons.select_all),
          //   onPressed: () {
          //     setState(() {
          //       _isSelectionMode = !_isSelectionMode;
          //       if (!_isSelectionMode) _selectedItems.clear();
          //     });
          //   },
          // ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _isSelectionMode
                ? IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _isSelectionMode = false;
                        _selectedItems.clear();
                      });
                    },
                  )
                : GestureDetector(
                    onTap: () {
                      setState(() {
                        _isSelectionMode = true;
                      });
                    },
                    child: Text(
                      "Select",
                      style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: MediaQuery.of(context).size.width * 0.038),
                    ),
                  ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _itemDetails.isEmpty
              ? Center(child: Text("No items available"))
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: _itemDetails.length,
                    itemBuilder: (context, index) {
                      final menuItem = _itemDetails[index];
                      final isSelected = _selectedItems.contains(menuItem.id);

                      return GestureDetector(
                        onTap: _isSelectionMode
                            ? () {
                                setState(() {
                                  if (isSelected) {
                                    _selectedItems.remove(menuItem.id);
                                  } else {
                                    _selectedItems.add(menuItem.id);
                                  }
                                });
                              }
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ItemDetail(itemDetailsModal: menuItem),
                                  ),
                                );
                              },
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                                image: DecorationImage(
                                  image: NetworkImage(menuItem.imageUrl),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            if (_isSelectionMode)
                              Positioned(
                                top: 10,
                                right: 10,
                                child: CircleAvatar(
                                  backgroundColor: Colors.white,
                                  child: Icon(
                                    isSelected
                                        ? Icons.check_circle
                                        : Icons.radio_button_unchecked,
                                    color:
                                        isSelected ? Colors.green : Colors.grey,
                                  ),
                                ),
                              ),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                color: Colors.black.withOpacity(0.5),
                                padding: EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
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
      ),
    );
  }
}
