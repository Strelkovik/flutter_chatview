import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatview/chatview.dart';
import 'package:chatview/src/extensions/extensions.dart';
import 'package:chatview/src/widgets/reaction_widget.dart';
import 'package:chatview/src/widgets/read_indicator.dart';
import 'package:flutter/material.dart';

class CustomMessageView extends StatefulWidget {
  const CustomMessageView({
    super.key,
    required this.customMessageModel,
    required this.message,
    required this.isMessageBySender,
    this.inComingChatBubbleConfig,
    this.outgoingChatBubbleConfig,
    this.messageReactionConfig,
  });

  final Future<CustomMessageModel?> customMessageModel;
  final Message message;
  final bool isMessageBySender;
  final ChatBubble? inComingChatBubbleConfig;
  final ChatBubble? outgoingChatBubbleConfig;
  final MessageReactionConfiguration? messageReactionConfig;

  @override
  State<CustomMessageView> createState() => _CustomMessageViewState();
}

class _CustomMessageViewState extends State<CustomMessageView> {
  CustomMessageModel? _customMessageData;
  @override
  void initState() {
    super.initState();
    _loadCustomMessageData();
  }

  Future<void> _loadCustomMessageData() async {
    try {
      final data = await widget.customMessageModel;
      setState(() {
        _customMessageData = data;
      });
    } catch (error) {
      setState(() {
        _customMessageData = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_customMessageData == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: _customMessageData!.onTap,
            child: Container(
              height: 320,
              width: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
                color: _color,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 200,
                    width: 200,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16.0),
                        topRight: Radius.circular(16.0),
                      ),
                      child: CachedNetworkImage(
                        alignment: Alignment.topCenter,
                        imageUrl: _customMessageData!.imageUrl ?? '',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _customMessageData!.title,
                          style: _customMessageData!.titleTextStyle,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _customMessageData!.price.priceFormat(),
                          style: _customMessageData!.titleTextStyle,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (widget.message.reaction.reactions.isNotEmpty)
          ReactionWidget(
            isMessageBySender: widget.isMessageBySender,
            reaction: widget.message.reaction,
            messageReactionConfig: widget.messageReactionConfig,
          ),
        Positioned(
          right: 16,
          bottom: 16,
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: ReadIndicator(
              padding: const EdgeInsets.all(3),
              message: widget.message,
              textStyle: _textStyle,
              isMessageBySender: widget.isMessageBySender,
              indicatorColor:
                  widget.outgoingChatBubbleConfig?.readIndicatorColor,
              filledIndicatorColor:
                  widget.outgoingChatBubbleConfig?.filledReadIndicatorColor,
            ),
          ),
        ),
      ],
    );
  }

  TextStyle? get _textStyle => widget.isMessageBySender
      ? widget.outgoingChatBubbleConfig?.textStyle
      : widget.inComingChatBubbleConfig?.textStyle;

  Color get _color => widget.isMessageBySender
      ? widget.outgoingChatBubbleConfig?.color ?? Colors.purple
      : widget.inComingChatBubbleConfig?.color ?? Colors.grey.shade500;
}
