import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:image_picker/image_picker.dart';

class ScanPage extends StatefulWidget {
  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  File? filePath;
  String label = '';
  double confidence = 0.0;

  Future<void> _tfLteInit() async {
    await Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt",
      numThreads: 1,
      isAsset: true,
      useGpuDelegate: false,
    );
  }

  pickImageCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image == null) return;

    var imageFile = File(image.path);

    setState(() {
      filePath = imageFile;
    });

    var recognitions = await Tflite.runModelOnImage(
      path: image.path,
      imageMean: 0.0,
      imageStd: 255.0,
      numResults: 2,
      threshold: 0.5,
      asynch: true,
    );

    if (recognitions == null || recognitions.isEmpty) {
      setState(() {
        label = "Image cannot be recognized";
        confidence = 0.0;
      });
      return;
    }

    // Only consider predictions with confidence > 70%
    if (recognitions[0]['confidence'] * 100 < 70.0) {
      setState(() {
        label = "Image cannot be recognized";
        confidence = 0.0;
      });
      return;
    }

    setState(() {
      confidence = (recognitions[0]['confidence'] * 100);
      label = recognitions[0]['label'].toString();
    });
  }

  pickImageGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    var imageFile = File(image.path);

    setState(() {
      filePath = imageFile;
    });

    var recognitions = await Tflite.runModelOnImage(
      path: image.path,
      imageMean: 0.0,
      imageStd: 255.0,
      numResults: 2,
      threshold: 0.5,
      asynch: true,
    );

    if (recognitions == null || recognitions.isEmpty) {
      setState(() {
        label = "Image cannot be recognized";
        confidence = 0.0;
      });
      return;
    }

    // Only consider predictions with confidence > 70%
    if (recognitions[0]['confidence'] * 100 < 70.0) {
      setState(() {
        label = "Image cannot be recognized";
        confidence = 0.0;
      });
      return;
    }

    setState(() {
      confidence = (recognitions[0]['confidence'] * 100);
      label = recognitions[0]['label'].toString();
    });
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
    if (_isDiseaseDetected()) {
      return "Status: Unhealthy";
    } else {
      return "Status: Healthy";
    }
  }

  bool _isDiseaseDetected() {
    return label.contains("Rust") || label.contains("Powdery Mildew");
  }

  void _showRemedyInstructions(BuildContext context) {
    String title = '';
    String steps = '';

    if (label.contains("Rust")) {
      title = "Remedy for Rust";
      steps = "Step 1: Prune and dispose of affected leaves and stems.\n"
          "Step 2: Apply a fungicide designed to treat rust diseases.\n"
          "Step 3: Improve air circulation around the plant to reduce humidity.\n"
          "Step 4: Avoid overhead watering to keep leaves dry.";
    } else if (label.contains("Powdery Mildew")) {
      title = "Remedy for Powdery Mildew";
      steps = "Step 1: Remove and dispose of infected plant parts.\n"
          "Step 2: Spray the plant with a milk-water solution (1 part milk to 9 parts water).\n"
          "Step 3: Increase sunlight exposure where possible.\n"
          "Step 4: Ensure proper spacing between plants to improve airflow.";
    } else {
      return; // No valid disease detected
    }

    // Show dialog with remedy instructions
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(steps),
          actions: [
            TextButton(
              child: const Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
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
                                    "The Accuracy is: ${confidence.toStringAsFixed(0)}%",
                                    style: const TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    _generateStatusText(),
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: _isDiseaseDetected() ? Colors.red : Colors.green,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FloatingActionButton(
                    onPressed: pickImageCamera,
                    child: const Icon(Icons.camera_alt),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  const SizedBox(width: 16),
                  FloatingActionButton(
                    onPressed: pickImageGallery,
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
              // Conditional display of Put in Inventory or Remedy buttons
              if (label.isNotEmpty) ...[
                if (_isDiseaseDetected())
                  ElevatedButton(
                    onPressed: () {
                      _showRemedyInstructions(context); // Show remedy instructions
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white, // Red color for Remedy button
                    ),
                    child: const Text("Remedy"),
                  )
                else
                  ElevatedButton(
                    onPressed: () {
                      // Handle Put in Inventory action
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white, // Green color for Inventory button
                    ),
                    child: const Text("Put in Inventory"),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
