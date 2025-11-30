import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:helloworld/LoginUI.dart';
import 'package:helloworld/Database/Remote/firebase_auth.dart';
import 'package:helloworld/messageUI.dart'; // ChatScreen
import 'package:helloworld/services/translationServices.dart';
import 'package:helloworld/settingsPage.dart';

class HomePage extends StatefulWidget {
  final String userName;
  final String phoneNumber;
  final String profileUrl;

  const HomePage({
    Key? key,
    this.userName = "Guest",
    this.phoneNumber = "Not available",
    this.profileUrl = "",
  }) : super(key: key);

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "HelloWorld",
          style: TextStyle(color: Colors.black, fontSize: 25),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue[300]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: widget.profileUrl.trim().isNotEmpty
                        ? NetworkImage(widget.profileUrl)
                        : const AssetImage('assets/images/default_avatar.jpeg')
                    as ImageProvider,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    widget.userName,
                    style: const TextStyle(color: Colors.black, fontSize: 15),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.phoneNumber,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("Home"),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Settings"),
              onTap: (){
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder:(_)=>LanguageSettingsPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Log out"),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    backgroundColor: Colors.purple[50],
                    title: const Text("Log out"),
                    content: const Text("Are you sure you want to log out?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          await RemoteDb.instance.logoutUser();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Logged out successfully"),
                            ),
                          );
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => LoginUI()),
                                (route) => false,
                          );
                        },
                        child: const Text("Log out"),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('participants', arrayContains: currentUser.uid)
        // remove orderBy for now to avoid index error
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Error loading chats"));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final chats = snapshot.data!.docs;

          if (chats.isEmpty) {
            return const Center(child: Text("No chats yet"));
          }

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index].data() as Map<String, dynamic>;

              final participants = List<String>.from(chat['participants']);
              final participantEmails =
              List<String>.from(chat['participantEmails']);

              final otherIndex =
              participants.indexWhere((id) => id != currentUser.uid);
              final otherUid =
              otherIndex != -1 ? participants[otherIndex] : "Unknown";
              final otherEmail =
              otherIndex != -1 ? participantEmails[otherIndex] : "Unknown";

              return ListTile(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatScreen(
                      receiverUid: otherUid,
                      receiverEmail: otherEmail,
                    ),
                  ),
                ),
                title: Text(otherEmail),
                subtitle: Text(chat['lastMessage'] ?? "",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                ),
                trailing: Text(
                  chat['lastTimestamp'] != null
                      ? (chat['lastTimestamp'] as Timestamp)
                      .toDate()
                      .toLocal()
                      .toString()
                      : "",
                  style: const TextStyle(fontSize: 12),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.chat),
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) {
              final emailController = TextEditingController();
              return AlertDialog(
                title: const Text("Start new chat"),
                content: TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    hintText: "Enter receiver's email",
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () async {
                      final receiverEmail = emailController.text.trim();
                      if (receiverEmail.isEmpty) return;

                      final userDoc = await FirebaseFirestore.instance
                          .collection('users')
                          .where('email', isEqualTo: receiverEmail)
                          .limit(1)
                          .get();

                      if (userDoc.docs.isNotEmpty) {
                        final receiverUid = userDoc.docs.first.id;

                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatScreen(
                              receiverUid: receiverUid,
                              receiverEmail: receiverEmail,
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("User not found"),
                          ),
                        );
                      }
                    },
                    child: const Text("Start"),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}