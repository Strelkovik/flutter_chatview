import 'package:chatview/chatview.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReadIndicator extends StatelessWidget {
  const ReadIndicator({
    super.key,
    required this.message,
    required this.isMessageBySender,
    this.textStyle,
  });

  final Message message;
  final bool isMessageBySender;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: message.messageType == MessageType.image
            ? Colors.black.withOpacity(0.6)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Row(
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
                      ? Colors.greenAccent
                      : Colors.white,
                  size: 15,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
