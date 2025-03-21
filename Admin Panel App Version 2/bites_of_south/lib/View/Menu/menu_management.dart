// import 'package:bites_of_south/Modal/item_details_modal.dart';
// import 'package:bites_of_south/View/Menu/add_item_to_menu.dart';
// import 'package:bites_of_south/View/Menu/item_detail.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:lottie/lottie.dart';
// import 'package:auto_size_text/auto_size_text.dart';

// // MenuManagementScreen is a StatefulWidget that manages the menu items.
// class MenuManagementScreen extends StatefulWidget {
//   const MenuManagementScreen({super.key});

//   @override
//   _MenuManagementScreenState createState() => _MenuManagementScreenState();
// }

// class _MenuManagementScreenState extends State<MenuManagementScreen> {
//   // List to store all menu items fetched from Firestore.
//   List<ItemDetailsModal> _itemDetails = [];

//   // Map to group menu items by their category.
//   Map<String, List<ItemDetailsModal>> _groupedItems = {};

//   // Boolean to track if data is being loaded.
//   bool _isLoading = false;

//   // Boolean to track if the selection mode is active (for deleting items).
//   bool _isSelectionMode = false;

//   // Set to store the IDs of selected items for deletion.
//   final Set<String> _selectedItems = {};

//   // Controller for the search text field.
//   final TextEditingController _searchController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     // Fetch menu items when the widget is initialized.
//     _fetchMenuItems();
//     // Add a listener to the search controller to filter items based on search text.
//     _searchController.addListener(_filterItems);
//   }

//   @override
//   void dispose() {
//     // Dispose the search controller to avoid memory leaks.
//     _searchController.dispose();
//     super.dispose();
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     // Fetch menu items again when dependencies change.
//     _fetchMenuItems();
//   }

//   // Function to fetch menu items from Firestore.
//   Future<void> _fetchMenuItems() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       // Fetch all documents from the 'menu' collection in Firestore.
//       final snapshot =
//           await FirebaseFirestore.instance.collection('menu').get();
//       setState(() {
//         // Convert Firestore documents to ItemDetailsModal objects.
//         _itemDetails = snapshot.docs
//             .map((doc) => ItemDetailsModal.fromFirestore(doc))
//             .toList();
//         // Group the items by their category.
//         _groupItemsByCategory();
//       });
//     } catch (e) {
//       print("Error fetching items: $e");
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   // Function to group menu items by their category.
//   void _groupItemsByCategory() {
//     _groupedItems.clear();
//     for (var item in _itemDetails) {
//       if (_groupedItems.containsKey(item.category)) {
//         _groupedItems[item.category]!.add(item);
//       } else {
//         _groupedItems[item.category] = [item];
//       }
//     }
//   }

//   // Function to filter menu items based on the search text.
//   void _filterItems() {
//     setState(() {
//       if (_searchController.text.isEmpty) {
//         // If the search text is empty, show all items grouped by category.
//         _groupItemsByCategory();
//       } else {
//         // Otherwise, filter items that match the search text.
//         _groupedItems.clear();
//         for (var item in _itemDetails) {
//           if (item.title
//               .toLowerCase()
//               .contains(_searchController.text.toLowerCase())) {
//             if (_groupedItems.containsKey(item.category)) {
//               _groupedItems[item.category]!.add(item);
//             } else {
//               _groupedItems[item.category] = [item];
//             }
//           }
//         }
//       }
//     });
//   }

