import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final CollectionReference inventoryRef = FirebaseFirestore.instance.collection('inventories');

  void _showAddInventoryDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController dateController = TextEditingController();
    final TextEditingController sizeController = TextEditingController(); // New controller for size

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Create Inventory"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(hintText: "Inventory Name"),
              ),
              TextField(
                controller: dateController,
                decoration: const InputDecoration(hintText: "Date (e.g. 2024-11-01)"),
              ),
              TextField(
                controller: sizeController,
                decoration: const InputDecoration(hintText: "Size (Max Items)"),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty ||
                    dateController.text.trim().isEmpty ||
                    sizeController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("All fields are required")),
                  );
                  return;
                }

                // Add inventory with a size limit
                await inventoryRef.add({
                  'name': nameController.text.trim(),
                  'date': dateController.text.trim(),
                  'quantity': 0, // Initial quantity is 0
                  'size': int.parse(sizeController.text.trim()), // Size is the limit
                });

                Navigator.of(context).pop();
              },
              child: const Text("Create"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  // Function to fetch number of items in an inventory
  Future<int> _getItemCount(String inventoryId) async {
    final itemsSnapshot = await FirebaseFirestore.instance
        .collection('inventories')
        .doc(inventoryId)
        .collection('items')
        .get();
    return itemsSnapshot.docs.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Inventories:',
          style: TextStyle(
            fontSize: 24, // Larger font size for better visibility
            fontWeight: FontWeight.w600, // Semi-bold text for emphasis
            color: Colors.green[700], // Text color to match the icon color
            decoration: TextDecoration.none, // Underline the text
            decorationColor: Colors.green[200], // Optional: sets the underline color
            decorationThickness: 2, // Optional: controls the thickness of the underline
          ),
        ),
        elevation: 0, // No elevation, for a flat design
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // Rounded corners
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: inventoryRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading inventories'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final inventories = snapshot.data!.docs;

          return inventories.isEmpty
              ? const Center(child: Text("No inventories created"))
              : ListView.builder(
            itemCount: inventories.length,
            itemBuilder: (context, index) {
              final inventory = inventories[index];
              final inventoryId = inventory.id;
              final inventoryName = inventory['name'];
              final size = inventory['size']; // Total size (max items)

              return FutureBuilder<int>(
                future: _getItemCount(inventoryId), // Get current item count
                builder: (context, itemCountSnapshot) {
                  if (!itemCountSnapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final currentItemCount = itemCountSnapshot.data!;

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(15),
                      title: Text(
                        inventoryName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Date: ${inventory['date']}'),
                          const SizedBox(height: 5),
                          // Display the number of items
                          Text('Size: $currentItemCount/$size'),
                        ],
                      ),
                      trailing: Icon(Icons.arrow_forward, color: Theme.of(context).primaryColor),
                      onTap: () => _openInventoryDetails(
                        inventoryId,
                        inventoryName,
                      ),
                    ),
                  );
                },
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

  void _openInventoryDetails(String inventoryId, String inventoryName) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => InventoryDetailsPage(
        inventoryId: inventoryId,
        inventoryName: inventoryName,
      ),
    ));
  }
}


class InventoryDetailsPage extends StatelessWidget {
  final String inventoryId;
  final String inventoryName;

  const InventoryDetailsPage({
    super.key,
    required this.inventoryId,
    required this.inventoryName,
  });

  Future<void> _deleteInventory(BuildContext context) async {
    final inventoryRef = FirebaseFirestore.instance.collection('inventories');
    final historyRef = FirebaseFirestore.instance.collection('inventory_history');

    final itemsSnapshot = await FirebaseFirestore.instance
        .collection('inventories')
        .doc(inventoryId)
        .collection('items')
        .get();

    List<Map<String, dynamic>> itemsData = [];
    for (var item in itemsSnapshot.docs) {
      itemsData.add(item.data() as Map<String, dynamic>); // Safely cast to Map<String, dynamic>
    }

    Map<String, dynamic> historyData = {
      'inventoryName': inventoryName,
      'date': DateTime.now().toString(),
      'items': itemsData,
    };

    WriteBatch batch = FirebaseFirestore.instance.batch();
    batch.set(
      historyRef.doc(inventoryId),
      historyData,
    );

    batch.delete(inventoryRef.doc(inventoryId));
    await batch.commit();

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Inventory deleted and moved to history")),
    );
  }

  Future<void> _showItemDetails(BuildContext context, Map<String, dynamic> item) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(item['label']),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Date: ${item['date']}'),
              Text('Time: ${item['time']}'),
              Text('Document ID: ${item['id']}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final itemsRef = FirebaseFirestore.instance
        .collection('inventories')
        .doc(inventoryId)
        .collection('items');
    final inventoryRef = FirebaseFirestore.instance.collection('inventories').doc(inventoryId);

    return Scaffold(
      appBar: AppBar(
        title: Text("$inventoryName Items"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text("Delete Inventory"),
                    content: const Text("Are you sure you want to delete this inventory?"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () {
                          _deleteInventory(context);
                        },
                        child: const Text("Delete"),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: inventoryRef.get(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading inventory size'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final inventoryData = snapshot.data!.data() as Map<String, dynamic>;
          final size = inventoryData['size'] ?? 0;

          return StreamBuilder<QuerySnapshot>(
            stream: itemsRef.snapshots(),
            builder: (context, itemSnapshot) {
              if (itemSnapshot.hasError) {
                return const Center(child: Text('Error loading items'));
              }
              if (!itemSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final items = itemSnapshot.data!.docs;

              // Create a scrollable grid based on the size
              List<Widget> gridItems = List.generate(size, (index) {
                final item = items.isNotEmpty && index < items.length
                    ? items[index].data() as Map<String, dynamic>
                    : null;

                return GestureDetector(
                  onTap: () {
                    if (item != null) {
                      _showItemDetails(context, item);
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: item != null ? Colors.blue.shade300 : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: item != null
                        ? Center(
                      child: Text(
                        item['label'],
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    )
                        : null,
                  ),
                );
              });

              return Padding(
                padding: const EdgeInsets.all(20),
                child: GridView.count(
                  crossAxisCount: 5, // Maximum of 7 rows
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  children: gridItems,
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
