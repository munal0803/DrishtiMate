import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For vibration
import 'package:flutter_tts/flutter_tts.dart';
import 'package:camera/camera.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:image/image.dart' as imglib;
import 'package:http_parser/http_parser.dart';
import 'package:permission_handler/permission_handler.dart';

late List<CameraDescription> cameras;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras(); // initialize cameras
  runApp(MaterialApp(home: ObjectDetectScreen()));
}

class ObjectDetectScreen extends StatefulWidget {
  @override
  State<ObjectDetectScreen> createState() => _ObjectDetectScreenState();
}

class _ObjectDetectScreenState extends State<ObjectDetectScreen> {
  late CameraController controller;
  bool isCameraInitialized = false;

  final stt.SpeechToText speech = stt.SpeechToText();
  final FlutterTts tts = FlutterTts();
  bool isListening = false;
  String spokenText = "";
  bool isDetecting = false;
  late Future<void> helpListeningLoop;
  XFile? recordedVideo;
  List<File> savedFrames = [];
  final int maxSavedFrames = 50;
  final String saveDirPath =
      "/storage/emulated/0/Android/data/com.example.yourapp/files/frames";

  final String flaskUrl = "http://192.168.29.169:5000/start_detection";
  final String callbackUrl = "http://192.168.29.169:5000/found";

  Future<void> initCamera() async {
    controller = CameraController(cameras[0], ResolutionPreset.medium);
    await controller.initialize();
    if (!mounted) return;
    setState(() {
      isCameraInitialized = true;
    });
    // _startLoopedRecording();
  }

  // Future<void> requestStoragePermission() async {
  //   if (await Permission.storage.request().isGranted) {
  //     print("✅ Storage permission granted");
  //   } else {
  //     print("❌ Storage permission denied");
  //   }

  //   if (await Permission.manageExternalStorage.request().isGranted) {
  //     print("✅ Manage external storage granted");
  //   }
  // }

  void _startLoopedRecording() async {
    while (mounted) {
      // Start recording
      await controller.startVideoRecording();
      print("Recording started...");

      // Wait 1 minute
      await Future.delayed(Duration(minutes: 1));

      // Stop and save video
      recordedVideo = await controller.stopVideoRecording();
      print("Recording saved to: ${recordedVideo?.path}");

      // Optional: delete previous file to replace
      final file = File(recordedVideo!.path);
      if (await file.exists()) {
        await file.delete();
        print("Previous video deleted.");
      }
    }
  }

  // Future<void> startDetection() async {
  //   await tts.speak("Listening in 1 second...");
  //   await Future.delayed(Duration(seconds: 3));

  //   bool available = await speech.initialize(
  //     onError: (error) {
  //       print("❌ Speech error: $error");
  //     },
  //     onStatus: (status) {
  //       print("🎙️ Speech status: $status");
  //     },
  //   );

  //   if (available) {
  //     spokenText = "";
  //     await speech.listen(
  //       listenMode: stt.ListenMode.dictation,
  //       listenFor: const Duration(seconds: 10),
  //       pauseFor: const Duration(seconds: 10), // Prevent early stop on pause
  //       cancelOnError: false,
  //       onResult: (val) async {
  //         if (val.finalResult || val.recognizedWords.isNotEmpty) {
  //           spokenText = val.recognizedWords.isNotEmpty
  //               ? val.recognizedWords
  //               : "Nothing";
  //           await tts.speak("You said $spokenText");

  //           await http.post(
  //             Uri.parse(flaskUrl),
  //             headers: {"Content-Type": "application/json"},
  //             body: jsonEncode({
  //               "text": spokenText,
  //               "callback_url": callbackUrl,
  //             }),
  //           );
  //         }
  //       },
  //     );
  //   } else {
  //     print("❌ Speech recognition not available.");
  //   }
  //   print("--------------> detection completed for speech");
  // }

  Future<String> startDetection() async {
    await tts.speak("Listening in 1 second...");
    await Future.delayed(Duration(seconds: 3));

    String detectedText = "";

    bool available = await speech.initialize(
      onError: (error) {
        print("❌ Speech error: $error");
      },
      onStatus: (status) {
        print("🎙️ Speech status: $status");
      },
    );

    if (available) {
      await speech.listen(
        listenMode: stt.ListenMode.dictation,
        listenFor: const Duration(seconds: 3),
        pauseFor: const Duration(seconds: 3),
        cancelOnError: false,
        onResult: (val) async {
          if (val.finalResult || val.recognizedWords.isNotEmpty) {
            detectedText = val.recognizedWords.isNotEmpty
                ? val.recognizedWords
                : "Nothing";
            await tts.speak("You said $detectedText");
          }
        },
      );

      // Wait until listening finishes
      await Future.delayed(Duration(seconds: 12));
    } else {
      print("❌ Speech recognition not available.");
    }

    return detectedText;
  }

