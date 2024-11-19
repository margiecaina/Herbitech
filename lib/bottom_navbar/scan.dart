import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ScanPage extends StatefulWidget {
  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  File? filePath;
  String label = '';
  double confidence = 0.0;
  bool isLoading = false;

  Future<void> _tfLteInit() async {
    await Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt",
      numThreads: 1,
      isAsset: true,
      useGpuDelegate: false,
    );
  }

  Future<void> pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);

    if (image == null) return;

    var imageFile = File(image.path);

    setState(() {
      filePath = imageFile;
      isLoading = true;
    });

    try {
      var recognitions = await Tflite.runModelOnImage(
        path: image.path,
        imageMean: 0.0,
        imageStd: 255.0,
        numResults: 2,
        threshold: 0.5,
        asynch: true,
      );

      if (recognitions == null ||
          recognitions.isEmpty ||
          (recognitions[0]['confidence'] * 100 < 70.0)) {
        setState(() {
          label = "Image cannot be recognized";
          confidence = 0.0;
        });
      } else {
        setState(() {
          confidence = recognitions[0]['confidence'] * 100;
          label = recognitions[0]['label'].toString();
        });
      }
    } catch (e) {
      print("Error running model: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  String _generateLabelText() {
    if (label.contains("Ampalaya")) {
      return "Plant Detected: Ampalaya";
    } else if (label.contains("Bawang")) {
      return "Plant Detected: Bawang";
    } else if (label.contains("Rust")) {
      return "Disease Detected: Rust";
    } else if (label.contains("Powdery Mildew")) {
      return "Disease Detected: Powdery Mildew";
    }
    return "Label Not Found";
  }

  String _generateStatusText() {
    return _isDiseaseDetected() ? "Status: Unhealthy" : "Status: Healthy";
  }

  bool _isDiseaseDetected() {
    return label.contains("Rust") || label.contains("Powdery Mildew");
  }

  void _showRemedyInstructions(BuildContext context) {
    String title = '';
    String steps = '';

    if (label.contains("Rust")) {
      title = "Suggested Remedy for \nRust";
      steps =
      "1. Prune and remove infected leaves and stems: \nCarefully cut away all affected plant parts to prevent the spread of the disease. Dispose of the infected material away from healthy plants.\n"
          "2. Apply a targeted fungicide: \nUse a fungicide labeled for rust control. Follow the manufacturer's instructions for proper application, typically applying the product during early morning or late afternoon to avoid plant stress.\n"
          "3. Increase air circulation: \nPrune surrounding plants and improve spacing to reduce humidity around the plant. Rust thrives in damp, low-ventilated areas.\n"
          "4. Water properly: \nWater plants at the base, avoiding wetting the foliage. Rust thrives in conditions of excess moisture on the leaves.\n"
          "5. Monitor regularly: \nCheck the plant frequently for signs of new rust spots. Apply fungicide as a preventive measure if new outbreaks occur.";
    }
    else if (label.contains("Powdery Mildew")) {
      title = "Suggested Remedy for \nPowdery Mildew";
      steps =
      "1. Remove and discard infected plant parts: \nPrune off all leaves, stems, and flowers showing signs of powdery mildew. This reduces the spread of spores to other parts of the plant.\n"
          "2. Apply a fungicide specifically for powdery mildew: \nChoose a fungicide containing sulfur, potassium bicarbonate, or neem oil. Ensure full coverage on affected plant surfaces, especially on the underside of leaves.\n"
          "3. Improve air circulation: \nPrune dense foliage to allow air to flow freely. Powdery mildew thrives in high humidity and stagnant air.\n"
          "4. Increase sunlight exposure: \nIf possible, relocate the plant to a sunnier area. Powdery mildew tends to thrive in shaded, humid conditions.\n"
          "5. Avoid overhead watering: \nWater at the base of the plant, as wet foliage encourages mildew growth. Consider using a drip irrigation system to avoid wetting the leaves.\n"
          "6. Prevent future outbreaks: \nRegularly inspect plants for early signs of powdery mildew. Reapply fungicide at recommended intervals during the growing season.";
    }
    else {
      return; // No valid disease detected
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(steps),
              const SizedBox(height: 20),
              Column( // Changed Row to Column to stack buttons vertically
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      // Handle the "Monitor this plant" action
                      await _addToMonitoringCollection();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Plant added to monitoring"),
                          duration: Duration(
                              seconds: 1), // Set the duration to 2 seconds
                        ),
                      );
                    },
                    child: const Text("Monitor this plant"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,),
                  ),
                  const SizedBox(height: 12),
                  // Added some spacing between buttons
                  ElevatedButton(
                    onPressed: () async {
                      // Handle the "Report to expert" action
                      await _addToRemedyReportCollection();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Plant report sent to expert"),
                          duration: Duration(
                              seconds: 1), // Set the duration to 2 seconds
                        ),
                      );
                    },
                    child: const Text("Report to expert"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red,
                      foregroundColor: Colors.white,),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _addToMonitoringCollection() async {
    final uid = 'user_uid'; // Replace with actual user UID
    final now = DateTime.now();
    final date = "${now.year}-${now.month}-${now.day}";
    final time = "${now.hour}:${now.minute}:${now.second}";

    // Add the plant to the monitoring collection
    await FirebaseFirestore.instance.collection('plant_monitoring').add({
      'label': label.replaceAll(RegExp(r'^\d+\s+'), ''), // Clean the label
      'imageUrl': filePath!.path,
      'confidence': confidence,
      'uid': uid,
      'date': date,
      'time': time,
    });
  }

  Future<void> _addToRemedyReportCollection() async {
    final uid = 'user_uid'; // Replace with actual user UID
    final now = DateTime.now();
    final date = "${now.year}-${now.month}-${now.day}";
    final time = "${now.hour}:${now.minute}:${now.second}";

    // Add the report to the remedy report collection
    await FirebaseFirestore.instance.collection('remedy_reports').add({
      'label': label.replaceAll(RegExp(r'^\d+\s+'), ''), // Clean the label
      'imageUrl': filePath!.path,
      'confidence': confidence,
      'uid': uid,
      'date': date,
      'time': time,
    });
  }


  void _showInventorySelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('inventories')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text('Error loading inventories');
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
                    final uid = 'user_uid'; // Replace this with the actual UID
                    final now = DateTime.now();
                    final date = "${now.year}-${now.month}-${now.day}";
                    final time = "${now.hour}:${now.minute}:${now.second}";

                    // Add scanned item to the selected inventory
                    final inventoryRef = FirebaseFirestore.instance
                        .collection('inventories')
                        .doc(inventory.id)
                        .collection('items');

                    await inventoryRef.add({
                      'label': label.replaceAll(RegExp(r'^\d+\s+'), ''),
                      // Remove index
                      'imageUrl': filePath!.path,
                      'confidence': confidence,
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

                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(
                          "$label added to ${inventory['name']}")),
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


  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _tfLteInit();
  }

