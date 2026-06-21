# 📱 Raghay App (تطبيق رغّاي)

تطبيق محادثة فورية متكامل مبني باستخدام **Flutter** و **Dart**، ومربوط بمنصة **Firebase** لإدارة المستخدمين والمحادثات بشكل آمن ولحظي.

---

## ✨ المميزات الرئيسية

- **توثيق مستخدمين آمن (Authentication):** تسجيل دخول وإنشاء حساب عبر `Firebase Auth` مع إلزام المستخدم بالتحقق من بريده الإلكتروني عبر شاشة مخصصة (`VerifyEmailPage`).
- **هيكل محادثات متقدم (Chats Hub):** دعم نظام الغرف المتعددة والمحادثات الثنائية (1-on-1) بناءً على معرف فريد لكل غرفة (`chatRoomId`).
- **محادثة فورية ولحظية (Real-time Messaging):** مزامنة لحظية للرسائل باستخدام `Cloud Firestore Snapshots` مع ترتيبها تلقائياً حسب وقت الإرسال (`createdAt`).
- **واجهة مستخدم متجاوبة واحترافية (Responsive UI/UX):**
  - فقاعات محادثة ديناميكية للمرسل والمستلم تمنع تشوه التصميم عند وجود أسماء طويلة (`TextOverflow.ellipsis`).
  - حقول إدخال وأزرار مخصصة متجاوبة بالكامل مع مختلف أبعاد الشاشات.
  - نظام تنبيهات مرن يمنع تراكم الرسائل وتداخلها عند الضغط المتكرر.

---

## 🛠 التقنيات المستخدمة

- **Framework:** Flutter
- **Language:** Dart
- **Backend & Database:** Cloud Firestore & Firebase Auth

---

## 📂 هيكل المشروع

```text
lib/
│
├── models/
│   └── message_model.dart       # نموذج بيانات الرسالة
│
├── widgets/
│   ├── chat_bubble_receive.dart # فقاعة المستلم
│   ├── chat_bubble_send.dart    # فقاعة المرسل
│   ├── custom_button.dart       # زر مخصص متجاوب
│   └── custom_text_form_field.dart # حقل إدخال مخصص
│
├── pages/
│   ├── login_page.dart          # شاشة تسجيل الدخول
│   ├── register_page.dart       # شاشة إنشاء الحساب
│   ├── verify_email_page.dart   # شاشة التحقق من الإيميل
│   ├── chats_hub_page.dart      # شاشة مركز المحادثات
│   └── chat_page.dart           # شاشة غرف الدردشة
│
├── constants.dart               # الثوابت الموحدة (الألوان والأسمّاء)
├── firebase_options.dart        # إعدادات الفايربيز
└── main.dart                    # نقطة الانطلاق وإدارة المسارات

🚀 تشغيل المشروع محلياً
# 1. عمل Clone للمشروع
git clone [https://github.com/your-username/raghay_app.git](https://github.com/your-username/raghay_app.git)
cd raghay_app

# 2. تحميل الاعتمادات وحزم الـ Pub
flutter pub get

# 3. تشغيل التطبيق
flutter run

📄 الترخيص (License)
MIT License

```
