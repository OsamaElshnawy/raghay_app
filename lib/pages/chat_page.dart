import 'package:flutter/material.dart';
import 'package:raghay_app/constants.dart';
import 'package:raghay_app/models/message_model.dart';
import 'package:raghay_app/widgets/chat_bubble_receive.dart';
import 'package:raghay_app/widgets/chat_bubble_send.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});
  static String id = 'ChatPage';

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController messageController = TextEditingController();
  final ScrollController _controller = ScrollController();
  
  final CollectionReference messages = FirebaseFirestore.instance.collection(kMessagesCollection);

  @override
  void dispose() {
    messageController.dispose(); // ✅ التعديل الأهم لمنع تسريب الذاكرة
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage({
    required String value,
    required String myEmail,
    required String receiverEmail,
    required String senderName,
    required String receiverName,
  }) {
    if (value.trim().isEmpty) return;

    messages.add({
      kMessage: value,
      kTime: FieldValue.serverTimestamp(),
      kId: myEmail,
      'receiverId': receiverEmail,
      'chatRoomId': _getChatRoomId(myEmail, receiverEmail),
      'senderName': senderName,
      'receiverName': receiverName,
    });

    messageController.clear();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_controller.hasClients) {
        _controller.animateTo(
          _controller.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _getChatRoomId(String email1, String email2) {
    List<String> emails = [email1.toLowerCase(), email2.toLowerCase()];
    emails.sort();
    return "${emails[0]}_${emails[1]}";
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String myEmail = args['myEmail'] ?? '';
    final String receiverEmail = args['receiverEmail'] ?? '';
    final String receiverName = args['receiverName'] ?? '';
    final String myName = args['myName'] ?? myEmail.split('@')[0];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        backgroundColor: kPrimaryColor,
        title: Text(receiverName, style: const TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: messages
            .where('chatRoomId', isEqualTo: _getChatRoomId(myEmail, receiverEmail))
            .orderBy(kTime, descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text('Error loading messages.'));
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: kPrimaryColor));
          }

          List<MessageModel> messagesList = [];
          if (snapshot.hasData) {
            for (var doc in snapshot.data!.docs) {
              var data = doc.data() as Map<String, dynamic>;
              if (data[kTime] != null) messagesList.add(MessageModel.fromJson(data));
            }
          }

          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Expanded(
                  child: messagesList.isEmpty
                      ? const Center(child: Text('Say Hello! 👋', style: TextStyle(color: Colors.grey)))
                      : ListView.builder(
                          controller: _controller,
                          itemCount: messagesList.length,
                          itemBuilder: (context, index) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: myEmail == messagesList[index].sender
                                ? ChatBubbleSend(message: messagesList[index])
                                : ChatBubbleReceive(message: messagesList[index]),
                          ),
                        ),
                ),
                TextField(
                  controller: messageController,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (val) => _sendMessage(value: val, myEmail: myEmail, receiverEmail: receiverEmail, senderName: myName, receiverName: receiverName),
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.send, color: kPrimaryColor),
                      onPressed: () => _sendMessage(value: messageController.text, myEmail: myEmail, receiverEmail: receiverEmail, senderName: myName, receiverName: receiverName),
                    ),
                    enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: kPrimaryColor)),
                    focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide(color: kPrimaryColor)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}