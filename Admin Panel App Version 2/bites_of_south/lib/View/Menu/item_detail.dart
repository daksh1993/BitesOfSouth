import 'package:bites_of_south/Modal/item_details_modal.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ItemDetail extends StatefulWidget {
  final ItemDetailsModal itemDetailsModal;
  const ItemDetail({super.key, required this.itemDetailsModal});

  @override
  State<ItemDetail> createState() => _ItemDetailState();
}

class _ItemDetailState extends State<ItemDetail> {
  late bool isAvailable; // Store current availability status
  @override
  void initState() {
    super.initState();
    isAvailable = widget.itemDetailsModal.isAvailable;
  }

  @override
  Widget build(BuildContext context) {
    ItemDetailsModal itemData = widget.itemDetailsModal;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Item Detail"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ignore: unnecessary_null_comparison
              itemData.imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        imageUrl: itemData.imageUrl,
                        height: MediaQuery.of(context).size.height * 0.40,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(),
                        ),
                        errorWidget: (context, url, error) => Container(
                          height: MediaQuery.of(context).size.height * 0.45,
                          width: double.infinity,
                          color: Colors.grey[300],
                          child: Center(child: Text("Image Load Failed")),
                        ),
                      ),
                    )
                  : Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: const Center(child: Text("No Image Available")),
                    ),
              const SizedBox(height: 16),
              Text(
                itemData.title,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "₹${itemData.price}",
                style: const TextStyle(fontSize: 20, color: Colors.green),
              ),
              const SizedBox(height: 16),
              Text(
                itemData.description,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Text(
                "Category: ${itemData.category}",
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                "Making Time: ${itemData.makingTime}",
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                "Rating: ${itemData.rating}",
                style: const TextStyle(fontSize: 16),
              ),
              SwitchListTile(
                title: Text("Item Availability"),
                subtitle: Text(isAvailable ? "Enabled" : "Disabled"),
                value: isAvailable,
                activeColor: Colors.green,
                inactiveThumbColor: Colors.red,
                contentPadding: const EdgeInsets.all(0),
                onChanged: (value) {
                  _confirmAvailabilityChange(context, value);
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.grey[100],
        onPressed: () {
          _showEditDialog(context, itemData);
        },
        child: const Icon(Icons.edit),
      ),
    );
  }

  void _confirmAvailabilityChange(BuildContext context, bool newValue) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirm Change"),
        content: Text(
            "Are you sure you want to ${newValue ? 'enable' : 'disable'} this item?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              await _updateAvailability(newValue);
            },
            child: Text("Confirm"),
          ),
        ],
      ),
    );
  }

  // Update Firestore
  Future<void> _updateAvailability(bool newValue) async {
    try {
      await FirebaseFirestore.instance
          .collection('menu')
          .doc(widget.itemDetailsModal.id)
          .update({'isAvailable': newValue});

      setState(() {
        isAvailable = newValue; // Update UI
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Availability updated successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating availability: $e")),
      );
    }
  }

  void _showEditDialog(BuildContext context, ItemDetailsModal itemData) {
    final TextEditingController titleController =
        TextEditingController(text: itemData.title);
    final TextEditingController priceController =
        TextEditingController(text: itemData.price.toString());
    final TextEditingController descriptionController =
        TextEditingController(text: itemData.description);
    List<String> categories = [
      'Dosa',
      'Uttapam',
      'Idli & Vada',
      'Thali',
      'Special Dosa',
      'Beverage'
    ];

    String selectedCategory =
        categories.contains(itemData.category) ? itemData.category : 'Default';

    // final TextEditingController categoryController =
    //     TextEditingController(text: itemData.category);
    final TextEditingController makingTimeController =
        TextEditingController(text: itemData.makingTime.toString());
    final TextEditingController ratingController =
        TextEditingController(text: itemData.rating.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Item"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: "Title"),
                ),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: "Price"),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: "Description"),
                ),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  items: categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    selectedCategory = value!;
                  },
                  decoration: InputDecoration(labelText: "Category"),
                ),
                TextField(
                  controller: makingTimeController,
                  decoration: const InputDecoration(labelText: "Making Time"),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: ratingController,
                  decoration: const InputDecoration(labelText: "Rating"),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                // Collect updated data
                final updatedItem = {
                  'title': titleController.text,
                  'price': (priceController.text),
                  'description': descriptionController.text,
                  'category': selectedCategory ?? 'Default',
                  'makingTime': (makingTimeController.text),
                  'rating': (ratingController.text),
                };

                try {
                  // Update Firestore
                  await FirebaseFirestore.instance
                      .collection('menu')
                      .doc(itemData.id)
                      .update(updatedItem);

                  Navigator.pop(context); // Close the dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Item updated successfully!")),
                  );

                  // Update local state
                  setState(() {
                    itemData.title = updatedItem['title'] as String;
                    itemData.price = updatedItem['price'] as String;
                    itemData.description = updatedItem['description'] as String;
                    itemData.category = updatedItem['category'] as String;
                    itemData.makingTime = updatedItem['makingTime'] as String;
                    itemData.rating = updatedItem['rating'] as String;
                  });
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: ${e.toString()}")),
                  );
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }
}
