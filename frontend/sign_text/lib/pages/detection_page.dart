import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart' show rootBundle;
import 'package:sign_text/l10n/app_localizations.dart';

class DetectionPage extends StatefulWidget {
  const DetectionPage({super.key});
  @override
  State<DetectionPage> createState() => _DetectionPageState();
}

class _DetectionPageState extends State<DetectionPage> {
  late CameraController _controller;
  late List<CameraDescription> cameras;
  bool _isCameraInitialized = false;
  DateTime _lastFrameSent = DateTime.now();
  String _prediction = "";
  String jsonString = "";
  Map<String, dynamic> jsonData = {};

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    loadJsonFromFile();
  }

  Future<void> loadJsonFromFile() async {
    String jsonString = await rootBundle.loadString('assets/labels.json');

    jsonData = jsonDecode(jsonString);
  }

  Future<void> _initializeCamera() async {
    cameras = await availableCameras();
    _controller = CameraController(cameras[0], ResolutionPreset.high);

    await _controller.initialize();
    setState(() {
      _isCameraInitialized = true;
    });

    _controller.startImageStream((CameraImage image) {
      if (DateTime.now().difference(_lastFrameSent).inMilliseconds > 1000) {
        _lastFrameSent = DateTime.now();
        _sendFrameToBackend(image);
      }
    });
  }

  Future<void> _sendFrameToBackend(CameraImage image) async {
    img.Image? imgImage = _convertCameraImageToImage(image);

    if (imgImage != null) {
      List<int> bytes = img.encodeJpg(imgImage);
      await _sendImageToServer(bytes);
    }
  }

  img.Image? _convertCameraImageToImage(CameraImage image) {
    return convertYUV420ToImageColor(image);
  }

  img.Image convertYUV420ToImageColor(CameraImage cameraImage) {
    final width = cameraImage.width;
    final height = cameraImage.height;
    final yBuffer = cameraImage.planes[0].bytes;
    final uBuffer = cameraImage.planes[1].bytes;
    final vBuffer = cameraImage.planes[2].bytes;

    final img.Image image = img.Image(width, height);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final int uvIndex =
            ((x ~/ 2) + (y ~/ 2) * (cameraImage.planes[1].bytesPerRow ~/ 2))
                .clamp(0, uBuffer.length - 1);
        final int yIndex = y * cameraImage.planes[0].bytesPerRow + x;

        final int yValue = yBuffer[yIndex];
        final int uValue = uBuffer[uvIndex];
        final int vValue = vBuffer[uvIndex];

        int r = (yValue + 1.402 * (vValue - 128)).clamp(0, 255).toInt();
        int g = (yValue - 0.344136 * (uValue - 128) - 0.714136 * (vValue - 128))
            .clamp(0, 255)
            .toInt();
        int b = (yValue + 1.772 * (uValue - 128)).clamp(0, 255).toInt();

        image.setPixel(x, y, img.getColor(r, g, b));
      }
    }
    return image;
  }

  Future<void> _sendImageToServer(List<int> imageBytes) async {
    String base64Image = base64Encode(imageBytes);

    final response = await http.post(
      Uri.parse('https://ec2f-193-140-142-102.ngrok-free.app/predict'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'image': base64Image}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _prediction = "$_prediction${jsonData[data['prediction']]}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
        appBar: AppBar(
            iconTheme: IconThemeData(color: Colors.white),
            backgroundColor: Colors.indigo.shade400,
            title: Text(
              loc.liveHandDetection,
              style: GoogleFonts.khula(
                  color: Colors.white, fontWeight: FontWeight.w700),
            )),
        body: Stack(
          children: [
            Center(
              child: _isCameraInitialized
                  ? CameraPreview(_controller)
                  : CircularProgressIndicator(),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                height: 200,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(color: Color(0XFFDDDADA)),
                child: Text(
                  _prediction,
                  style: GoogleFonts.khula(
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ));
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
