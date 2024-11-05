import 'dart:io';
import 'dart:typed_data';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

void main() {
  runApp(YoloApp());
}

class YoloApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: YoloDetectionScreen(),
    );
  }
}

class YoloDetectionScreen extends StatefulWidget {
  @override
  _YoloDetectionScreenState createState() => _YoloDetectionScreenState();
}

class _YoloDetectionScreenState extends State<YoloDetectionScreen> {
  Interpreter? _interpreter;
  File? _selectedImage;
  final picker = ImagePicker();
  List<Detection>? _detections;

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  Future<void> loadModel() async {
    _interpreter = await Interpreter.fromAsset('assets/models/model_unquant.tflite');
  }

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
      await processImage(_selectedImage!);
    }
  }

  Future<void> processImage(File imageFile) async {
    if (_interpreter == null) return;

    final inputImage = img.decodeImage(imageFile.readAsBytesSync())!;
    final resizedImage = img.copyResize(inputImage, width: 640, height: 640);
    var input = imageToByteListUint8(resizedImage, 640, 640);

    var output = List.generate(1, (i) => List.filled(25200, 0.0));

    // Run inference
    _interpreter!.run(input, output);

    // Decode YOLOv8 output
    var detections = yoloV8PostProcessing(output[0]);

    setState(() {
      _detections = detections;
    });
  }

  Uint8List imageToByteListUint8(img.Image image, int width, int height) {
    var convertedBytes = Uint8List(1 * width * height * 3);
    var buffer = ByteData.view(convertedBytes.buffer);
    int pixelIndex = 0;
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        int pixel = image.getPixel(x, y);
        buffer.setUint8(pixelIndex++, (pixel >> 16) & 0xFF); // Red channel
        buffer.setUint8(pixelIndex++, (pixel >> 8) & 0xFF);  // Green channel
        buffer.setUint8(pixelIndex++, pixel & 0xFF);          // Blue channel
      }
    }
    return convertedBytes;
  }

  List<Detection> yoloV8PostProcessing(List<double> modelOutput) {
    List<Detection> detections = [];

    // Simulate YOLOv8 architecture's post-processing with bounding box decoding and NMS.
    final decodedBoxes = decodeBoundingBoxes(modelOutput);
    final nmsResults = applyNonMaxSuppression(decodedBoxes);

    return nmsResults;
  }

  List<Detection> decodeBoundingBoxes(List<double> output) {
    List<Detection> detections = [];

    // Example loop for bounding box decoding
    for (int i = 0; i < output.length; i += 5) {
      // Assuming the output format is [x, y, w, h, confidence]
      double x = output[i];
      double y = output[i + 1];
      double w = output[i + 2];
      double h = output[i + 3];
      double confidence = output[i + 4]; // Placeholder confidence score

      // Create a bounding box
      Rect box = Rect.fromCenter(center: Offset(x, y), width: w, height: h);

      // Create a Detection object
      detections.add(Detection('object', confidence, box)); // Assuming class 'object' for simplicity
    }

    return detections;
  }

  List<Detection> applyNonMaxSuppression(List<Detection> detections) {
    List<Detection> filteredDetections = [];

    // Placeholder for NMS logic
    // Typically involves filtering out overlapping bounding boxes based on confidence scores.

    return filteredDetections;
  }

  @override
  void dispose() {
    _interpreter?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _selectedImage == null
                ? Text("No image selected")
                : Image.file(_selectedImage!),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: pickImage,
              child: Text("Select Image"),
            ),
            if (_detections != null) ...[
              for (var detection in _detections!)
                Text("Detected: ${detection.className} - Confidence: ${detection.confidence}")
            ],
          ],
        ),
      ),
    );
  }
}

class Detection {
  final String className;
  final double confidence;
  final Rect boundingBox;

  Detection(this.className, this.confidence, this.boundingBox);
}
