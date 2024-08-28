library voice_message_recorder;

import 'package:chatview/text_field/provider/sound_record_notifier.dart';
import 'package:flutter/material.dart';

import '../recorderSize.dart';

/// Used this class to show counter and mic Icon
class ShowCounter extends StatelessWidget {
  final SoundRecordNotifier soundRecorderState;
  final TextStyle? counterTextStyle;
  final Color? counterBackGroundColor;
  final double fullRecordPackageHeight;
  // ignore: sort_constructors_first
  const ShowCounter({
    required this.soundRecorderState,
    required this.fullRecordPackageHeight,
    super.key,
    this.counterTextStyle,
    required this.counterBackGroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        decoration: BoxDecoration(
            color: counterBackGroundColor ?? const Color(0xfff5f4f4),
            borderRadius: BorderRadius.all(Radius.circular(RecorderSize.x30))),
        height: fullRecordPackageHeight * 0.98,
        width: MediaQuery.of(context).size.width * 0.3,
        child: Padding(
          padding: Spacing.only(top: RecorderSize.x6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(width: RecorderSize.x30),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    soundRecorderState.second.toString().padLeft(2, '0'),
                    style: counterTextStyle ??
                        const TextStyle(color: Colors.black),
                  ),
                  SizedBox(width: RecorderSize.x3),
                  const Text(" : "),
                  Text(
                    soundRecorderState.minute.toString().padLeft(2, '0'),
                    style: counterTextStyle ??
                        const TextStyle(color: Colors.black),
                  ),
                ],
              ),
              SizedBox(width: RecorderSize.x3),
              AnimatedOpacity(
                duration: const Duration(seconds: 1),
                opacity: soundRecorderState.second % 2 == 0 ? 1 : 0,
                child: const Icon(
                  Icons.mic,
                  color: Colors.red,
                ),
              ),
              SizedBox(width: RecorderSize.x10),
            ],
          ),
        ),
      ),
    );
  }
}
