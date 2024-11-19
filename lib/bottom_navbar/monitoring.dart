import 'dart:io'; // For File class
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MonitorPage extends StatefulWidget {
  @override
  _MonitorPageState createState() => _MonitorPageState();
}

class _MonitorPageState extends State<MonitorPage> {
  String? _selectedInventory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Plant Monitoring',
            style: TextStyle(
              fontSize: 24, // Larger font size for better visibility
              fontWeight: FontWeight.w600, // Semi-bold text for emphasis
              color: Colors.green[200], // Text color to match the icon color
              decoration: TextDecoration.overline, // Underline the text
              decorationColor: Colors.green[200], // Optional: sets the underline color
              decorationThickness: 2, // Optional: controls the thickness of the underline
            ),
          ),
          centerTitle: true, // Centers the title
          elevation: 0, // No elevation, for a flat design
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // Rounded corners
          ),
        ),


        body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('plant_monitoring')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading plants'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final plants = snapshot.data!.docs;

          if (plants.isEmpty) {
            return const Center(child: Text('No plants to monitor'));
          }

          return ListView.builder(
            itemCount: plants.length,
            itemBuilder: (context, index) {
              final plant = plants[index];
              final label = plant['label'];  // This is the plant's label (or disease name)
              final imageUrl = plant['imageUrl'];
              final date = plant['date'];
              final time = plant['time'];

              // Determine the disease status, assuming it's unhealthy for now
              String status = "Unhealthy";  // You can adjust this based on the logic for health checking

              return Card(
                margin: const EdgeInsets.all(8),
                elevation: 5,
                child: InkWell(
                  onTap: () {
                    // Navigate to a new blank page when tapped
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BlankPage(), // Modify BlankPage to your desired page
                      ),
                    );
                  },
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(10),
                    leading: Image.file(
                      File(imageUrl), // Ensure this is a valid local path or URL
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                    title: Text("Disease Detected: $label"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Status: $status"),
                        Text("Date: $date Time: $time"),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () {
                        _showOptionsDialog(context, plant);
                      },
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showOptionsDialog(BuildContext context, DocumentSnapshot plant) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose an action'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => _decomposePlant(plant),
                child: const Text('Decompose'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
              const SizedBox(height: 10),
              // Put in Inventory
              ElevatedButton(
                onPressed: () => _showInventorySelection(context, plant),
                child: const Text('Put in Inventory'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _decomposePlant(DocumentSnapshot plant) async {
    try {
      // Move the plant data to the decomposed plants collection
      await FirebaseFirestore.instance.collection('decomposed_plants').add({
        'label': plant['label'],
        'imageUrl': plant['imageUrl'],
        'date': plant['date'],
        'time': plant['time'],
      });

      // Delete the plant from the plant monitoring collection
      await FirebaseFirestore.instance
          .collection('plant_monitoring')
          .doc(plant.id)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Plant decomposed and moved to history")),
      );
      Navigator.of(context).pop();
    } catch (e) {
      print("Error decomposing plant: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to decompose plant")),
      );
    }
  }

  void _showInventorySelection(BuildContext context, DocumentSnapshot plant) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('inventories').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('Error loading inventories'));
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final inventories = snapshot.data!.docs;

            return inventories.isEmpty
                ? const Center(child: Text("No inventories available"))
                : ListView.builder(
              itemCount: inventories.length,
              itemBuilder: (context, index) {
                final inventory = inventories[index];
                return ListTile(
                  title: Text(inventory['name']),
                  onTap: () async {
                    final uid = 'user_uid'; // Replace with actual UID
                    final now = DateTime.now();
                    final date = "${now.year}-${now.month}-${now.day}";
                    final time = "${now.hour}:${now.minute}:${now.second}";

                    // Add plant to the selected inventory
                    final inventoryRef = FirebaseFirestore.instance
                        .collection('inventories')
                        .doc(inventory.id)
                        .collection('items');

                    await inventoryRef.add({
                      'label': plant['label'],
                      'imageUrl': plant['imageUrl'],
                      'uid': uid,
                      'date': date,
                      'time': time,
                    });

                    // Increment the inventory's quantity
                    await FirebaseFirestore.instance
                        .collection('inventories')
                        .doc(inventory.id)
                        .update({
                      'quantity': FieldValue.increment(1),
                    });

                    // Remove plant from monitoring
                    await FirebaseFirestore.instance
                        .collection('plant_monitoring')
                        .doc(plant.id)
                        .delete();

                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("${plant['label']} added to ${inventory['name']}")),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

// BlankPage widget to navigate to when a ListTile is clicked
class BlankPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Experts Report"),
      ),
      body: Center(
        child: Text("Not yet done"),
      ),
    );
  }
}
