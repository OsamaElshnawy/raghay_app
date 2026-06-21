import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:raghay_app/constants.dart';
import 'package:raghay_app/pages/chat_page.dart';
import 'package:raghay_app/pages/login_page.dart';
import 'package:raghay_app/widgets/show_snack_bar.dart';

class ChatsHubPage extends StatefulWidget {
  const ChatsHubPage({super.key});
  static String id = 'ChatsHubPage';

  @override
  State<ChatsHubPage> createState() => _ChatsHubPageState();
}

class _ChatsHubPageState extends State<ChatsHubPage> {
  final TextEditingController _searchEmailController = TextEditingController();
  String myName = '';
  bool _hasFetchedName = false;

  // 🎯 Cache لضمان استقرار الأسماء ومنع الفليكرينج (Flickering)
  final Map<String, String> _cachedUsernames = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hasFetchedName) return;

    final String myEmail = ModalRoute.of(context)!.settings.arguments as String;
    final User? currentUser = FirebaseAuth.instance.currentUser;
    myName = currentUser?.displayName ?? myEmail.split('@')[0];

    _fetchMyUsername(myEmail);
  }

  Future<void> _fetchMyUsername(String email) async {
    try {
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(email.toLowerCase())
          .get();

      if (userDoc.exists && mounted) {
        setState(() {
          myName = userDoc.data()?['username'] ?? email.split('@')[0];
          _hasFetchedName = true;
          _cachedUsernames[email.toLowerCase()] = myName;
        });
      }
    } catch (e) {
      debugPrint("Error fetching my username: $e");
    }
  }

  void _showSearchDialog(BuildContext context, String myEmail) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Start New Chat'),
          content: TextField(
            controller: _searchEmailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: "Enter user's exact email...",
              prefixIcon: Icon(Icons.email),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _searchEmailController.clear();
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
              onPressed: () async {
                String targetEmail = _searchEmailController.text
                    .trim()
                    .toLowerCase();

                if (targetEmail.isEmpty) return;
                if (targetEmail == myEmail.toLowerCase()) {
                  showSnackBar(context, "You can't chat with yourself!");
                  return;
                }

                var userDoc = await FirebaseFirestore.instance
                    .collection('users')
                    .doc(targetEmail)
                    .get();

                if (userDoc.exists) {
                  final userData = userDoc.data() as Map<String, dynamic>;
                  final String username =
                      userData['username'] ?? 'Unknown User';

                  _cachedUsernames[targetEmail] = username;
                  _searchEmailController.clear();

                  if (!context.mounted) return;
                  Navigator.pop(context);

                  String senderNameParam = myName.isEmpty
                      ? myEmail.split('@')[0]
                      : myName;

                  Navigator.pushNamed(
                    context,
                    ChatPage.id,
                    arguments: {
                      'myEmail': myEmail,
                      'receiverEmail': targetEmail,
                      'receiverName': username,
                      'myName': senderNameParam,
                    },
                  );
                } else {
                  if (!context.mounted) return;
                  showSnackBar(
                    context,
                    'User not found! Make sure the email is correct.',
                  );
                }
              },
              child: const Text('Chat', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _searchEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String myEmail = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        automaticallyImplyLeading: false,
        title: const Text(
          'Raghay',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              try {
                await FirebaseAuth.instance.signOut();
                if (!context.mounted) return;
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  LoginPage.id,
                  (route) => false,
                );
              } catch (e) {
                showSnackBar(context, 'Error signing out: ${e.toString()}');
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kPrimaryColor,
        onPressed: () => _showSearchDialog(context, myEmail),
        child: const Icon(Icons.chat, color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection(kMessagesCollection)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: kPrimaryColor),
            );
          }

          if (snapshot.hasData) {
            Set<String> uniqueChatRooms = {};
            List<Map<String, dynamic>> activeChats = [];

            for (var doc in snapshot.data!.docs) {
              var data = doc.data() as Map<String, dynamic>;
              String? chatRoomId = data['chatRoomId'];

              if (chatRoomId != null &&
                  chatRoomId.contains(myEmail.toLowerCase())) {
                if (!uniqueChatRooms.contains(chatRoomId)) {
                  uniqueChatRooms.add(chatRoomId);

                  String receiverEmail = data['id'] == myEmail
                      ? (data['receiverId'] ?? '')
                      : (data['id'] ?? '');
                  String rawReceiverName = data['id'] == myEmail
                      ? (data['receiverName'] ?? '')
                      : (data['senderName'] ?? '');

                  // تحديث الكاش إذا وجدنا اسم صحيح
                  if (rawReceiverName.isNotEmpty &&
                      !rawReceiverName.contains('@')) {
                    _cachedUsernames[receiverEmail.toLowerCase()] =
                        rawReceiverName;
                  }

                  String finalReceiverName =
                      _cachedUsernames[receiverEmail.toLowerCase()] ??
                      (rawReceiverName.isNotEmpty
                          ? rawReceiverName
                          : receiverEmail.split('@')[0]);

                  activeChats.add({
                    'chatRoomId': chatRoomId,
                    'receiverEmail': receiverEmail,
                    'receiverName': finalReceiverName,
                    'lastMessage': data[kMessage] ?? '',
                  });
                }
              }
            }

            if (activeChats.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text(
                    'No active chats yet.\nClick the button to start! 🚀',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              );
            }

            return ListView.builder(
              itemCount: activeChats.length,
              itemBuilder: (context, index) {
                var chat = activeChats[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: kPrimaryColor,
                      child: Text(
                        chat['receiverName'][0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      chat['receiverName'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      chat['lastMessage'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey,
                    ),
                    onTap: () {
                      String senderNameParam = myName.isEmpty
                          ? myEmail.split('@')[0]
                          : myName;
                      Navigator.pushNamed(
                        context,
                        ChatPage.id,
                        arguments: {
                          'myEmail': myEmail,
                          'receiverEmail': chat['receiverEmail'],
                          'receiverName': chat['receiverName'],
                          'myName': senderNameParam,
                        },
                      );
                    },
                  ),
                );
              },
            );
          }
          return const Center(child: Text('Something went wrong'));
        },
      ),
    );
  }
}