//   // Function to delete selected items from Firestore.
//   Future<void> _deleteSelectedItems() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       // Delete each selected item from Firestore.
//       for (String itemId in _selectedItems) {
//         await FirebaseFirestore.instance
//             .collection('menu')
//             .doc(itemId)
//             .delete();
//       }
//       // Clear the selected items set and refresh the menu items.
//       _selectedItems.clear();
//       _fetchMenuItems();
//     } catch (e) {
//       print("Error deleting items: $e");
//     } finally {
//       setState(() {
//         _isLoading = false;
//         _isSelectionMode = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: Text("Menu Management"),
//         actions: [
//           // Show delete button if in selection mode.
//           if (_isSelectionMode)
//             IconButton(
//               icon: Icon(Icons.delete_forever),
//               onPressed: _selectedItems.isEmpty
//                   ? null
//                   : () {
//                       _deleteSelectedItems();
//                     },
//             ),
//           // Show close button if in selection mode, otherwise show select button.
//           _isSelectionMode
//               ? IconButton(
//                   icon: Icon(Icons.close),
//                   onPressed: () {
//                     setState(() {
//                       _isSelectionMode = false;
//                       _selectedItems.clear();
//                     });
//                   },
//                 )
//               : GestureDetector(
//                   onTap: () {
//                     setState(() {
//                       _isSelectionMode = true;
//                     });
//                   },
//                   child: Padding(
//                     padding: const EdgeInsets.only(right: 8.0),
//                     child: Text(
//                       "Select",
//                       style: TextStyle(
//                           fontWeight: FontWeight.normal,
//                           fontSize: MediaQuery.of(context).size.height * 0.018),
//                     ),
//                   ),
//                 ),
//         ],
//         bottom: PreferredSize(
//           preferredSize: Size.fromHeight(56.0),
//           child: Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: TextField(
//               controller: _searchController,
//               decoration: InputDecoration(
//                 hintStyle: TextStyle(fontSize: 14),
//                 hintText: "Search menu items...",
//                 suffixIcon: Icon(Icons.search),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(18.0),
//                   borderSide: BorderSide.none,
//                 ),
//                 filled: true,
//                 fillColor: Colors.grey[200],
//               ),
//             ),
//           ),
//         ),
//       ),
//       body: _isLoading
//           ? Center(
//               child: SizedBox(
//                 height: MediaQuery.of(context).size.height * 0.2,
//                 width: MediaQuery.of(context).size.height * 0.2,
//                 child: Lottie.asset('assets/loadin.json'),
//               ),
//             )
//           : _groupedItems.isEmpty
//               ? Center(child: Text("No items available"))
//               : Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: ListView(
//                     children: _groupedItems.entries.map((entry) {
//                       return Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // Display the category name.
//                           Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: Text(
//                               entry.key,
//                               style: TextStyle(
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                           // Display the items in a grid view.
//                           GridView.builder(
//                             shrinkWrap: true,
//                             physics: NeverScrollableScrollPhysics(),
//                             gridDelegate:
//                                 SliverGridDelegateWithFixedCrossAxisCount(
//                               crossAxisCount: 2,
//                               crossAxisSpacing: 12,
//                               mainAxisSpacing: 12,
//                               childAspectRatio: MediaQuery.of(context)
//                                       .size
//                                       .width /
//                                   (MediaQuery.of(context).size.height / 1.8),
//                             ),
//                             itemCount: entry.value.length,
//                             itemBuilder: (context, index) {
//                               final menuItem = entry.value[index];
//                               final isSelected =
//                                   _selectedItems.contains(menuItem.id);

//                               return GestureDetector(
//                                 onTap: _isSelectionMode
//                                     ? () {
//                                         // Toggle selection of the item.
//                                         setState(() {
//                                           if (isSelected) {
//                                             _selectedItems.remove(menuItem.id);
//                                           } else {
//                                             _selectedItems.add(menuItem.id);
//                                           }
//                                         });
//                                       }
//                                     : () async {
//                                         // Navigate to the item detail screen.
//                                         await Navigator.push(
//                                           context,
//                                           MaterialPageRoute(
//                                             builder: (context) => ItemDetail(
//                                                 itemDetailsModal: menuItem),
//                                           ),
//                                         );
//                                         _fetchMenuItems(); // Refresh after coming back
//                                       },
//                                 child: Stack(
//                                   children: [
//                                     Card(
//                                       elevation: 4,
//                                       color: Colors.white,
//                                       child: Column(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.start,
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                           // Display the item image.
//                                           Expanded(
//                                             child: ClipRRect(
//                                               borderRadius: BorderRadius.only(
//                                                 topLeft: Radius.circular(8),
//                                                 topRight: Radius.circular(8),
//                                               ),
//                                               child: CachedNetworkImage(
//                                                 imageUrl: menuItem.imageUrl,
//                                                 fit: BoxFit.cover,
//                                                 width: double.infinity,
//                                                 height: double.infinity,
//                                                 placeholder: (context, url) =>
//                                                     Center(
//                                                   child: SizedBox(
//                                                     height:
//                                                         MediaQuery.of(context)
//                                                                 .size
//                                                                 .height *
//                                                             0.2,
//                                                     width:
//                                                         MediaQuery.of(context)
//                                                                 .size
//                                                                 .height *
//                                                             0.2,
//                                                     child: Lottie.asset(
//                                                         'assets/loadin.json'),
//                                                   ),
//                                                 ),
//                                                 errorWidget:
//                                                     (context, url, error) =>
//                                                         Icon(Icons.error),
//                                               ),
//                                             ),
//                                           ),
//                                           // Display the item title and price.

