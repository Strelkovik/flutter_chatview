library voice_message_recorder;

import 'dart:io';

import 'package:camera/camera.dart';
import 'package:chatview/chatview.dart';
import 'package:chatview/src/utils/debounce.dart';
import 'package:chatview/text_field/provider/sound_record_notifier.dart';
import 'package:chatview/text_field/widgets/show_counter.dart';
import 'package:chatview/text_field/widgets/show_mic_with_text.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../audio_encoder_type.dart';
import '../recorderSize.dart';
import '../widgets/lock_record.dart';
import '../widgets/sound_recorder_when_locked_design.dart';
import 'camera/CameraView.dart';
import 'camera/camera.dart';
import 'filePicker.dart';

class VoiceMessageRecorder extends StatefulWidget {
  /// use it for change back ground of cancel
  final Color? cancelTextBackGroundColor;

  /// function return the recording sound file and the time
  final Function(File soundFile, String time) functionSendVoice;

  /// function called when start recording
  final Function()? functionStartRecording;

  /// function called when stop recording, return the recording time (even if time < 1)
  final Function(String time)? functionStopRecording;
  final Function(bool) functionRecorderStatus;
  final Function(String camera)? functionCameraPicker;
  final Function(String file)? functionFilePicker;
  final Function(String emogi)? functionEmogiPicker;
  final Function(String text) functionSendTextMessage;
  final Function(String) functionDataCameraReceived;

  /// recording Icon That pressesd to start record
  final Widget? recordIcon;

  /// recording Icon when user locked the record
  final Widget? recordIconWhenLockedRecord;

  /// use to change the backGround Icon when user recording sound
  final Color? recordIconBackGroundColor;

  /// use to change the Icon backGround color when user locked the record
  final Color? sendButtonBackgroundColor;

  /// use to change all recording widget color
  final Color? textFieldBackGroundColor;
  final Color? backGroundColor;

  /// use to change the counter style
  final TextStyle? timerTextStyle;

  /// text to know user should drag in the left to cancel record
  final String? slideToCancelText;

  /// use to change slide to cancel textstyle
  final TextStyle? slideToCancelTextStyle;

  /// this text show when lock record and to tell user should press in this text to cancel recod
  final String? cancelText;

  /// use to change cancel text style
  final TextStyle? cancelTextStyle;

  /// put you file directory storage path if you didn't pass it take deafult path
  final String? storeSoundRecoringPath;

  /// Chose the encode type
  final AudioEncoderType encode;

  /// use if you want change the raduis of un record
  final BorderRadius? radius;

  // use to change the counter back ground color
  final Color? timerBackgroundColor;
  final Color? backGroundBoarderColor;

  final double? boarderRadius;
  // use to change lock icon to design you need it
  final Widget? lockButton;

  // use it to change send button when user lock the record
  final Widget? sendButtonIcon;

  // this function called when cancel record function

  // use to set max record time in second
  final int? maxRecordTimeInSecond;

  // use to change full package Height
  final double fullRecordPackageHeight;

  final double initRecordPackageWidth;
  final double? verticalPadding;

  final TextEditingController textFieldController;

  /// Provides focusNode for focusing text field.
  final FocusNode? focusNode;

  final SendMessageConfiguration? sendMessageConfig;

