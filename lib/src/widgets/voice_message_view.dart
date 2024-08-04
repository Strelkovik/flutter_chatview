import 'dart:async';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:chatview/chatview.dart';
import 'package:chatview/src/models/voice_message_configuration.dart';
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
  late PlayerController controller;
  late StreamSubscription<PlayerState> playerStateSubscription;

  final ValueNotifier<PlayerState> _playerState =
      ValueNotifier(PlayerState.stopped);

  PlayerState get playerState => _playerState.value;

  PlayerWaveStyle playerWaveStyle = const PlayerWaveStyle(scaleFactor: 70);

  late VoiceController voiceController;

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
      isFile: false,
    );
  }

  @override
  void dispose() {
    playerStateSubscription.cancel();
    controller.dispose();
    _playerState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        VoiceMessagePlayer(
          pauseIcon: widget.config?.pauseIcon ??
              const Icon(
                Icons.stop,
                color: Colors.white,
              ),
          playIcon: widget.config?.playIcon ??
              const Icon(
                Icons.play_arrow,
                color: Colors.white,
              ),
          backgroundColor: widget.isMessageBySender
              ? widget.outgoingChatBubbleConfig?.color ?? Colors.white
              : widget.inComingChatBubbleConfig?.color ?? Colors.white,
          activeSliderColor: widget.isMessageBySender
              ? widget.inComingChatBubbleConfig?.color ?? Colors.white
              : widget.outgoingChatBubbleConfig?.color ?? Colors.white,
          // circlesColor: Colors.white,
          controller: voiceController,
        ),
        if (widget.message.reaction.reactions.isNotEmpty)
          ReactionWidget(
            isMessageBySender: widget.isMessageBySender,
            reaction: widget.message.reaction,
            messageReactionConfig: widget.messageReactionConfig,
          ),
        Positioned(
          bottom: 5,
          right: widget.isMessageBySender ? 15 : 0,
          child: SizedBox(
            width: 55,
            height: 20,
            child: ReadIndicator(
              message: widget.message,
              isMessageBySender: widget.isMessageBySender,
              textStyle: TextStyle(
                color: widget.isMessageBySender ? Colors.white : Colors.black,
                fontSize: 10,
              ),
            ),
          ),
        )
      ],
    );
  }
}