//                                           Padding(
//                                             padding: const EdgeInsets.all(8.0),
//                                             child: Column(
//                                               crossAxisAlignment:
//                                                   CrossAxisAlignment.start,
//                                               children: [
//                                                 SizedBox(
//                                                   height:
//                                                       25, // Fixed height to keep image height consistent
//                                                   child: AutoSizeText(
//                                                     menuItem.title,
//                                                     style: TextStyle(
//                                                       fontSize:
//                                                           18, // Default size
//                                                       fontWeight:
//                                                           FontWeight.normal,
//                                                     ),
//                                                     maxLines: 1,
//                                                     minFontSize:
//                                                         16, // Minimum size to shrink to
//                                                     overflow:
//                                                         TextOverflow.ellipsis,
//                                                   ),
//                                                 ),
//                                                 Text(
//                                                   "₹${menuItem.price}",
//                                                   style: TextStyle(
//                                                     fontSize: 12,
//                                                     color: Colors.grey,
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                     // Show a selection indicator if in selection mode.
//                                     if (_isSelectionMode)
//                                       Positioned(
//                                         top: 10,
//                                         right: 10,
//                                         child: CircleAvatar(
//                                           backgroundColor: Colors.white,
//                                           child: Icon(
//                                             isSelected
//                                                 ? Icons.check_circle
//                                                 : Icons.radio_button_unchecked,
//                                             color: isSelected
//                                                 ? Colors.green
//                                                 : Colors.grey,
//                                           ),
//                                         ),
//                                       ),
//                                   ],
//                                 ),
//                               );
//                             },
//                           ),
//                         ],
//                       );
//                     }).toList(),
//                   ),
//                 ),
//       // Floating action button to add a new item to the menu.
//       floatingActionButton: FloatingActionButton(
//         backgroundColor: Colors.white,
//         onPressed: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => AddItemToMenu()),
//           ).then((_) {
//             _fetchMenuItems();
//           });
//         },
//         child: Icon(Icons.add),
//       ),
//     );
//   }
// }

import 'package:bites_of_south/View/Menu/add_item_to_menu.dart';
import 'package:bites_of_south/View/Menu/item_detail.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:bites_of_south/Controller/Menu/menu_load_auth.dart';
import 'package:provider/provider.dart'; // New import

class MenuManagementScreen extends StatefulWidget {
  const MenuManagementScreen({super.key});

  @override
  _MenuManagementScreenState createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends State<MenuManagementScreen> {
  bool _isSelectionMode = false;
  final Set<String> _selectedItems = {};
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MenuLoadAuth>(context, listen: false).fetchMenuItems();
    });
    _searchController.addListener(() {
      Provider.of<MenuLoadAuth>(context, listen: false)
          .filterItems(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Provider.of<MenuLoadAuth>(context, listen: false).fetchMenuItems();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MenuLoadAuth>(
      builder: (context, menuProvider, child) {
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
                          menuProvider.deleteSelectedItems(_selectedItems);
                          setState(() {
                            _isSelectionMode = false;
                            _selectedItems.clear();
                          });
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
                              fontSize:
                                  MediaQuery.of(context).size.height * 0.018),
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
          body: menuProvider.isLoading
              ? Center(
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.2,
                    width: MediaQuery.of(context).size.height * 0.2,
                    child: Lottie.asset('assets/loadin.json'),
                  ),
                )
              : menuProvider.groupedItems.isEmpty
                  ? Center(child: Text("No items available"))
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListView(
                        children:
                            menuProvider.groupedItems.entries.map((entry) {
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
                                          (MediaQuery.of(context).size.height /
                                              1.8),
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
                                                _selectedItems
                                                    .remove(menuItem.id);
                                              } else {
                                                _selectedItems.add(menuItem.id);
                                              }
                                            });
                                          }
                                        : () async {
                                            await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ItemDetail(
                                                        itemDetailsModal:
                                                            menuItem),
                                              ),
                                            );
                                            menuProvider.fetchMenuItems();
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
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    topLeft: Radius.circular(8),
                                                    topRight:
                                                        Radius.circular(8),
                                                  ),
                                                  child: CachedNetworkImage(
                                                    imageUrl: menuItem.imageUrl,
                                                    fit: BoxFit.cover,
                                                    width: double.infinity,
                                                    height: double.infinity,
                                                    placeholder:
                                                        (context, url) =>
                                                            Center(
                                                      child: SizedBox(
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            0.2,
                                                        width: MediaQuery.of(
                                                                    context)
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
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    SizedBox(
                                                      height: 25,
                                                      child: AutoSizeText(
                                                        menuItem.title,
                                                        style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                        ),
                                                        maxLines: 1,
                                                        minFontSize: 16,
                                                        overflow: TextOverflow
                                                            .ellipsis,
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
                                                    : Icons
                                                        .radio_button_unchecked,
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
                    ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddItemToMenu()),
              ).then((_) {
                menuProvider.fetchMenuItems();
              });
            },
            child: Icon(Icons.add),
          ),
        );
      },
    );
  }
}
