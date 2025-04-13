import 'package:bites_of_south/Controller/Menu/menu_load_auth.dart';
import 'package:bites_of_south/View/Menu/add_item_to_menu.dart';
import 'package:bites_of_south/View/Menu/item_detail.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:auto_size_text/auto_size_text.dart';

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
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final minDimension =
        screenWidth < screenHeight ? screenWidth : screenHeight;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final crossAxisCount =
        screenWidth > 800 ? (isLandscape ? 4 : 3) : (isLandscape ? 3 : 2);
    final padding = (minDimension * 0.04).clamp(12.0, 20.0); // 4% clamped
    final spacing = (minDimension * 0.03).clamp(8.0, 16.0); // 3% clamped

    return Consumer<MenuLoadAuth>(
      builder: (context, menuProvider, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(
              _isSelectionMode ? "${_selectedItems.length} Selected" : "Menu",
              style: TextStyle(
                fontSize: (minDimension * 0.055).clamp(18.0, 22.0),
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            backgroundColor: Colors.green[600],
            elevation: 2,
            actions: [
              if (_isSelectionMode)
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.white),
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
                      icon: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: (minDimension * 0.06).clamp(20.0, 24.0),
                      ),
                      onPressed: () {
                        setState(() {
                          _isSelectionMode = !_isSelectionMode;
                          if (!_isSelectionMode) _selectedItems.clear();
                        });
                      },
                    )
                  : GestureDetector(
                      onTap: () {
                        setState(() {
                          _isSelectionMode = !_isSelectionMode;
                          if (!_isSelectionMode) _selectedItems.clear();
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Select",
                          style: TextStyle(
                            fontSize: (minDimension * 0.045).clamp(14.0, 16.0),
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60.0),
              child: Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: padding, vertical: 8.0),
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(
                      fontSize: (minDimension * 0.045).clamp(14.0, 16.0)),
                  decoration: InputDecoration(
                    hintText: "Search items...",
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    prefixIcon: Icon(Icons.search, color: Colors.green[600]),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: Colors.green[600]),
                            onPressed: () => _searchController.clear(),
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
          ),
          body: SafeArea(
            child: menuProvider.isLoading
                ? Center(
                    child: Lottie.asset(
                      'assets/loadin.json',
                      width: minDimension * 0.2,
                      height: minDimension * 0.2,
                      fit: BoxFit.cover,
                    ),
                  )
                : menuProvider.groupedItems.isEmpty
                    ? _buildEmptyState(minDimension)
                    : RefreshIndicator(
                        onRefresh: () => menuProvider.fetchMenuItems(),
                        color: Colors.green[600],
                        child: ListView.builder(
                          padding: EdgeInsets.all(padding),
                          itemCount: menuProvider.groupedItems.length,
                          itemBuilder: (context, index) {
                            final entry = menuProvider.groupedItems.entries
                                .elementAt(index);
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: padding,
                                      top: spacing,
                                      bottom: spacing),
                                  child: Text(
                                    entry.key,
                                    style: TextStyle(
                                      fontSize: (minDimension * 0.06)
                                          .clamp(20.0, 24.0),
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                ),
                                GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    crossAxisSpacing: spacing,
                                    mainAxisSpacing: spacing,
                                    childAspectRatio: isLandscape ? 0.85 : 0.75,
                                  ),
                                  itemCount: entry.value.length,
                                  itemBuilder: (context, itemIndex) {
                                    final menuItem = entry.value[itemIndex];
                                    final isSelected =
                                        _selectedItems.contains(menuItem.id);

                                    return GestureDetector(
                                      onTap: () {
                                        HapticFeedback.selectionClick();
                                        if (_isSelectionMode) {
                                          setState(() {
                                            if (isSelected) {
                                              _selectedItems
                                                  .remove(menuItem.id);
                                            } else {
                                              _selectedItems.add(menuItem.id);
                                            }
                                          });
                                        } else {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ItemDetail(
                                                itemDetailsModal: menuItem,
                                              ),
                                            ),
                                          ).then((_) =>
                                              menuProvider.fetchMenuItems());
                                        }
                                      },
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 200),
                                        decoration: BoxDecoration(
                                          border: isSelected
                                              ? Border.all(
                                                  color: Colors.green[600]!,
                                                  width: 2)
                                              : null,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Card(
                                          elevation: 3,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Stack(
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          const BorderRadius
                                                              .vertical(
                                                        top:
                                                            Radius.circular(12),
                                                      ),
                                                      child: CachedNetworkImage(
                                                        imageUrl:
                                                            menuItem.imageUrl,
                                                        fit: BoxFit.cover,
                                                        width: double.infinity,
                                                        placeholder:
                                                            (context, url) =>
                                                                Container(
                                                          color:
                                                              Colors.grey[200],
                                                          child: Center(
                                                              child: Lottie.asset(
                                                                  "assets/loadin.json")),
                                                        ),
                                                        errorWidget: (context,
                                                                url, error) =>
                                                            Container(
                                                          color:
                                                              Colors.grey[200],
                                                          child: Icon(
                                                            Icons.fastfood,
                                                            color: Colors
                                                                .grey[500],
                                                            size:
                                                                (minDimension *
                                                                        0.08)
                                                                    .clamp(30.0,
                                                                        40.0),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.all(
                                                        padding * 0.6),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        SizedBox(
                                                          height:
                                                              (minDimension *
                                                                      0.06)
                                                                  .clamp(20.0,
                                                                      24.0),
                                                          child: AutoSizeText(
                                                            menuItem.title,
                                                            style: TextStyle(
                                                              fontSize:
                                                                  (minDimension *
                                                                          0.045)
                                                                      .clamp(
                                                                          15.0,
                                                                          17.0),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: Colors
                                                                  .grey[800],
                                                            ),
                                                            maxLines: 1,
                                                            minFontSize: 13,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                            height:
                                                                spacing * 0.3),
                                                        Text(
                                                          "₹${double.parse(menuItem.price).toStringAsFixed(2)}",
                                                          style: TextStyle(
                                                            fontSize:
                                                                (minDimension *
                                                                        0.035)
                                                                    .clamp(12.0,
                                                                        14.0),
                                                            color: Colors
                                                                .grey[600],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              if (_isSelectionMode)
                                                Positioned(
                                                  top: 8,
                                                  right: 8,
                                                  child: AnimatedScale(
                                                    scale:
                                                        isSelected ? 1.2 : 1.0,
                                                    duration: const Duration(
                                                        milliseconds: 200),
                                                    child: Checkbox(
                                                      value: isSelected,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          if (value == true) {
                                                            _selectedItems.add(
                                                                menuItem.id);
                                                          } else {
                                                            _selectedItems
                                                                .remove(menuItem
                                                                    .id);
                                                          }
                                                        });
                                                      },
                                                      activeColor:
                                                          Colors.green[600],
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4),
                                                      ),
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
                              ],
                            );
                          },
                        ),
                      ),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.green[600],
            foregroundColor: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddItemToMenu()),
              ).then((_) => menuProvider.fetchMenuItems());
            },
            child: const Icon(Icons.add, size: 28),
            elevation: 4,
            shape: const CircleBorder(),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(double minDimension) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fastfood,
            size: (minDimension * 0.15).clamp(60.0, 80.0),
            color: Colors.grey[400],
          ),
          SizedBox(height: minDimension * 0.04),
          Text(
            "Your Menu is Empty",
            style: TextStyle(
              fontSize: (minDimension * 0.055).clamp(18.0, 22.0),
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: minDimension * 0.02),
          Text(
            "Add new items to get started!",
            style: TextStyle(
              fontSize: (minDimension * 0.04).clamp(14.0, 16.0),
              color: Colors.grey[500],
            ),
          ),
          SizedBox(height: minDimension * 0.04),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddItemToMenu()),
              ).then((_) => Provider.of<MenuLoadAuth>(context, listen: false)
                  .fetchMenuItems());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[600],
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: minDimension * 0.08,
                vertical: minDimension * 0.03,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              "Add Item",
              style:
                  TextStyle(fontSize: (minDimension * 0.045).clamp(14.0, 16.0)),
            ),
          ),
        ],
      ),
    );
  }
}
