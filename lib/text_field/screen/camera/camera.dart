import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../recorderSize.dart';
import 'CameraView.dart';
import 'VideoView.dart';

class CameraState extends ChangeNotifier {
  late CameraController _cameraController;
  late Future<void> cameraValue;
  bool isRecording = false;
  bool flash = false;
  bool isCameraFront = true;
  double transform = 0;

  CameraState() {
    initializeCamera();
  }
  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  Future<void> initializeCamera() async {
    final cameras = await availableCameras();
    _cameraController = CameraController(cameras[0], ResolutionPreset.high);
    cameraValue = _cameraController.initialize();
    notifyListeners();
  }

  void toggleFlash() {
    flash = !flash;
    flash
        ? _cameraController.setFlashMode(FlashMode.torch)
        : _cameraController.setFlashMode(FlashMode.off);
    notifyListeners();
  }

  void switchCamera() async {
    isCameraFront = !isCameraFront;
    transform += pi;
    final cameras = await availableCameras();
    int cameraPos = isCameraFront ? 0 : 1;
    _cameraController =
        CameraController(cameras[cameraPos], ResolutionPreset.high);
    cameraValue = _cameraController.initialize();
    notifyListeners();
  }

  void takePhoto(BuildContext context, Color IconBackGroundColor,
      Function(String) onDataCameraReceived) async {
    XFile file = await _cameraController.takePicture();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (builder) => CameraViewPage(
          path: file.path,
          IconBackGroundColor: IconBackGroundColor,
          onDataCameraReceived: onDataCameraReceived,
        ),
      ),
    );
  }
}

class CameraScreen extends StatelessWidget {
  final Color IconBackGroundColor;
  final Function(String) onDataVideoReceived;
  final Function(String) onDataCameraReceived;
  const CameraScreen(
      {super.key,
      required this.IconBackGroundColor,
      required this.onDataCameraReceived,
      required this.onDataVideoReceived});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CameraState(),
      child: CameraScreenBody(
        IconBackGroundColor: IconBackGroundColor,
        onDataCameraReceived: onDataCameraReceived,
        onDataVideoReceived: onDataVideoReceived,
      ),
    );
  }
}

class CameraScreenBody extends StatelessWidget {
  final Function(String) onDataVideoReceived;
  final Color IconBackGroundColor;
  final Function(String) onDataCameraReceived;
  const CameraScreenBody(
      {super.key,
      required this.IconBackGroundColor,
      required this.onDataCameraReceived,
      required this.onDataVideoReceived});

  @override
  Widget build(BuildContext context) {
    final cameraState = Provider.of<CameraState>(context);
    return Scaffold(
      body: Stack(
        children: [
          FutureBuilder(
            future: cameraState.cameraValue,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: CameraPreview(cameraState._cameraController),
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
          Positioned(
            bottom: 0.0,
            child: Container(
              color: Colors.black,
              padding: EdgeInsets.only(
                  top: RecorderSize.x5, bottom: RecorderSize.x5),
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: Icon(
                          cameraState.flash ? Icons.flash_on : Icons.flash_off,
                          color: Colors.white,
                          size: RecorderSize.x28,
                        ),
                        onPressed: () => cameraState.toggleFlash(),
                      ),
                      GestureDetector(
                        onTap: () => !cameraState.isRecording
                            ? cameraState.takePhoto(context,
                                IconBackGroundColor, onDataCameraReceived)
                            : null,
                        child: cameraState.isRecording
                            ? Icon(
                                Icons.radio_button_on,
                                color: Colors.red,
                                size: RecorderSize.x80,
                              )
                            : Icon(
                                Icons.panorama_fish_eye,
                                color: Colors.white,
                                size: RecorderSize.x70,
                              ),
                      ),
                      IconButton(
                        icon: Transform.rotate(
                          angle: cameraState.transform,
                          child: Icon(
                            Icons.flip_camera_ios,
                            color: Colors.white,
                            size: RecorderSize.x28,
                          ),
                        ),
                        onPressed: () => cameraState.switchCamera(),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: RecorderSize.x4,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
