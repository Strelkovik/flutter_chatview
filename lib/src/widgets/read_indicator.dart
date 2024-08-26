import 'package:chatview/chatview.dart';
import 'package:chatview/src/extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReadIndicator extends StatelessWidget {
  const ReadIndicator({
    super.key,
    required this.message,
    required this.isMessageBySender,
    this.padding = const EdgeInsets.all(0),
    this.textStyle,
    this.indicatorColor,
    this.filledIndicatorColor,
  });

  final Message message;
  final bool isMessageBySender;
  final TextStyle? textStyle;
  final Color? indicatorColor;
  final Color? filledIndicatorColor;

  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: message.messageType == MessageType.image ||
                message.message.isAllEmoji
            ? Colors.black.withOpacity(0.6)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Padding(
        padding: padding,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              DateFormat.Hm().format(message.createdAt),
              style: textStyle?.copyWith(fontSize: 10) ??
                  const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                  ),
            ),
            if (isMessageBySender)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Icon(
                  message.status == MessageStatus.read ||
                          message.status == MessageStatus.delivered
                      ? Icons.done_all
                      : Icons.done,
                  color: message.status == MessageStatus.read
                      ? filledIndicatorColor ?? Colors.greenAccent
                      : indicatorColor ?? Colors.white,
                  size: 15,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
