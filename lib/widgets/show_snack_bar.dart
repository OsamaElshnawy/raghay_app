import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, String message) {
  // تصفية أي سناك بار قديم فوراً لتجنب التراكم والبطء
  ScaffoldMessenger.of(context).removeCurrentSnackBar();

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
      backgroundColor: const Color(0xff274460), // متناسق مع لون التطبيق الأساسي
      behavior: SnackBarBehavior.floating, // طافٍ فوق عناصر الواجهة
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8), // حواف دائرية متناسقة
      ),
      duration: const Duration(seconds: 2), // مدة عرض مناسبة وخفيفة
    ),
  );
}