  void listenForHelp() async {
    print("Listening for help...");

    bool available = await speech.initialize();
    if (!available) {
      print("Speech recognition not available");
      return;
    }

    await _startListeningLoop();
  }

  Future<void> _startListeningLoop() async {
    while (true) {
      if (!speech.isListening) {
        await speech.listen(
          listenMode: stt.ListenMode.dictation,
          partialResults: true,
          cancelOnError: false,
          listenFor: Duration(seconds: 30), // keeps mic open for longer
          pauseFor: Duration(seconds: 5),
          onResult: (val) async {
            String said = val.recognizedWords.toLowerCase();
            print("Help Listener: $said");

            if (said.contains("help")) {
              await tts.speak("Help word detected");

              await http.post(
                Uri.parse("http://192.168.29.169:5000/help_alert"),
                headers: {"Content-Type": "application/json"},
                body: jsonEncode({"message": "Help word detected"}),
              );
            }
          },
        );
      }

      await Future.delayed(Duration(seconds: 2));
    }
  }

  void toggleDetection() async {
    if (isDetecting) {
      setState(() => isDetecting = false);
      speech.stop();
      await stopDetection();
      await controller.stopImageStream(); // stop frame stream
      print("Detection stopped");
    } else {
      setState(() => isDetecting = true);
      spokenText = await startDetection();
      print("---------------> Detected speech $spokenText"); // speech + post
      startFrameStreaming(spokenText); // begin sending frames
    }
  }

  bool isProcessingFrame = false;

  // void startFrameStreaming() {
  //   if (!controller.value.isInitialized) return;

  //   controller.startImageStream((CameraImage image) async {
  //     if (isProcessingFrame) return; // Skip if still processing previous frame
  //     isProcessingFrame = true;

  //     try {
  //       final jpegBytes = await convertToJpeg(image);
  //       print("-------------->Image converted");
  //       if (jpegBytes != null) {
  //         final uri = Uri.parse("http://10.97.90.147:5000/detect_frame");
  //         final request = http.MultipartRequest('POST', uri);
  //         request.files.add(http.MultipartFile.fromBytes(
  //           'image',
  //           jpegBytes,
  //           filename: 'frame.jpg',
  //           contentType: MediaType('image', 'jpeg'),
  //         ));
  //         final response = await request.send();

  //         if (response.statusCode != 200) {
  //           print('Frame upload failed: ${response.statusCode}');
  //         }
  //       }
  //     } catch (e) {
  //       print("Frame send error: $e");
  //     } finally {
  //       isProcessingFrame = false; // Unlock for the next frame
  //     }
  //   });
  // }

