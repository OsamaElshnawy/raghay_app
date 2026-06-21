import 'package:flutter/material.dart';

// اللون الأساسي للأبلكيشن
const kPrimaryColor = Color(0xff274460);

// اسم الـ Collection الأساسية في الفاير ستور
const kMessagesCollection = 'messages';

// 🎯 اسم الحقل (Field) الخاص بنص الرسالة داخل الفاير ستور لتجنب التضارب
const kMessage = 'message';

// اسم حقل الوقت لترتيب الرسائل
const kTime = 'createdAt';

// 🎯 معرف مرسل الرسالة (الـ Email أو الـ UID)
const kId = 'id';

// 🎯 اسم الحقل الخاص باسم المستخدم المرسل لعرضه في الفقاعة
const kSenderName = 'senderName';

// 🎯 الثابت الجديد: اسم الحقل الخاص برقم الغرفة (لفصل المحادثات)
const kChatRoomId = 'chatRoomId';
