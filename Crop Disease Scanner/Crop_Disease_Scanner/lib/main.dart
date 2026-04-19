import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const CropScannerApp());
}

class CropScannerApp extends StatelessWidget {
  const CropScannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crop Scanner',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const CropScannerScreen(),
    );
  }
}

class CropScannerScreen extends StatefulWidget {
  const CropScannerScreen({super.key});

  @override
  State<CropScannerScreen> createState() => _CropScannerScreenState();
}

class _CropScannerScreenState extends State<CropScannerScreen> {
  File? _image;
  String _prediction = "Awaiting image...";
  String _confidence = "";
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

  // 🔴 PASTE YOUR LOCALTUNNEL URL HERE (Keep the /predict at the end!)
  final String apiUrl = "https://purple-points-burn.loca.lt/predict";

  // 1. Pick an image from Camera or Gallery
  Future<void> pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _prediction = "Image loaded. Ready to analyze.";
        _confidence = "";
      });
    }
  }

  // 2. Send the image to your FastAPI Backend
  Future<void> analyzeLeaf() async {
    if (_image == null) return;

    setState(() {
      _isLoading = true;
      _prediction = "Analyzing...";
      _confidence = "";
    });

    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));

      // 💡 PRO-TIP: This header forces Localtunnel to skip the password warning page!
      request.headers['Bypass-Tunnel-Reminder'] = 'true';

      request.files.add(await http.MultipartFile.fromPath('file', _image!.path));

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        var json = jsonDecode(responseData);
        setState(() {
          // Clean up the prediction text (replace underscores with spaces)
          _prediction = json['prediction'].toString().replaceAll('_', ' ');
          _confidence = "Confidence: ${json['confidence']}";
        });
      } else {
        setState(() {
          _prediction = "Server Error: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        _prediction = "Connection failed. Is the server running?";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 3. The User Interface
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crop Disease Scanner'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Image Display Area
              Container(
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.green, width: 2),
                ),
                child: _image == null
                    ? const Icon(Icons.yard, size: 100, color: Colors.grey)
                    : ClipRRect(
                  borderRadius: BorderRadius.circular(13),
                  child: Image.file(_image!, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 20),

              // Camera / Gallery Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Analyze Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton.icon(
                  onPressed: _isLoading || _image == null ? null : analyzeLeaf,
                  icon: _isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.search),
                  label: const Text('Analyze Leaf', style: TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(height: 30),

              // Results Display
              Text(
                _prediction,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                _confidence,
                style: const TextStyle(fontSize: 18, color: Colors.green),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
