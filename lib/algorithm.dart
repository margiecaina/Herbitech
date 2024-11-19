import 'dart:io'; // Import package for file handling
import 'dart:typed_data'; // Import package for handling byte data
import 'dart:math'; // Import package for mathematical functions
import 'package:flutter/material.dart'; // Import Flutter material design package
import 'package:image_picker/image_picker.dart'; // Import package to pick images
import 'package:tflite_flutter/tflite_flutter.dart'; // Import TensorFlow Lite Flutter package
import 'package:image/image.dart' as img; // Import image processing package

// START OF APPLICATION
void main() {
  runApp(YoloApp()); // Start the application with YoloApp
}

class YoloApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Build the main UI for the application
    return MaterialApp(
      home: YoloDetectionScreen(), // Set YoloDetectionScreen as the home screen
    );
  }
}

class YoloDetectionScreen extends StatefulWidget {
  @override
  _YoloDetectionScreenState createState() => _YoloDetectionScreenState(); // Create the state for this screen
}

class _YoloDetectionScreenState extends State<YoloDetectionScreen> {
  Interpreter? _interpreter; // Declare an interpreter for the model
  File? _selectedImage; // Declare a variable for the selected image
  final picker = ImagePicker(); // Create an image picker instance
  List<Detection>? _detections; // List to hold detected objects

  @override
  void initState() {
    super.initState(); // Call the parent class's initState method
    loadModel(); // Load the machine learning model when the screen initializes
  }

  // FUNCTION to load the YOLOv8 model
  Future<void> loadModel() async {
    _interpreter = await Interpreter.fromAsset('assets/model_unquant.tflite'); // Load the model from assets
  }

  // FUNCTION to pick an image from the gallery
  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery); // Show image picker
    if (pickedFile != null) { // Check if an image is selected
      setState(() {
        _selectedImage = File(pickedFile.path); // Set the selected image
      });
      await processImage(_selectedImage!); // Process the selected image
    }
  }

  // FUNCTION to process the selected image for detection
  Future<void> processImage(File imageFile) async {
    if (_interpreter == null) return; // Exit if the interpreter is not initialized

    final inputImage = img.decodeImage(imageFile.readAsBytesSync())!; // Decode the image
    final resizedImage = img.copyResize(inputImage, width: 640, height: 640); // Resize the image to 640x640
    var input = imageToByteListUint8(resizedImage, 640, 640); // Convert resized image to byte format

    var output = List.generate(1, (i) => List.filled(25200, 0.0)); // Create an output list for results

    _interpreter!.run(input, output); // Run inference on the input image

    // Call post-processing function to decode model output
    var detections = yoloV8PostProcessing(output[0]);

    setState(() {
      _detections = detections; // Update detected objects in the state
    });
  }

  // FUNCTION to convert an image to a byte list
  Uint8List imageToByteListUint8(img.Image image, int width, int height) {
    var convertedBytes = Uint8List(1 * width * height * 3); // Create byte list for RGB
    var buffer = ByteData.view(convertedBytes.buffer); // Create a buffer for the byte list
    int pixelIndex = 0; // Initialize pixel index
    for (int y = 0; y < height; y++) { // Loop through each pixel in height
      for (int x = 0; x < width; x++) { // Loop through each pixel in width
        int pixel = image.getPixel(x, y); // Get pixel color
        buffer.setUint8(pixelIndex++, (pixel >> 16) & 0xFF); // Set red channel
        buffer.setUint8(pixelIndex++, (pixel >> 8) & 0xFF);  // Set green channel
        buffer.setUint8(pixelIndex++, pixel & 0xFF);          // Set blue channel
      }
    }
    return convertedBytes; // Return byte array of the image
  }

  // FUNCTION for post-processing model output
  List<Detection> yoloV8PostProcessing(List<double> modelOutput) {
    List<Detection> detections = []; // Initialize list for detections

    // Call functions to decode bounding boxes and apply NMS
    final decodedBoxes = decodeBoundingBoxes(modelOutput);
    final nmsResults = applyNonMaxSuppression(decodedBoxes);

    return nmsResults; // Return filtered detections
  }

  // FUNCTION to decode bounding boxes from model output
  List<Detection> decodeBoundingBoxes(List<double> output) {
    List<Detection> detections = []; // Initialize detections list

    for (int i = 0; i < output.length; i += 5) { // Loop through model output
      double x = output[i]; // Get x-coordinate
      double y = output[i + 1]; // Get y-coordinate
      double w = output[i + 2]; // Get width
      double h = output[i + 3]; // Get height
      double confidence = output[i + 4]; // Get confidence score

      // Create a bounding box
      Rect box = Rect.fromCenter(center: Offset(x, y), width: w, height: h);
      // Create a Detection object with the detected object info
      detections.add(Detection('object', confidence, box)); // Assume class 'object' for simplicity
    }

    return detections; // Return list of detections
  }

  // FUNCTION to apply Non-Maximum Suppression
  List<Detection> applyNonMaxSuppression(List<Detection> detections) {
    List<Detection> filteredDetections = []; // Initialize filtered detections list
    // Placeholder for NMS logic to filter overlapping boxes based on confidence scores
    return filteredDetections; // Return filtered list
  }

  @override
  void dispose() {
    _interpreter?.close(); // Close interpreter to free resources
    super.dispose(); // Call the parent dispose method
  }

  @override
  Widget build(BuildContext contextBui) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _selectedImage == null
                ? Text("No image selected") // Display message if no image is selected
                : Image.file(_selectedImage!), // Display the selected image
            SizedBox(height: 20), // Add space between widgets
            ElevatedButton(
              onPressed: pickImage, // Set button to pick image
              child: Text("Select Image"), // Button label
            ),
            if (_detections != null) ...[
              for (var detection in _detections!) // Loop through detected objects
                Text("Detected: ${detection.className} - Confidence: ${detection.confidence}") // Display detection info
            ],
          ],
        ),
      ),
    );
  }
}

// CLASS to define a detection object
class Detection {
  final String className; // Name of the detected object
  final double confidence; // Confidence score of the detection
  final Rect boundingBox; // Bounding box for the detected object

  Detection(this.className, this.confidence, this.boundingBox); // Constructor for the Detection class
}

