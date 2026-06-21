import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raghay_app/constants.dart';

class MessageModel {
  final String message;
  final String time;
  final String sender; // الـ id (بريد الراسل)
  final String receiverId; // بريد المستقبل
  final String chatRoomId; // معرف الغرفة المشتركة
  final String senderName; // 🎯 حقل اسم الراسل
  final String receiverName; // 🎯 حقل اسم المستقبل الجديد لضمان تكامل البيانات

  MessageModel({
    required this.message,
    required this.time,
    required this.sender,
    required this.receiverId,
    required this.chatRoomId,
    required this.senderName,
    required this.receiverName,
  });

  // 1. الدالة المحدثة لاستقبل البيانات من الفايربيز 📥
  factory MessageModel.fromJson(Map<String, dynamic> jsonData) {
    final Timestamp? timestamp = jsonData[kTime] as Timestamp?;

    String formattedTime = '..:..';
    if (timestamp != null) {
      final DateTime dateTime = timestamp.toDate();

      // تحويل الساعة لنظام 12 ساعة مع تحديد AM أو PM
      final int hour = dateTime.hour > 12
          ? dateTime.hour - 12
          : (dateTime.hour == 0 ? 12 : dateTime.hour);
      final String period = dateTime.hour >= 12 ? 'PM' : 'AM';
      final String minute = dateTime.minute.toString().padLeft(2, '0');

      formattedTime = "$hour:$minute $period"; // تظهر مثل: 2:05 PM
    }

    // تأمين جلب الأسماء بشكل احتياطي (Fallback) من الإيميل لو الرسالة قديمة
    final String fallbackSender = jsonData['id'] ?? 'Unknown';
    final String fallbackReceiver = jsonData['receiverId'] ?? 'Unknown';

    return MessageModel(
      message: jsonData[kMessage] ?? '',
      time: formattedTime,
      sender: fallbackSender,
      receiverId: fallbackReceiver,
      chatRoomId: jsonData['chatRoomId'] ?? '',
      senderName: jsonData['senderName'] ?? fallbackSender.split('@')[0],
      receiverName: jsonData['receiverName'] ?? fallbackReceiver.split('@')[0],
    );
  }

  // 2. دالة تحويل البيانات لإرسالها للفايربيز 📤
  Map<String, dynamic> toMap() {
    return {
      kMessage: message,
      kTime:
          FieldValue.serverTimestamp(), // متاح تركها هنا لو كنت تعتمد عليها مباشرة عند الإرسال من الـ Model
      'id': sender,
      'receiverId': receiverId,
      'chatRoomId': chatRoomId,
      'senderName': senderName,
      'receiverName': receiverName,
    };
  }
}
