import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class VideoStreamer extends StatefulWidget {
  @override
  _VideoStreamerState createState() => _VideoStreamerState();
}

class _VideoStreamerState extends State<VideoStreamer> {
  CameraController? controller;
  List<CameraDescription>? cameras;
  bool isRecording = false;

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  Future<void> initCamera() async {
    cameras = await availableCameras();
    controller = CameraController(cameras![0], ResolutionPreset.medium);
    await controller!.initialize();
    setState(() {});
  }

  Future<void> startRecording() async {
    if (!controller!.value.isInitialized) return;

    final directory = await getTemporaryDirectory();
    final path = '${directory.path}/video.mp4';

    await controller!.startVideoRecording();
    setState(() => isRecording = true);
  }

  Future<void> stopRecording() async {
    final file = await controller!.stopVideoRecording();
    setState(() => isRecording = false);
    await sendVideoToBackend(file.path);
  }

  Future<void> sendVideoToBackend(String path) async {
    var uri = Uri.parse('http://10.187.157.6:5000/upload');
    var request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('video', path));
    var response = await request.send();
    if (response.statusCode == 200) {
      print('Video sent successfully');
    } else {
      print('Failed to send video');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(title: Text("Video Streamer")),
      body: Column(
        children: [
          Expanded(child: CameraPreview(controller!)),
          ElevatedButton(
            onPressed: isRecording ? stopRecording : startRecording,
            child: Text(isRecording ? 'Stop' : 'Record'),
          )
        ],
      ),
    );
  }
}