// Add this method to show plant information
  void _showPlantInformation(BuildContext context) {
    String title = '';
    String information = '';

    if (label.contains("Ampalaya")) {
      title = "Ampalaya (Bittermelon)";
      information =
      "Ampalaya, also known as bitter melon, is a tropical vine in the Cucurbitaceae family. It is widely used in Asian cuisine and traditional medicine. Known for its distinct bitter taste, it is rich in vitamins and minerals such as vitamin C, folate, and iron.\n\n"
          "Plant Type: Creeper (Vine)\n"
          "Health Benefits:\n"
          "- Rich in antioxidants and vitamins that help boost immunity.\n"
          "- Known for its potential to lower blood sugar levels, making it beneficial for diabetes management.\n"
          "- Supports digestion and promotes healthy liver function.\n"
          "- Can help in weight loss by reducing fat absorption.\n\n"
          "Growth Stages:\n"
          "1. Germination: The seeds usually germinate within 7-10 days when planted in warm soil.\n"
          "2. Seedling Stage: After germination, the plant grows its first leaves, and the seedlings can be transplanted to the garden or containers.\n"
          "3. Vegetative Stage: The plant grows leaves, tendrils, and flowers. This stage lasts for several weeks.\n"
          "4. Fruit Development: After pollination, the plant produces fruits that grow from green to yellow or orange when ripe.\n"
          "5. Harvesting: The bitter melon is typically harvested when it reaches its full size and the fruit has turned yellow or orange.\n";
    } else if (label.contains("Bawang")) {
      title = "Bawang (Garlic)";
      information =
      "Bawang, or garlic, is a bulbous plant from the Allium family. It is commonly used in cooking for its pungent flavor and aroma. Garlic is known for its numerous health benefits, including its ability to boost the immune system, improve cardiovascular health, and fight off infections.\n\n"
          "Plant Type: Herb (Bulbous Perennial)\n"
          "Health Benefits:\n"
          "- Contains compounds like allicin that have powerful antibacterial, antiviral, and antifungal properties.\n"
          "- Known for its ability to reduce cholesterol levels and lower blood pressure.\n"
          "- Acts as an immune booster and helps fight common illnesses such as the flu and colds.\n"
          "- Rich in antioxidants, garlic helps reduce inflammation and supports heart health.\n\n"
          "Growth Stages:\n"
          "1. Planting: Garlic is typically planted in the fall or early spring, with individual cloves planted 1-2 inches deep.\n"
          "2. Germination: The cloves sprout and develop roots within 2-3 weeks of planting.\n"
          "3. Vegetative Stage: During spring, the plant develops green shoots, which are harvested as 'green garlic' in some cases.\n"
          "4. Bulb Formation: The bulbs begin to form underground as the plant matures, typically in late spring to early summer.\n"
          "5. Harvesting: Garlic is harvested when the leaves begin to yellow, signaling the bulbs are ready. Typically harvested in mid-summer.\n";
    }


    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          content: Text(information),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 12),
              Card(
                elevation: 20,
                clipBehavior: Clip.hardEdge,
                child: SizedBox(
                  width: 300,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 18),
                        Container(
                          height: 280,
                          width: 280,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            image: const DecorationImage(
                              image: AssetImage('assets/upload.jpg'),
                            ),
                          ),
                          child: filePath == null
                              ? const Text('')
                              : Image.file(
                            filePath!,
                            fit: BoxFit.fill,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              if (label.isNotEmpty) ...[
                                Text(
                                  label == "Image cannot be recognized"
                                      ? label
                                      : _generateLabelText(),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (label != "Image cannot be recognized") ...[
                                  const SizedBox(height: 12),
                                  Text(
                                    "The Accuracy is: ${confidence
                                        .toStringAsFixed(0)}%",
                                    style: const TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    _generateStatusText(),
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: _isDiseaseDetected()
                                          ? Colors.red
                                          : Colors.green,
                                    ),
                                  ),
                                ],
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (isLoading) const CircularProgressIndicator(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FloatingActionButton(
                    onPressed: () => pickImage(ImageSource.camera),
                    child: const Icon(Icons.camera_alt),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  const SizedBox(width: 16),
                  FloatingActionButton(
                    onPressed: () => pickImage(ImageSource.gallery),
                    child: const Icon(Icons.photo_library),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  const SizedBox(width: 16),
                  FloatingActionButton(
                    onPressed: () {
                      setState(() {
                        filePath = null;
                        label = '';
                        confidence = 0.0;
                      });
                    },
                    child: const Icon(Icons.refresh),
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (label.isNotEmpty)
                Column(
                  children: [
                    if (!_isDiseaseDetected()) // Only show the Plant Information button if it's a healthy plant
                      ElevatedButton(
                        onPressed: () => _showPlantInformation(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("Plant Information"),
                      ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _isDiseaseDetected()
                          ? () => _showRemedyInstructions(context)
                          : () => _showInventorySelection(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        _isDiseaseDetected() ? Colors.red : Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                          _isDiseaseDetected() ? "Remedy" : "Put in Inventory"),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}