  // /// Provides configuration of default text field in chat.
  // final SendMessageConfiguration? sendMessageConfig;
  // ignore: sort_constructors_first
  const VoiceMessageRecorder({
    super.key,
    required this.functionSendVoice,
    required this.functionRecorderStatus,
    required this.functionSendTextMessage,
    required this.functionDataCameraReceived,
    required this.sendMessageConfig,
    required this.textFieldController,
    this.focusNode,
    this.sendButtonIcon,
    this.initRecordPackageWidth = 50,
    this.fullRecordPackageHeight = 50,
    this.maxRecordTimeInSecond,
    this.storeSoundRecoringPath = "",
    this.functionStartRecording,
    this.functionStopRecording,
    this.recordIcon,
    this.lockButton,
    this.timerBackgroundColor,
    this.recordIconWhenLockedRecord,
    this.recordIconBackGroundColor = const Color(0xFF128C7E),
    this.sendButtonBackgroundColor = const Color(0xFF128C7E),
    this.textFieldBackGroundColor = const Color(0xffffffff),
    this.backGroundBoarderColor = const Color(0xffffffff),
    this.backGroundColor = Colors.transparent,
    this.cancelTextStyle,
    this.timerTextStyle,
    this.slideToCancelTextStyle,
    this.slideToCancelText = "Потяните чтобы отменить",
    this.cancelText = "Отменить",
    this.encode = AudioEncoderType.AAC,
    this.cancelTextBackGroundColor = const Color(0xfffaefef),
    this.radius,
    this.boarderRadius = 30,
    this.verticalPadding = 5,
    this.functionCameraPicker,
    this.functionFilePicker,
    this.functionEmogiPicker,
  });

  @override
  _VoiceMessageRecorder createState() => _VoiceMessageRecorder();
}

class _VoiceMessageRecorder extends State<VoiceMessageRecorder> {
  late SoundRecordNotifier soundRecordNotifier;

  ValueNotifier<TypeWriterStatus> composingStatus =
      ValueNotifier(TypeWriterStatus.typed);

  late Debouncer debouncer;
  @override
  void initState() {
    debouncer = Debouncer(
        widget.sendMessageConfig?.textFieldConfig?.compositionThresholdTime ??
            const Duration(seconds: 1));
    soundRecordNotifier = SoundRecordNotifier(
      maxRecordTime: widget.maxRecordTimeInSecond,
      startRecording: widget.functionStartRecording ?? () {},
      stopRecording: widget.functionStopRecording ?? (String x) {},
      sendRequestFunction: widget.functionSendVoice,
    );

    composingStatus.addListener(() {
      widget.sendMessageConfig?.textFieldConfig?.onMessageTyping
          ?.call(composingStatus.value);
    });

    soundRecordNotifier.initialStorePathRecord =
        widget.storeSoundRecoringPath ?? "";
    soundRecordNotifier.isShow = false;
    soundRecordNotifier.voidInitialSound();
    super.initState();
  }

  @override
  void dispose() {
    debouncer.dispose();
    composingStatus.dispose();
    super.dispose();
  }

