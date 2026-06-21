import 'package:flutter/material.dart';
import 'package:raghay_app/constants.dart';
import 'package:raghay_app/models/message_model.dart';

class ChatBubbleReceive extends StatelessWidget {
  const ChatBubbleReceive({super.key, required this.message});
  final MessageModel message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.all(16.0),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: const BoxDecoration(
          color: kPrimaryColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
            bottomRight: Radius.circular(32),
          ),
        ),
        child: IntrinsicWidth(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message.senderName,
                overflow: TextOverflow
                    .ellipsis, // ✅ إضافة القطع التلقائي للأسماء الطويلة
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.amber[200],
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                message.message,
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  message.time,
                  style: TextStyle(fontSize: 11, color: Colors.grey[300]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
