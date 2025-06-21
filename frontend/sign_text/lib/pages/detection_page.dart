import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart' show rootBundle;
import 'package:sign_text/l10n/app_localizations.dart';
import 'package:sign_text/image_preprocessing.dart' as preprocess;
import 'package:translator/translator.dart';

class DetectionPage extends StatefulWidget {
  const DetectionPage({super.key});

  @override
  State<DetectionPage> createState() => _DetectionPageState();
}

class _DetectionPageState extends State<DetectionPage> {
  final FlutterTts _flutterTts = FlutterTts();
  late CameraController _controller;
  late List<CameraDescription> cameras;
  bool _isCameraInitialized = false;
  DateTime _lastFrameSent = DateTime.now();
  String _prediction = "";
  String _displayText = "";
  String jsonString = "";
  Map<String, dynamic> jsonData = {};
  String _lang = 'en';
  Map? _voice;
  int? _selectedValue = 0;
  List<String> languages = ['tr', 'en', 'ar'];

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    loadJsonFromFile();
    updateVoice();
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
    img.Image? imgImage = preprocess.convertCameraImageToImage(image);

    if (imgImage != null) {
      List<int> bytes = img.encodeJpg(imgImage);
      await _sendImageToServer(bytes);
    }
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
      _prediction = "$_prediction${jsonData[data['prediction']]}";
      setState(() {
        _displayText = _prediction;
      });
    }
  }

  void updateVoice() {
    _flutterTts.getVoices.then((data) {
      try {

        List<Map> voices = List<Map>.from(data);
        List<Map> filteredVoices =
            voices.where((v) => v['name'].contains(_lang)).toList();
        setState(() {
          _voice = filteredVoices.first;
          setVoice(_voice!);
        });
      } catch (e) {
        print(e);
      }
    });
  }

  void setVoice(Map voice) {
    _flutterTts.setVoice({"name": voice["name"], "locale": voice["locale"]});
  }

  void translate() async {
    final translator = GoogleTranslator();
    var translation =
        await translator.translate(_prediction, from: 'tr', to: _lang);
    setState(() {
      _displayText = translation.toString();
    });
    updateVoice();
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
                color: Colors.white,
                width: double.infinity,
                height: 200,
                child: Container(
                    margin: EdgeInsets.all(11.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8.0),
                      border:
                          Border.all(color: Colors.indigo.shade400, width: 3.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 10,
                          spreadRadius: -5,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Stack(
                        children: [
                          Text(
                            _displayText,
                            style: GoogleFonts.khula(
                                color: Colors.black, fontSize: 16.0),
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return StatefulBuilder(
                                                builder: (builder, setState) {
                                              return AlertDialog(
                                                title: Text(
                                                  loc.selectLanguage,
                                                  style: GoogleFonts.khula(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                content: SizedBox(
                                                  height: 200.0,
                                                  // Set a fixed height
                                                  width: double.maxFinite,
                                                  child: ListView(
                                                    shrinkWrap: true,
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 25),
                                                    children: [
                                                      RadioListTile<int>(
                                                        value: 0,
                                                        groupValue:
                                                            _selectedValue,
                                                        onChanged: (value) {
                                                          setState(() {
                                                            _selectedValue =
                                                                value;
                                                            _lang = languages[
                                                                value!];
                                                          });
                                                        },
                                                        title: Text(loc.turkish,
                                                            style: GoogleFonts
                                                                .khula(
                                                                    fontSize:
                                                                        20)),
                                                      ),
                                                      RadioListTile<int>(
                                                        value: 1,
                                                        groupValue:
                                                            _selectedValue,
                                                        onChanged: (value) {
                                                          setState(() {
                                                            _selectedValue =
                                                                value;
                                                            _lang = languages[
                                                                value!];
                                                          });
                                                        },
                                                        title: Text(loc.english,
                                                            style: GoogleFonts
                                                                .khula(
                                                                    fontSize:
                                                                        20)),
                                                      ),
                                                      RadioListTile<int>(
                                                        value: 2,
                                                        groupValue:
                                                            _selectedValue,
                                                        onChanged: (value) {
                                                          setState(() {
                                                            _selectedValue =
                                                                value;
                                                            _lang = languages[
                                                                value!];
                                                          });
                                                        },
                                                        title: Text(loc.arabic,
                                                            style: GoogleFonts
                                                                .khula(
                                                                    fontSize:
                                                                        20)),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                actions: [
                                                  TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: Text(loc.cancel)),
                                                  TextButton(
                                                      onPressed: () {
                                                        translate();
                                                        Navigator.pop(context);
                                                      },
                                                      child: Text(loc.apply))
                                                ],
                                              );
                                            });
                                          });
                                    },
                                    icon: Icon(Icons.translate),
                                    color: Colors.grey[800]),
                                SizedBox(
                                  width: 20.0,
                                ),
                                IconButton(
                                    onPressed: () {
                                      _flutterTts.speak(_displayText);
                                    },
                                    icon: Icon(Icons.volume_up),
                                    color: Colors.grey[800])
                              ],
                            ),
                          )
                        ],
                      ),
                    )),
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