  bool switchTextVoice = true;
  // Initial height of the container
  late final FocusNode textInputFocus = widget.focusNode ?? FocusNode();
  bool show = false;
  @override
  Widget build(BuildContext context) {
    RecorderSize().init(context);
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => CameraState()),
          ChangeNotifierProvider(create: (context) => soundRecordNotifier),
        ],
        child: Consumer<SoundRecordNotifier>(
          builder: (context, value, _) {
            return Directionality(
                textDirection: TextDirection.rtl, child: makeBody(value));
          },
        ));
  }

  Widget makeBody(SoundRecordNotifier state) {
    if (soundRecordNotifier.buttonPressed == false &&
        soundRecordNotifier.isLocked == false &&
        soundRecordNotifier.isShow == false &&
        soundRecordNotifier.lockScreenRecord == false) {
      widget.functionRecorderStatus(true);
    } else {
      widget.functionRecorderStatus(false);
    }

    return Container(
      decoration: BoxDecoration(color: widget.backGroundColor),
      padding: Spacing.symmetric(vertical: widget.verticalPadding!),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Align(
                  alignment: Alignment.centerLeft,
                  child: widget.textFieldController.text.isEmpty
                      ? GestureDetector(
                          onHorizontalDragUpdate: (scrollEnd) {
                            state.updateScrollValue(
                                scrollEnd.globalPosition, context);
                          },
                          onHorizontalDragEnd: (x) {
                            // print('locpos ${x.localPosition.dx}');
                            if (state.buttonPressed && !state.isLocked) {
                              state.resetEdgePadding();
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(widget.boarderRadius!),
                                topRight:
                                    Radius.circular(widget.boarderRadius!),
                              ),
                            ),
                            child: recordVoice(state),
                          ),
                        )
                      : Padding(
                          padding: Spacing.only(
                              left: RecorderSize.x7, right: RecorderSize.x7),
                          child: InkWell(
                            onTap: () {
                              widget.functionSendTextMessage(
                                  widget.textFieldController.text);
                              widget.textFieldController.clear();
                              setState(() {});
                            },
                            child: Transform.scale(
                              scale: 1,
                              child: ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(RecorderSize.x600),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeIn,
                                  width: RecorderSize.x42,
                                  height: RecorderSize.x42,
                                  child: Container(
                                    color: widget.sendButtonBackgroundColor,
                                    child: Padding(
                                      padding: Spacing.all(RecorderSize.x4),
                                      child: Icon(
                                        Icons.send,
                                        textDirection: TextDirection.ltr,
                                        size: RecorderSize.x26,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )),
              if (!soundRecordNotifier.isShow)
                Container(
                  width: MediaQuery.of(context).size.width * 0.83,
                  height: widget.textFieldController.text.length > 90
                      ? RecorderSize.x130
                      : widget.textFieldController.text.length > 69
                          ? RecorderSize.x110
                          : widget.textFieldController.text.length > 48
                              ? RecorderSize.x100
                              : widget.textFieldController.text.length > 23
                                  ? RecorderSize.x80
                                  : widget.fullRecordPackageHeight,
                  padding: EdgeInsets.symmetric(
                    horizontal: RecorderSize.x20 * 0.50,
                  ),
                  decoration: BoxDecoration(
                    color: widget.textFieldBackGroundColor,
                    border: Border.all(color: const Color(0xFFEFEFEF)),
                    borderRadius: BorderRadius.circular(
                        widget.textFieldController.text.length > 23
                            ? RecorderSize.x18
                            : widget.boarderRadius!),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          pickFile(
                            extension: [
                              'jpg',
                              'jpeg',
                              'png',
                            ],
                          );
                          // showModalBottomSheet(
                          //     backgroundColor: Colors.transparent,
                          //     context: context,
                          //     builder: (builder) => bottomSheet());
                        },
                        child: const Icon(
                          Icons.attach_file,
                          color: Colors.black,
                        ),
                      ),
                      if (widget.textFieldController.text.isEmpty)
                        SizedBox(width: RecorderSize.x10),
                      if (widget.textFieldController.text.isEmpty)
                        GestureDetector(
                          onTap: () {
                            _checkPermissionAndOpenCamera();
                          },
                          child: const Icon(
                            Icons.camera_alt_outlined,
                            color: Colors.black,
                          ),
                        ),
                      Flexible(
                        child: Directionality(
                          textDirection: TextDirection.ltr,
                          child: TextField(
                            textDirection: TextDirection.ltr,
                            focusNode: textInputFocus,
                            controller: widget.textFieldController,
                            onTap: () {
                              show = false;
                              setState(() {});
                            },
                            onChanged: (val) {
                              _onChanged(val);
                              show = false;
                              setState(() {});
                            },
                            maxLines: 4, // Limit to 3 lines
                            decoration: const InputDecoration(
                              // contentPadding: EdgeInsets.only(
                              //   top: RecorderSize.x12,
                              //   bottom: RecorderSize.x1,
                              // ),
                              hintStyle: TextStyle(
                                color: Colors.grey,
                              ),
                              hintText: '',
                              labelStyle: TextStyle(
                                color: Colors.grey,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: RecorderSize.x3,
                      ),
                      GestureDetector(
                        child: Icon(
                          show ? Icons.keyboard : Icons.emoji_emotions_outlined,
                        ),
                        onTap: () {
                          if (!show) {
                            textInputFocus.unfocus();
                            textInputFocus.canRequestFocus = false;
                          }
                          setState(() {
                            show = !show;
                          });
                        },
                      )
                    ],
                  ),
                ),
            ],
          ),
          show ? emojiSelect() : Container(),
        ],
      ),
    );
  }

  void _onChanged(String inputText) {
    debouncer.run(() {
      composingStatus.value = TypeWriterStatus.typed;
    }, () {
      composingStatus.value = TypeWriterStatus.typing;
    });
    // _inputText.value = inputText;
  }

  void _checkPermissionAndOpenCamera() async {
    // PermissionStatus status = await Permission.camera.status;
    // if (!status.isGranted) {
    //   status = await Permission.camera.request();
    //   if (status != PermissionStatus.granted) {
    //     // Handle denied permissions
    //     return;
    //   }
    // }
    _openCamera();
  }

  void _openCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        textInputFocus.unfocus();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CameraScreen(
              IconBackGroundColor: widget.recordIconBackGroundColor!,
              onDataCameraReceived: widget.functionDataCameraReceived,
              onDataVideoReceived: widget.functionDataCameraReceived,
            ),
          ),
        );
      } else {
        debugPrint("No camera available");
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Widget recordVoice(SoundRecordNotifier state) {
    if (kDebugMode) {
      print(" state.lockScreenRecord ${state.lockScreenRecord}");
    }
    if (state.lockScreenRecord == true) {
      return SoundRecorderWhenLockedDesign(
          cancelText: widget.cancelText,
          fullRecordPackageHeight: widget.fullRecordPackageHeight,
          // cancelRecordFunction: widget.cacnelRecording ?? () {},
          sendButtonIcon: widget.sendButtonIcon,
          lockRecordingBackGroundColor: widget.cancelTextBackGroundColor,
          cancelTextStyle: widget.cancelTextStyle,
          counterBackGroundColor: widget.timerBackgroundColor,
          sendButtonBackgroundColor:
              widget.sendButtonBackgroundColor ?? Colors.blue,
          counterTextStyle: widget.timerTextStyle,
          recordIconWhenLockedRecord: widget.recordIconWhenLockedRecord,
          sendRequestFunction: widget.functionSendVoice,
          soundRecordNotifier: state,
          stopRecording: widget.functionStopRecording,
          boarderRadius: widget.boarderRadius!,
          backGroundBoarderColor: widget.backGroundBoarderColor);
    }

    return Listener(
      onPointerDown: (details) async {
        state.setNewInitialDraggableHeight(details.position.dy);
        state.resetEdgePadding();

        soundRecordNotifier.isShow = true;
        state.showAnimation = false;
        state.record(widget.functionStartRecording);
      },
      onPointerUp: (details) async {
        if (!state.isLocked) {
          state.finishRecording();
        }
      },
      child: AnimatedContainer(
        curve: Curves.easeInOut,
        duration: Duration(
            milliseconds: soundRecordNotifier.isShow
                ? 0
                : soundRecordNotifier.showAnimation
                    ? 300
                    : 0),
        height: widget.fullRecordPackageHeight,
        width: (soundRecordNotifier.isShow)
            ? MediaQuery.of(context).size.width * 0.95
            : widget.initRecordPackageWidth,
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: Spacing.only(right: state.edge),
                child: Container(
                  decoration: BoxDecoration(
                    border: soundRecordNotifier.isShow
                        ? Border(
                            top: BorderSide(
                                color: widget.backGroundBoarderColor!),
                            bottom: BorderSide(
                                color: widget.backGroundBoarderColor!),
                            left: BorderSide(
                                color: widget.backGroundBoarderColor!))
                        : Border.all(color: Colors.transparent),
                    borderRadius: soundRecordNotifier.isShow
                        ? BorderRadius.only(
                            topLeft: Radius.circular(widget.boarderRadius!),
                            bottomLeft: Radius.circular(widget.boarderRadius!),
                            topRight: Radius.circular(widget.boarderRadius!),
                            bottomRight: Radius.circular(widget.boarderRadius!))
                        : widget.radius != null && !soundRecordNotifier.isShow
                            ? widget.radius
                            : BorderRadius.circular(0),
                    color: (soundRecordNotifier.isShow)
                        ? widget.textFieldBackGroundColor
                        : Colors.transparent,
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: ShowMicWithText(
                          initRecordPackageWidth: widget.initRecordPackageWidth,
                          counterBackGroundColor: widget.timerBackgroundColor,
                          recordButtonBackGroundColor:
                              widget.recordIconBackGroundColor,
                          fullRecordPackageHeight:
                              widget.fullRecordPackageHeight,
                          recordIcon: widget.recordIcon,
                          shouldShowText: soundRecordNotifier.isShow,
                          soundRecorderState: state,
                          slideToCancelTextStyle: widget.slideToCancelTextStyle,
                          slideToCancelText: widget.slideToCancelText,
                        ),
                      ),
                      if (soundRecordNotifier.isShow)
                        Center(
                          child: ShowCounter(
                              counterBackGroundColor:
                                  widget.timerBackgroundColor,
                              soundRecorderState: state,
                              fullRecordPackageHeight:
                                  widget.fullRecordPackageHeight),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              width: RecorderSize.x70,
              child: LockRecord(
                soundRecorderState: state,
                lockIcon: widget.lockButton,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> pickFile({required List<String> extension}) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      // allowedExtensions: extension,
    );

    final filePath = result?.files.single.path;
    final fileExtension = filePath?.split('.').last.toLowerCase();

    print(
        'File>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>. extension: $fileExtension');
    if (result != null) {
      if (result.files.single.path!.split('.').last.toLowerCase() == 'jpg' ||
          result.files.single.path!.split('.').last.toLowerCase() == 'jpeg' ||
          result.files.single.path!.split('.').last.toLowerCase() == 'png' ||
          result.files.single.path!.split('.').last.toLowerCase() == 'gif' ||
          result.files.single.path!.split('.').last.toLowerCase() == 'bmp') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CameraViewPage(
              IconBackGroundColor: widget.recordIconBackGroundColor!,
              path: result.files.single.path!,
              onDataCameraReceived: (s) {
                widget.functionDataCameraReceived(s);
                Navigator.of(context).pop();
                // Navigator.of(context).pop();
              },
            ),
          ),
        );
      }
      // else if (result.files.single.path!.split('.').last.toLowerCase() ==
      //         'mp4' ||
      //     result.files.single.path!.split('.').last.toLowerCase() == 'avi' ||
      //     result.files.single.path!.split('.').last.toLowerCase() == 'mov' ||
      //     result.files.single.path!.split('.').last.toLowerCase() == 'vmv' ||
      //     result.files.single.path!.split('.').last.toLowerCase() == 'flv') {
      //   Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //       builder: (context) => VideoViewPage(
      //           IconBackGroundColor: widget.recordIconBackGroundColor!,
      //           path: result.files.single.path!,
      //           onDataVideoReceived: widget.functionDataCameraReceived),
      //     ),
      //   );
      // }
      else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FileViewPage(
              IconBackGroundColor: widget.recordIconBackGroundColor!,
              path: result.files.single.path!,
              onDataFileReceived: widget.functionDataCameraReceived,
              audioExtensions: extension,
            ),
          ),
        );
      }
    } else {
      // User canceled the picker
    }
  }

  Widget emojiSelect() {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: EmojiPicker(
          onEmojiSelected: (category, emoji) {
            // show = false;
            setState(() {});
          },
          textEditingController: widget.textFieldController,
          // scrollController: _scrollController,
          config: Config(
            height: RecorderSize.x250,
            checkPlatformCompatibility: true,
            emojiViewConfig: const EmojiViewConfig(
                // Issue: https://github.com/flutter/flutter/issues/28894
                emojiSizeMax: 28
                /* (foundation.defaultTargetPlatform ==
          TargetPlatform.iOS
          ? 1.2
          : 1.0),*/
                ),
            swapCategoryAndBottomBar: false,
            skinToneConfig: SkinToneConfig(
                indicatorColor: widget.recordIconBackGroundColor!),
            categoryViewConfig: CategoryViewConfig(
                iconColorSelected: widget.recordIconBackGroundColor!,
                indicatorColor: widget.recordIconBackGroundColor!),
            bottomActionBarConfig: const BottomActionBarConfig(enabled: false),
            searchViewConfig: SearchViewConfig(
                backgroundColor: widget.recordIconBackGroundColor!),
          )),
    );
  }
}
