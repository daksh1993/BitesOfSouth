import 'package:bites_of_south/Modal/item_details.dart';
import 'package:flutter/material.dart';

class ItemDetail extends StatefulWidget {
  final ItemDetailsModal itemDetailsModal;
  const ItemDetail({super.key, required this.itemDetailsModal});

  @override
  State<ItemDetail> createState() => _ItemDetailState();
}

class _ItemDetailState extends State<ItemDetail> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ItemDetailsModal _itemData = widget.itemDetailsModal;

    return Scaffold(
      appBar: AppBar(
        title: Text("Item Detail"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _itemData.imageUrl != null
                ? Image.network(_itemData.imageUrl,
                    height: MediaQuery.of(context).size.height * 0.45,
                    width: double.infinity,
                    fit: BoxFit.cover)
                : Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: Center(child: Text("No Image Available")),
                  ),
            SizedBox(height: 16),
            Text(
              _itemData.title ?? 'No Title',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "₹${_itemData.price ?? '0'}",
              style: TextStyle(fontSize: 20, color: Colors.green),
            ),
            SizedBox(height: 16),
            Text(
              _itemData.description ?? 'No Description',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              "Category: ${_itemData.category ?? 'Unknown'}",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              "Making Time: ${_itemData.makingTime ?? 'Unknown'}",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              "Rating: ${_itemData!.rating ?? '0'}",
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print("Printing from details screen: " + _itemData.id);
        },
        child: Icon(Icons.edit),
      ),
    );
  }
}