  void startFrameStreaming(spokentext) {
    if (!controller.value.isInitialized) return;

    controller.startImageStream((CameraImage image) async {
      if (isProcessingFrame) return;
      isProcessingFrame = true;

      try {
        final jpegBytes = await convertToJpeg(image);
        if (jpegBytes != null) {
          _saveFrameInBackground(Uint8List.fromList(jpegBytes));
        }
        // print("-------------->Image converted");

        if (jpegBytes != null) {
          final uri = Uri.parse("http://192.168.29.169:5000/detect_frame")
              .replace(queryParameters: {
            'target_text': spokenText, // store this from startDetection()
            'callback_url': callbackUrl,
          });
          final request = http.MultipartRequest('POST', uri);
          request.files.add(http.MultipartFile.fromBytes(
            'image',
            jpegBytes,
            filename: 'frame.jpg',
            contentType: MediaType('image', 'jpeg'),
          ));

          // final streamedResponse = await request.send();
          // final response = await http.Response.fromStream(streamedResponse);

          // if (response.statusCode == 200) {
          //   final data = jsonDecode(response.body);
          //   print("✅ Backend says: ${data['message']}");
          //   // You can also show this in UI using setState or use TTS to speak it
          // } else {
          //   print('❌ Frame upload failed: ${response.statusCode}');
          // }
          final streamedResponse = await request.send();
          final response = await http.Response.fromStream(streamedResponse);
          print(response.body);
          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            print("---------------------------> $data");
            if (data.containsKey('message')) {
              final message = data['message'].toString().toLowerCase();
              print("-------------------->  $message");
              final target = spokenText
                  .toLowerCase(); // spokenText should be accessible here

              tts.speak(target);
              print("🎯 Target spoken text: $target");

              if (message.contains(target)) {
                await tts.speak(message);
              } else {
                print("🔇 Message does not match spoken text");
              }
            }
          } else {
            print('❌ Frame upload failed: ${response.statusCode}');
          }
        }
      } catch (e) {
        print("❌ Frame send error: $e");
      } finally {
        isProcessingFrame = false;
      }
    });
  }

  void _saveFrameInBackground(Uint8List jpegBytes) async {
    try {
      // Create directory if not exists
      final dir = Directory(saveDirPath);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      // Save with timestamp name
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${dir.path}/frame_$timestamp.jpg');
      await file.writeAsBytes(jpegBytes);

      // Manage frame list
      savedFrames.add(file);
      if (savedFrames.length > maxSavedFrames) {
        final removed = savedFrames.removeAt(0);
        if (await removed.exists()) {
          await removed.delete();
        }
      }
    } catch (e) {
      print("❌ Frame save error: $e");
    }
  }

  Future<List<int>?> convertToJpeg(CameraImage image) async {
    try {
      final int width = image.width;
      final int height = image.height;
      final img = imglib.Image(width: width, height: height);

      final Plane planeY = image.planes[0];
      final Plane planeU = image.planes[1];
      final Plane planeV = image.planes[2];

      final bytesY = planeY.bytes;
      final bytesU = planeU.bytes;
      final bytesV = planeV.bytes;

      final int strideY = planeY.bytesPerRow;
      final int strideUV = planeU.bytesPerRow;

      for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
          final int uvIndex = (y >> 1) * strideUV + (x >> 1);
          final int yIndex = y * strideY + x;

          final int Y = bytesY[yIndex];
          final int U = bytesU[uvIndex];
          final int V = bytesV[uvIndex];

          // YUV to RGB conversion
          final int r = (Y + 1.370705 * (V - 128)).clamp(0, 255).toInt();
          final int g = (Y - 0.337633 * (U - 128) - 0.698001 * (V - 128))
              .clamp(0, 255)
              .toInt();
          final int b = (Y + 1.732446 * (U - 128)).clamp(0, 255).toInt();

          img.setPixelRgb(x, y, r, g, b);
        }
      }

      return imglib.encodeJpg(img);
    } catch (e) {
      print("Conversion error: $e");
      return null;
    }
  }

  // Future<List<int>?> convertToJpeg(CameraImage image) async {
  //   try {
  //     final WriteBuffer allBytes = WriteBuffer();
  //     for (Plane plane in image.planes) {
  //       allBytes.putUint8List(plane.bytes);
  //     }
  //     final bytess = allBytes.done().buffer.asUint8List();

  //     final img = imglib.Image.fromBytes(
  //       width: image.width,
  //       height: image.height,
  //       bytes: bytess,
  //       numChannels: 4,
  //     );

  //     return imglib.encodeJpg(img); // returns List<int>
  //   } catch (e) {
  //     print("Conversion error: $e");
  //     return null;
  //   }
  // }

  /// Endpoint to receive object found notification
  void startCallbackListener() async {
    final server = await HttpServer.bind(InternetAddress.anyIPv4, 5001);
    print("Callback listener running on port 5001");

    server.listen((HttpRequest request) async {
      if (request.uri.path == "/found" && request.method == "POST") {
        final content = await utf8.decoder.bind(request).join();
        final data = jsonDecode(content);
        final message = data['message'];
        await tts.speak(message);
        request.response
          ..statusCode = 200
          ..write("Callback received")
          ..close();
      } else {
        request.response
          ..statusCode = 404
          ..write("Not Found")
          ..close();
      }
    });
  }

  Future<void> stopDetection() async {
    await tts.speak("Finding Stop");
    final response = await http.post(
      Uri.parse("http://192.168.29.169:5000/stop_detection"),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      print("Detection stopped.");
    } else {
      print("Failed to stop detection.");
    }
  }

  // void toggleDetection() async {
  //   if (isDetecting) {
  //     setState(() => isDetecting = false);
  //     speech.stop(); // stop voice listening
  //     await stopDetection();
  //     await controller.stopVideoRecording().catchError((_) {});
  //     print("Detection stopped");
  //   } else {
  //     setState(() => isDetecting = true);
  //     await startDetection();
  //     // listenForHelp(); // starts passive help listening
  //   }
  // }

  @override
  void initState() {
    super.initState();
    _welcomeMessage();
    startCallbackListener();
    initCamera();
  }

  Future<void> _welcomeMessage() async {
    await tts.setLanguage("en-US");
    await tts.setSpeechRate(0.5); // optional for better clarity
    await tts.speak("Welcome to DrishtiMate");
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: toggleDetection,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: const Text(
            "DrishtiMate",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.black.withOpacity(0.5),
          elevation: 0,
          centerTitle: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1D1E33), Color(0xFF111328)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: isDetecting
              ? Stack(
                  children: [
                    CameraPreview(controller),
                    Positioned(
                      bottom: 30,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Text(
                            "Detecting...",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.touch_app, size: 80, color: Colors.white70),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 24),
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: const Text(
                          "Tap anywhere to start detection",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
