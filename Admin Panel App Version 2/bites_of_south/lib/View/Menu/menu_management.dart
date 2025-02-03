import 'package:bites_of_south/Modal/item_details_modal.dart';
import 'package:bites_of_south/View/Menu/add_item_to_menu.dart';
import 'package:bites_of_south/View/Menu/item_detail.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class MenuManagementScreen extends StatefulWidget {
  const MenuManagementScreen({super.key});

  @override
  _MenuManagementScreenState createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends State<MenuManagementScreen> {
  List<ItemDetailsModal> _itemDetails = [];
  Map<String, List<ItemDetailsModal>> _groupedItems = {};
  bool _isLoading = false;
  bool _isSelectionMode = false;
  final Set<String> _selectedItems = {};
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchMenuItems();
    _searchController.addListener(_filterItems);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchMenuItems(); // Automatically refreshes when returning to this page
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
        _groupItemsByCategory();
      });
    } catch (e) {
      print("Error fetching items: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _groupItemsByCategory() {
    _groupedItems.clear();
    for (var item in _itemDetails) {
      if (_groupedItems.containsKey(item.category)) {
        _groupedItems[item.category]!.add(item);
      } else {
        _groupedItems[item.category] = [item];
      }
    }
  }

  void _filterItems() {
    setState(() {
      if (_searchController.text.isEmpty) {
        _groupItemsByCategory();
      } else {
        _groupedItems.clear();
        for (var item in _itemDetails) {
          if (item.title
              .toLowerCase()
              .contains(_searchController.text.toLowerCase())) {
            if (_groupedItems.containsKey(item.category)) {
              _groupedItems[item.category]!.add(item);
            } else {
              _groupedItems[item.category] = [item];
            }
          }
        }
      }
    });
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
          _isSelectionMode
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
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(
                      "Select",
                      style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: MediaQuery.of(context).size.height * 0.018),
                    ),
                  ),
                ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(56.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintStyle: TextStyle(fontSize: 14),
                hintText: "Search menu items...",
                suffixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? Center(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.2,
                width: MediaQuery.of(context).size.height * 0.2,
                child: Lottie.asset('assets/loadin.json'),
              ),
            )
          : _groupedItems.isEmpty
              ? Center(child: Text("No items available"))
              : ListView(
                  children: _groupedItems.entries.map((entry) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            entry.key,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio:
                                MediaQuery.of(context).size.width /
                                    (MediaQuery.of(context).size.height / 1.8),
                          ),
                          itemCount: entry.value.length,
                          itemBuilder: (context, index) {
                            final menuItem = entry.value[index];
                            final isSelected =
                                _selectedItems.contains(menuItem.id);

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
                                  : () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ItemDetail(
                                              itemDetailsModal: menuItem),
                                        ),
                                      );
                                      _fetchMenuItems(); // Refresh after coming back
                                    },
                              child: Stack(
                                children: [
                                  Card(
                                    elevation: 4,
                                    color: Colors.white,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(8),
                                              topRight: Radius.circular(8),
                                            ),
                                            child: CachedNetworkImage(
                                              imageUrl: menuItem.imageUrl,
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              height: double.infinity,
                                              placeholder: (context, url) =>
                                                  Center(
                                                child: SizedBox(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.2,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.2,
                                                  child: Lottie.asset(
                                                      'assets/loadin.json'),
                                                ),
                                              ),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Icon(Icons.error),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                menuItem.title,
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.normal,
                                                ),
                                              ),
                                              Text(
                                                "₹${menuItem.price}",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
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
                                          color: isSelected
                                              ? Colors.green
                                              : Colors.grey,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  }).toList(),
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
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
