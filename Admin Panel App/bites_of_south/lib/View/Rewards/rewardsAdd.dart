import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddRewardScreen extends StatefulWidget {
  @override
  _AddRewardScreenState createState() => _AddRewardScreenState();
}

class _AddRewardScreenState extends State<AddRewardScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _pointsController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  bool isCombo = false;
  String discountType = "free";
  List<String> selectedItems = [];
  Map<String, List<QueryDocumentSnapshot>> categorizedMenu = {};

  @override
  void initState() {
    super.initState();
    _fetchMenuItems();
  }

  Future<void> _fetchMenuItems() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection("menu").get();
    Map<String, List<QueryDocumentSnapshot>> categorized = {};

    for (var doc in snapshot.docs) {
      String category = doc["category"] ?? "Others";
      if (!categorized.containsKey(category)) {
        categorized[category] = [];
      }
      categorized[category]!.add(doc);
    }

    setState(() {
      categorizedMenu = categorized;
    });
  }

  Future<void> _saveReward() async {
    if (_nameController.text.isEmpty ||
        _pointsController.text.isEmpty ||
        selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please fill all fields and select an item"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    await FirebaseFirestore.instance.collection("rewards").doc().set({
      "name": _nameController.text,
      "requiredPoints": int.parse(_pointsController.text),
      "discountType": discountType,
      "discountValue": discountType == "percentage"
          ? int.parse(_discountController.text)
          : 100,
      "isCombo": isCombo,
      "menuItemId": isCombo ? selectedItems : selectedItems[0],
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Reward added successfully!"),
        backgroundColor: Color(0xFF4CAF50),
      ),
    );

    _nameController.clear();
    _pointsController.clear();
    _discountController.clear();
    selectedItems.clear();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text(
          "Add Reward",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFF4CAF50),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Side-by-side Reward Name and Points Required
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _nameController,
                    label: "Reward Name",
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: _pointsController,
                    label: "Points Required",
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            // Discount Type Dropdown
            _buildDropdown(),
            SizedBox(height: 12),
            // Discount % (if applicable)
            if (discountType == "percentage")
              _buildTextField(
                controller: _discountController,
                label: "Discount %",
                keyboardType: TextInputType.number,
              ),
            if (discountType == "percentage") SizedBox(height: 12),
            // Is Combo Switch
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: SwitchListTile(
                title: Text(
                  "Is Combo?",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                value: isCombo,
                activeColor: Color(0xFF4CAF50),
                onChanged: (value) {
                  setState(() {
                    isCombo = value;
                    if (!isCombo && selectedItems.length > 1) {
                      selectedItems = [selectedItems.first];
                    }
                  });
                },
              ),
            ),
            SizedBox(height: 12),
            // Search Bar
            _buildTextField(
              controller: _searchController,
              label: "Search Menu Items",
              prefixIcon: Icon(Icons.search, color: Color(0xFF4CAF50)),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear, color: Color(0xFF4CAF50)),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                        });
                      },
                    )
                  : null,
            ),
            SizedBox(height: 12),
            // Menu Items
            Expanded(
              child: categorizedMenu.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      itemCount: categorizedMenu.keys.length,
                      itemBuilder: (context, index) {
                        String category = categorizedMenu.keys.elementAt(index);
                        List<QueryDocumentSnapshot> items =
                            categorizedMenu[category]!;
                        List<QueryDocumentSnapshot> filteredItems =
                            items.where((item) {
                          String name = item["title"].toLowerCase();
                          return name
                              .contains(_searchController.text.toLowerCase());
                        }).toList();

                        if (filteredItems.isEmpty) return SizedBox.shrink();

                        return _buildCategoryCard(category, filteredItems);
                      },
                    ),
            ),
          ],
        ),
      ),
      // Sticky Publish Button
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(16),
        child: _buildPublishButton(),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    Icon? prefixIcon,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Color(0xFF388E3C)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Color(0xFF4CAF50)),
        ),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
      ),
      onChanged:
          controller == _searchController ? (value) => setState(() {}) : null,
    );
  }

  Widget _buildDropdown() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: DropdownButton<String>(
          value: discountType,
          isExpanded: true,
          underline: SizedBox(),
          items: ["free"].map((type) {
            return DropdownMenuItem(
              enabled: type == "free",
              value: type,
              child: Text(
                type.toUpperCase(),
                style: TextStyle(
                  color: type == "free" ? Color(0xFF4CAF50) : Colors.grey,
                  fontWeight:
                      type == "free" ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              discountType = value!;
            });
          },
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
      String category, List<QueryDocumentSnapshot> items) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      margin: EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(
          category,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF388E3C),
          ),
        ),
        iconColor: Color(0xFF4CAF50),
        children: items.map((item) {
          String itemId = item.id;
          String itemName = item["title"];
          double price =
              double.tryParse(item["price"]?.toString() ?? "0.0") ?? 0.0;

          return Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: CheckboxListTile(
              title: Text(
                itemName,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              subtitle: Text(
                "₹${price.toStringAsFixed(2)}",
                style: TextStyle(color: Colors.grey.shade600),
              ),
              value: selectedItems.contains(itemId),
              activeColor: Color(0xFF4CAF50),
              onChanged: (bool? selected) {
                setState(() {
                  if (isCombo) {
                    if (selected!) {
                      selectedItems.add(itemId);
                    } else {
                      selectedItems.remove(itemId);
                    }
                  } else {
                    selectedItems.clear();
                    if (selected!) {
                      selectedItems.add(itemId);
                    }
                  }
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            "No items found",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPublishButton() {
    return GestureDetector(
      onTapDown: (_) => setState(() {}),
      onTapUp: (_) => setState(() {}),
      child: AnimatedScale(
        scale: 1.0,
        duration: Duration(milliseconds: 100),
        child: ElevatedButton(
          onPressed: _saveReward,
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF4CAF50),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 4,
            shadowColor: Colors.black26,
          ),
          child: Text(
            "Publish Reward",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
