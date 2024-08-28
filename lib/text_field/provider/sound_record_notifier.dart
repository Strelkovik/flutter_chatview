import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:chatview/text_field/audio_encoder_type.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

class SoundRecordNotifier extends ChangeNotifier {
  int _localCounterForMaxRecordTime = 0;
  GlobalKey key = GlobalKey();
  int? maxRecordTime;

  /// This Timer Just For wait about 1 second until starting record
  Timer? _timer;

  /// This time for counter wait about 1 send to increase counter
  Timer? _timerCounter;

  /// Used when user enter the needed path
  String initialStorePathRecord = "";

  /// recording mp3 sound Object
  Record recordMp3 = Record();

  /// recording mp3 sound to check if all permisiion passed
  bool _isAcceptedPermission = false;

  /// used to update state when user draggable to the top state
  double currentButtonHeihtPlace = 0;

  /// used to know if isLocked recording make the object true
  /// else make the object isLocked false
  bool isLocked = false;

  /// when pressed in the recording mic button convert change state to true
  /// else still false
  bool isShow = false;

  /// to show second of recording
  late int second;

  /// to show minute of recording
  late int minute;

  /// to know if pressed the button
  late bool buttonPressed;

  /// used to update space when dragg the button to left
  late double edge;
  late bool loopActive;

  /// store final path where user need store mp3 record
  late bool startRecord;

  /// store the value we draggble to the top
  late double heightPosition;

  /// store status of record if lock change to true else
  /// false
  late bool lockScreenRecord;
  late String mPath;
  late bool showAnimation;

  /// function called when start recording
  Function()? startRecording;
  Function(File soundFile, String time) sendRequestFunction;

  /// function called when stop recording, return the recording time (even if time < 1)
  Function(String time)? stopRecording;

  late AudioEncoderType encode;

  // ignore: sort_constructors_first

  SoundRecordNotifier({
    required this.stopRecording,
    required this.sendRequestFunction,
    required this.startRecording,
    this.edge = 0.0,
    this.minute = 0,
    this.second = 0,
    this.buttonPressed = false,
    this.showAnimation = false,
    this.loopActive = false,
    this.mPath = '',
    this.startRecord = false,
    this.heightPosition = 0,
    this.lockScreenRecord = false,
    this.encode = AudioEncoderType.AAC,
    this.maxRecordTime,
  }) {
    voidInitialSound();
  }

  /// To increase counter after 1 sencond
  void _mapCounterGenerater() {
    _timerCounter = Timer(const Duration(seconds: 1), () {
      _increaseCounterWhilePressed();
      if (buttonPressed) _mapCounterGenerater();
    });
  }

  finishRecording() async {
    if (buttonPressed) {
      if (second > 1 || minute > 0) {
        await resetEdgePadding();
        String path = mPath;
        String time = "$minute:$second";
        stopRecording!(time);
        sendRequestFunction(File.fromUri(Uri(path: path)), time);
      }
      // playSound('packages/voice_message_recorder/assets/sounds/delete.mp3');
    }
    resetEdgePadding();
  }

  /// used to reset all value to initial value when end the record
  resetEdgePadding() async {
    _localCounterForMaxRecordTime = 0;
    isLocked = false;
    edge = 0;
    buttonPressed = false;
    second = 0;
    minute = 0;
    isShow = false;
    key = GlobalKey();
    heightPosition = 0;
    lockScreenRecord = false;
    if (_timer != null) _timer!.cancel();
    if (_timerCounter != null) _timerCounter!.cancel();
    await recordMp3.stop();

    notifyListeners();
  }

  String _getSoundExtention() {
    if (encode == AudioEncoderType.AAC ||
        encode == AudioEncoderType.AAC_LD ||
        encode == AudioEncoderType.AAC_HE ||
        encode == AudioEncoderType.OPUS) {
      return ".m4a";
    } else {
      return ".3gp";
    }
  }

