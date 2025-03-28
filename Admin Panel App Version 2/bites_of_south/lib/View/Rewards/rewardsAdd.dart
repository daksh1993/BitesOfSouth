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
          SnackBar(content: Text("Please fill all fields and select an item")));
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

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Reward added successfully!")));

    _nameController.clear();
    _pointsController.clear();
    _discountController.clear();
    selectedItems.clear();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Reward")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: "Reward Name")),
            TextField(
                controller: _pointsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Points Required")),
            DropdownButton<String>(
              value: discountType,
              items: ["free"].map((type) {
                return DropdownMenuItem(
                    enabled: type == "free",
                    value: type,
                    child: Text(type.toUpperCase()));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  discountType = value!;
                });
              },
            ),
            if (discountType == "percentage")
              TextField(
                  controller: _discountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: "Discount %")),
            SwitchListTile(
              title: Text("Is Combo?"),
              value: isCombo,
              onChanged: (value) {
                setState(() {
                  isCombo = value;
                  if (!isCombo && selectedItems.length > 1) {
                    selectedItems = [selectedItems.first]; // Keep only one
                  }
                });
              },
            ),
            SizedBox(height: 10),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                  labelText: "Search Menu Items",
                  prefixIcon: Icon(Icons.search)),
              onChanged: (query) {
                setState(() {});
              },
            ),
            Expanded(
              child: categorizedMenu.isEmpty
                  ? Center(child: Text("No items found"))
                  : ListView(
                      children: categorizedMenu.keys.map((category) {
                        List<QueryDocumentSnapshot> items =
                            categorizedMenu[category]!;
                        List<QueryDocumentSnapshot> filteredItems =
                            items.where((item) {
                          String name = item["title"].toLowerCase();
                          return name
                              .contains(_searchController.text.toLowerCase());
                        }).toList();

                        if (filteredItems.isEmpty) return SizedBox.shrink();

                        return ExpansionTile(
                          title: Text(category,
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          children: filteredItems.map((item) {
                            String itemId = item.id;
                            String itemName = item["title"];

                            return CheckboxListTile(
                              title: Text(itemName),
                              subtitle: Text("₹${item["price"]}"),
                              value: selectedItems.contains(itemId),
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
                            );
                          }).toList(),
                        );
                      }).toList(),
                    ),
            ),
            ElevatedButton(
              onPressed: () => _saveReward(),
              child: Text("Publish Reward"),
            )
          ],
        ),
      ),
    );
  }
}
