import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final CollectionReference inventoryRef =
  FirebaseFirestore.instance.collection('inventory');

  Future<void> _addInventoryItem(String itemName) async {
    final itemSnapshot = await inventoryRef.doc(itemName).get();
    if (itemSnapshot.exists) {
      // If item exists, increment the quantity
      await inventoryRef.doc(itemName).update({
        'quantity': FieldValue.increment(1),
      });
    } else {
      // Add a new item with a quantity of 1
      await inventoryRef.doc(itemName).set({
        'name': itemName,
        'quantity': 1,
      });
    }
  }

  void _showAddInventoryDialog() {
    final TextEditingController nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Add Inventory Item"),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(hintText: "Enter item name"),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await _addInventoryItem(nameController.text.trim());
                Navigator.of(context).pop();
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Inventory")),
      body: StreamBuilder<QuerySnapshot>(
        stream: inventoryRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Text('Error loading inventory');
          if (!snapshot.hasData) return const CircularProgressIndicator();

          final items = snapshot.data!.docs;

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                title: Text(item['name']),
                subtitle: Text('Quantity: ${item['quantity']}'),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddInventoryDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
