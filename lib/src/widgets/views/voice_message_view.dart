import 'package:chatview/chatview.dart';
import 'package:chatview/src/widgets/reaction_widget.dart';
import 'package:chatview/src/widgets/read_indicator.dart';
import 'package:flutter/material.dart';
import 'package:voice_message_player/voice_message_player.dart';

class VoiceMessageView extends StatefulWidget {
  const VoiceMessageView({
    Key? key,
    required this.screenWidth,
    required this.message,
    required this.isMessageBySender,
    this.inComingChatBubbleConfig,
    this.outgoingChatBubbleConfig,
    this.onMaxDuration,
    this.messageReactionConfig,
    this.config,
  }) : super(key: key);

  /// Provides configuration related to voice message.
  final VoiceMessageConfiguration? config;

  /// Allow user to set width of chat bubble.
  final double screenWidth;

  /// Provides message instance of chat.
  final Message message;
  final Function(int)? onMaxDuration;

  /// Represents current message is sent by current user.
  final bool isMessageBySender;

  /// Provides configuration of reaction appearance in chat bubble.
  final MessageReactionConfiguration? messageReactionConfig;

  /// Provides configuration of chat bubble appearance from other user of chat.
  final ChatBubble? inComingChatBubbleConfig;

  /// Provides configuration of chat bubble appearance from current user of chat.
  final ChatBubble? outgoingChatBubbleConfig;

  @override
  State<VoiceMessageView> createState() => _VoiceMessageViewState();
}

class _VoiceMessageViewState extends State<VoiceMessageView> {
  late VoiceController voiceController;
  late Color mainColor;

  @override
  void initState() {
    super.initState();
    voiceController = VoiceController(
      audioSrc: widget.message.message,
      onComplete: () {
        /// do something on complete
      },
      onPause: () {
        /// do something on pause
      },
      onPlaying: () {
        /// do something on playing
      },
      onError: (err) {
        /// do somethin on error
      },
      maxDuration: const Duration(seconds: 60),
      noiseCount: 50,
      isFile: false,
    );
    mainColor = widget.config?.decoration?.color ??
        widget.outgoingChatBubbleConfig?.color ??
        Colors.white;
  }

  @override
  void dispose() {
    // voiceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          margin: EdgeInsets.fromLTRB(
              5, 0, 6, widget.message.reaction.reactions.isNotEmpty ? 15 : 2),
          child: VoiceMessagePlayer(
            innerPadding: 6,
            stopDownloadingIcon: Icon(
              Icons.close,
              color: widget.config?.itemColor ?? Colors.white,
            ),
            pauseIcon: widget.config?.pauseIcon ??
                Icon(
                  Icons.stop,
                  color: widget.config?.itemColor ?? Colors.white,
                  size: 30,
                ),
            playIcon: Icon(
              Icons.play_arrow,
              color: widget.config?.itemColor ?? Colors.white,
              size: 30,
            ),
            circlesColor: widget.isMessageBySender ? mainColor : Colors.white,

            circlesTextStyle: widget.isMessageBySender
                ? widget.inComingChatBubbleConfig?.textStyle
                        ?.copyWith(fontSize: 10) ??
                    const TextStyle(color: Colors.white, fontSize: 10)
                : widget.outgoingChatBubbleConfig?.textStyle
                        ?.copyWith(fontSize: 10) ??
                    const TextStyle(color: Colors.white, fontSize: 10),
            playPauseButtonLoadingColor:
                widget.config?.itemColor ?? Colors.white,

            backgroundColor: widget.isMessageBySender
                ? mainColor
                : widget.inComingChatBubbleConfig?.color ?? Colors.white,
            activeSliderColor: widget.config?.itemColor ?? Colors.white,
            // circlesColor: Colors.white,
            controller: voiceController,
          ),
        ),
        if (widget.message.reaction.reactions.isNotEmpty)
          ReactionWidget(
            isMessageBySender: widget.isMessageBySender,
            reaction: widget.message.reaction,
            messageReactionConfig: widget.messageReactionConfig,
          ),
        Positioned(
          bottom: widget.message.reaction.reactions.isNotEmpty ? 18 : 5,
          right: widget.isMessageBySender ? 15 : 0,
          child: SizedBox(
            width: 55,
            height: 20,
            child: ReadIndicator(
              message: widget.message,
              isMessageBySender: widget.isMessageBySender,
              textStyle: const TextStyle(
                color: Colors.black,
                fontSize: 10,
              ),
              indicatorColor:
                  widget.outgoingChatBubbleConfig?.readIndicatorColor,
              filledIndicatorColor:
                  widget.outgoingChatBubbleConfig?.filledReadIndicatorColor,
            ),
          ),
        )
      ],
    );
  }
}
