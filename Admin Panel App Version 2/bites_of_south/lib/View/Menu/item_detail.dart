import 'package:bites_of_south/Modal/item_details_modal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ItemDetail extends StatefulWidget {
  final ItemDetailsModal itemDetailsModal;
  const ItemDetail({super.key, required this.itemDetailsModal});

  @override
  State<ItemDetail> createState() => _ItemDetailState();
}

class _ItemDetailState extends State<ItemDetail> {
  @override
  Widget build(BuildContext context) {
    ItemDetailsModal itemData = widget.itemDetailsModal;

    return Scaffold(
      appBar: AppBar(
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
                  ? Image.network(itemData.imageUrl,
                      height: MediaQuery.of(context).size.height * 0.45,
                      width: double.infinity,
                      fit: BoxFit.cover)
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
                "Category: ${itemData.category ?? 'Unknown'}",
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                "Making Time: ${itemData.makingTime ?? 'Unknown'}",
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                "Rating: ${itemData.rating ?? '0'}",
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showEditDialog(context, itemData);
        },
        child: const Icon(Icons.edit),
      ),
    );
  }

  void _showEditDialog(BuildContext context, ItemDetailsModal itemData) {
    final TextEditingController titleController =
        TextEditingController(text: itemData.title);
    final TextEditingController priceController =
        TextEditingController(text: itemData.price.toString());
    final TextEditingController descriptionController =
        TextEditingController(text: itemData.description);
    final TextEditingController categoryController =
        TextEditingController(text: itemData.category);
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
                TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(labelText: "Category"),
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
                  'category': categoryController.text,
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
