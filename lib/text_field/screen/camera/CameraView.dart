import 'dart:io';

import 'package:flutter/material.dart';

class CameraViewPage extends StatelessWidget {
  final Function(String) onDataCameraReceived;
  final Color IconBackGroundColor;
  const CameraViewPage({
    super.key,
    required this.path,
    required this.IconBackGroundColor,
    required this.onDataCameraReceived,
  });
  final String path;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(0, 0, 0, 1),
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height - 150,
              child: Image.file(
                File(path),
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
                bottom: 8,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        onDataCameraReceived(path);
                      },
                      child: const Text('Отправить'),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