  /// used to get the current store path
  Future<String> getFilePath() async {
    String sdPath = "";
    Directory tempDir = await getTemporaryDirectory();
    sdPath =
        initialStorePathRecord.isEmpty ? tempDir.path : initialStorePathRecord;
    var d = Directory(sdPath);
    if (!d.existsSync()) {
      d.createSync(recursive: true);
    }
    DateTime now = DateTime.now();
    String convertedDateTime =
        "${now.year.toString()}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}-${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
    // print("the current data is $convertedDateTime");
    String storagePath = "$sdPath/$convertedDateTime${_getSoundExtention()}";
    mPath = storagePath;
    return storagePath;
  }

  /// used to change the draggable to top value
  setNewInitialDraggableHeight(double newValue) {
    currentButtonHeihtPlace = newValue;
  }

  /// used to change the draggable to top value
  /// or To The X vertical
  /// and update this value in screen
  updateScrollValue(Offset currentValue, BuildContext context) async {
    if (buttonPressed == true) {
      final x = currentValue;

      /// take the diffrent between the origin and the current
      /// draggable to the top place
      double hightValue = currentButtonHeihtPlace - x.dy;

      /// if reached to the max draggable value in the top
      if (hightValue >= 50) {
        isLocked = true;
        lockScreenRecord = true;
        hightValue = 50;
      }
      if (hightValue < 0) hightValue = 0;
      heightPosition = hightValue;
      lockScreenRecord = isLocked;

      /// this operation for update X oriantation
      /// draggable to the left or right place
      try {
        // Ширина экрана
        showAnimation = true;

        final double screenWidth = MediaQuery.sizeOf(context).width;

        edge = screenWidth - x.dx;
        print("the edge is ${edge / screenWidth}");

        if (edge < 40) {
          edge = 0;
          showAnimation = false;
        }
        if (edge > screenWidth) edge = screenWidth;
        if (edge / screenWidth > 0.4) {
          resetEdgePadding();
        }
      } catch (e) {
        // Обработка ошибок (например, если key не доступен)
      }
      notifyListeners();
    }
  }

  /// this function to manage counter value
  /// when reached to 60 sec
  /// reset the sec and increase the min by 1
  _increaseCounterWhilePressed() async {
    if (loopActive) {
      return;
    }

    loopActive = true;
    if (maxRecordTime != null) {
      if (_localCounterForMaxRecordTime >= maxRecordTime!) {
        loopActive = false;
        finishRecording();
      }
      _localCounterForMaxRecordTime++;
    }
    second = second + 1;
    buttonPressed = buttonPressed;
    if (second == 60) {
      second = 0;
      minute = minute + 1;
    }

    notifyListeners();
    loopActive = false;
    notifyListeners();
  }

  /// this function to start record voice
  record(Function()? startRecord) async {
    if (!_isAcceptedPermission) {
      await Permission.microphone.request();
      await Permission.manageExternalStorage.request();
      await Permission.storage.request();
      _isAcceptedPermission = true;
    }
    buttonPressed = true;
    String recordFilePath = await getFilePath();
    _timer = Timer(const Duration(milliseconds: 900), () {
      recordMp3.start(path: recordFilePath);
    });

    if (startRecord != null) {
      // playSound('packages/voice_message_recorder/assets/sounds/record.mp3');
      startRecord();
    }

    _mapCounterGenerater();
    // notifyListeners();

    notifyListeners();
  }

  AudioPlayer audioPlayer = AudioPlayer();
  final player = AudioPlayer();
  Future<void> playSound(String path) async {
    try {
      final bytes = await rootBundle.load(path);

      await audioPlayer.play(BytesSource(bytes.buffer.asUint8List()));
    } catch (e) {
      if (kDebugMode) {
        print('Error loading audion on recording button: $e');
      }
    }
  }

  /// to check permission
  voidInitialSound() async {
    // if (Platform.isIOS) _isAcceptedPermission = true;

    startRecord = false;
    final status = await Permission.microphone.status;
    if (status.isGranted) {
      final result = await Permission.storage.request();
      if (result.isGranted) {
        _isAcceptedPermission = true;
      }
    }
  }
}
