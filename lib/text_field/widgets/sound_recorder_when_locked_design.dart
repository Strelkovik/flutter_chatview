library voice_message_recorder;

import 'package:chatview/text_field/provider/sound_record_notifier.dart';
import 'package:chatview/text_field/widgets/show_counter.dart';
import 'package:flutter/material.dart';

import '../recorderSize.dart';

// ignore: must_be_immutable
class SoundRecorderWhenLockedDesign extends StatelessWidget {
  final double fullRecordPackageHeight;
  final SoundRecordNotifier soundRecordNotifier;
  final String? cancelText;
  final Function sendRequestFunction;
  final Function(String time)? stopRecording;
  final Widget? recordIconWhenLockedRecord;
  final TextStyle? cancelTextStyle;
  final TextStyle? counterTextStyle;
  final Color sendButtonBackgroundColor;
  final Color? counterBackGroundColor;
  final Color? lockRecordingBackGroundColor;
  final Color? backGroundBoarderColor;
  final double boarderRadius;
  final Widget? sendButtonIcon;

  // ignore: sort_constructors_first
  const SoundRecorderWhenLockedDesign({
    super.key,
    required this.fullRecordPackageHeight,
    required this.sendButtonIcon,
    required this.soundRecordNotifier,
    required this.cancelText,
    required this.sendRequestFunction,
    this.stopRecording,
    required this.recordIconWhenLockedRecord,
    required this.cancelTextStyle,
    required this.counterTextStyle,
    required this.sendButtonBackgroundColor,
    required this.counterBackGroundColor,
    required this.lockRecordingBackGroundColor,
    this.backGroundBoarderColor,
    required this.boarderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: Spacing.only(right: RecorderSize.x10),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.94,
        height: fullRecordPackageHeight,
        decoration: BoxDecoration(
          border: soundRecordNotifier.isShow
              ? Border(
                  top: BorderSide(color: backGroundBoarderColor!),
                  bottom: BorderSide(color: backGroundBoarderColor!),
                  left: BorderSide(color: backGroundBoarderColor!))
              : Border.all(color: Colors.transparent),
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(boarderRadius),
              bottomLeft: Radius.circular(boarderRadius),
              topRight: Radius.circular(boarderRadius),
              bottomRight: Radius.circular(boarderRadius)),
          color: (soundRecordNotifier.isShow)
              ? lockRecordingBackGroundColor
              : Colors.transparent,
        ),
        child: InkWell(
          onTap: () {
            soundRecordNotifier.isShow = false;
            soundRecordNotifier.resetEdgePadding();
          },
          child: Row(
            children: [
              InkWell(
                onTap: () async {
                  soundRecordNotifier.isShow = false;
                  soundRecordNotifier.finishRecording();
                },
                child: Transform.scale(
                  scale: 1.2,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(RecorderSize.x600),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeIn,
                      width: fullRecordPackageHeight - 9,
                      height: fullRecordPackageHeight - 9,
                      child: Container(
                        color: sendButtonBackgroundColor,
                        child: Padding(
                          padding: Spacing.all(RecorderSize.x4),
                          child: recordIconWhenLockedRecord ??
                              sendButtonIcon ??
                              Icon(
                                Icons.send,
                                textDirection: TextDirection.ltr,
                                size: RecorderSize.x26,
                                color: (soundRecordNotifier.buttonPressed)
                                    ? Colors.grey.shade200
                                    : Colors.black,
                              ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                    onTap: () {
                      soundRecordNotifier.isShow = false;
                      String time =
                          "${soundRecordNotifier.minute}:${soundRecordNotifier.second}";
                      if (stopRecording != null) stopRecording!(time);
                      soundRecordNotifier.resetEdgePadding();
                    },
                    child: Padding(
                      padding: Spacing.all(RecorderSize.x8),
                      child: Text(
                        cancelText ?? "",
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.clip,
                        style: cancelTextStyle ??
                            const TextStyle(
                              color: Colors.black,
                            ),
                      ),
                    )),
              ),
              ShowCounter(
                soundRecorderState: soundRecordNotifier,
                counterTextStyle: counterTextStyle,
                counterBackGroundColor: counterBackGroundColor,
                fullRecordPackageHeight: fullRecordPackageHeight,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
