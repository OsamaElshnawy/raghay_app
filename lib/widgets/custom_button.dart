import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.title,
    required this.onPressed, // 🎯 التعديل: كتابة الاسم بـ Camel Case
  });

  final String title;
  final VoidCallback? onPressed; 

  @override
  Widget build(BuildContext context) {
    // جلب أبعاد الشاشة الحالية للجهاز
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      height: screenHeight * 0.08 < 45 ? 45 : screenHeight * 0.08,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: const Color(0xff274460),
            fontSize: screenWidth * 0.035, 
          ),
        ),
      ),
    );
  }
}