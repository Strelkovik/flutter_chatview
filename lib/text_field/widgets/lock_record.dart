library voice_message_recorder;

import 'package:chatview/text_field/provider/sound_record_notifier.dart';
import 'package:flutter/material.dart';

import '../recorderSize.dart';

/// This Class Represent Icons To swap top to lock recording
class LockRecord extends StatefulWidget {
  /// Object From Provider Notifier
  final SoundRecordNotifier soundRecorderState;
  // ignore: sort_constructors_first

  final Widget? lockIcon;
  const LockRecord({
    this.lockIcon,
    required this.soundRecorderState,
    super.key,
  });
  @override
  _LockRecordState createState() => _LockRecordState();
}

class _LockRecordState extends State<LockRecord> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    /// If click the Button Then send show lock and un lock icon
    if (!widget.soundRecorderState.buttonPressed) return Container();
    return AnimatedPadding(
      duration: const Duration(seconds: 1),
      padding: Spacing.all(
          widget.soundRecorderState.second % 2 == 0 ? 0 : RecorderSize.x0),
      child: Transform.translate(
        offset: const Offset(0, -70),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(RecorderSize.x12),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeIn,
                opacity: widget.soundRecorderState.edge >= 50 ? 0 : 1,
                child: Container(
                  height: RecorderSize.x50 -
                              widget.soundRecorderState.heightPosition <
                          0
                      ? 0
                      : RecorderSize.x50 -
                          widget.soundRecorderState.heightPosition,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade300,
                  ),
                  child: Padding(
                    padding: Spacing.all(RecorderSize.x8),
                    child: widget.lockIcon ??
                        Stack(
                          children: [
                            Align(
                              alignment: Alignment.topCenter,
                              child: AnimatedOpacity(
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeIn,
                                  opacity:
                                      widget.soundRecorderState.second % 2 != 0
                                          ? 0
                                          : 1,
                                  child: const Icon(
                                    Icons.lock_outline_rounded,
                                    color: Colors.red,
                                  )),
                            ),
                            Align(
                              alignment: Alignment.topCenter,
                              child: AnimatedOpacity(
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeIn,
                                  opacity:
                                      widget.soundRecorderState.second % 2 == 0
                                          ? 0
                                          : 1,
                                  child: const Icon(
                                    Icons.lock_open_rounded,
                                    color: Colors.red,
                                  )),
                            ),
                          ],
                        ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
