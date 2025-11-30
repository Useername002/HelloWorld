import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:helloworld/widgets/translatedMessage.dart';

class ChatScreen extends StatefulWidget {
  final String receiverUid;
  final String receiverEmail;

  const ChatScreen({
    Key? key,
    required this.receiverUid,
    required this.receiverEmail,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  String? _preferredLang; // viewer's target language (current user)

  String getChatId(String myUid, String otherUid) {
    return myUid.hashCode <= otherUid.hashCode
        ? "${myUid}_$otherUid"
        : "${otherUid}_$myUid";
  }

  @override
  void initState() {
    super.initState();
    _loadPreferredLanguage();
  }

  Future<void> _loadPreferredLanguage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    setState(() {
      _preferredLang = (doc.data() ?? {})['preferredLang'] ?? 'en';
    });
  }

  Future<void> sendMessage(String chatId, String content) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || content.trim().isEmpty) return;

    // Get sender’s preferred language from Firestore
    final senderDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final senderLang = (senderDoc.data() ?? {})['preferredLang'] ?? 'en';

    // Add the message with lang included
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
      'senderId': user.uid,
      'senderEmail': user.email,
      'content': content.trim(),
      'lang': senderLang,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Update parent chat doc for preview
    await FirebaseFirestore.instance.collection('chats').doc(chatId).set({
      'participants': [user.uid, widget.receiverUid],
      'participantEmails': [user.email, widget.receiverEmail],
      'lastMessage': content.trim(),
      'lastTimestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    _controller.clear();
  }

  Stream<QuerySnapshot> getMessages(String chatId) {
    return FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    final chatId = getChatId(user.uid, widget.receiverUid);
    final viewerLang = _preferredLang ?? 'en';

    return Scaffold(
      appBar: AppBar(title: Text(widget.receiverEmail)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: getMessages(chatId),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final docs = snapshot.data!.docs;
        
                  return ListView.builder(
                    reverse: true,
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final msg = docs[index].data() as Map<String, dynamic>;
                      final isMe = msg['senderId'] == user.uid;
                      final ts = msg['timestamp'] as Timestamp?;
                      final tsString =
                      ts != null ? ts.toDate().toLocal().toString() : null;
        
                      final sourceLang =
                      (msg['lang'] as String?)?.trim().isNotEmpty == true
                          ? msg['lang'] as String
                          : 'en';
        
                      return TranslatableMessageBubble(
                        text: msg['content'] ?? '',
                        isMe: isMe,
                        preferredLang: viewerLang,    // translate to viewer’s language
                        sourceLang: sourceLang,       // translate from sender’s language
                        timestampString: tsString,
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: "Type a message...",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () => sendMessage(chatId, _controller.text),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}