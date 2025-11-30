import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LanguageSettingsPage extends StatefulWidget {
  const LanguageSettingsPage({Key? key}) : super(key: key);

  @override
  State<LanguageSettingsPage> createState() => _LanguageSettingsPageState();
}

class _LanguageSettingsPageState extends State<LanguageSettingsPage> {
  String? selectedLang;

  // LibreTranslate supported languages (ISO codes + names)
  final Map<String, String> languages = {
    "en": "English",
    "ar": "Arabic",
    "zh": "Chinese",
    "fr": "French",
    "de": "German",
    "hi": "Hindi",
    "it": "Italian",
    "ja": "Japanese",
    "ko": "Korean",
    "pt": "Portuguese",
    "ru": "Russian",
    "es": "Spanish",
    "tr": "Turkish",
    "uk": "Ukrainian",
    "pl": "Polish",
    "ro": "Romanian",
    "bg": "Bulgarian",
    "cs": "Czech",
    "el": "Greek",
    "fa": "Persian",
    "id": "Indonesian",
    "ms": "Malay",
    "nl": "Dutch",
    "sv": "Swedish",
    "tl": "Tagalog",
    "vi": "Vietnamese"
  };

  Future<void> savePreferredLanguage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || selectedLang == null) return;

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'preferredLang': selectedLang,
    }, SetOptions(merge: true));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Preferred language set to ${languages[selectedLang]!}")),
    );

    Navigator.pop(context); // go back to HomePage
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Preferred Language")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: selectedLang,
              hint: const Text("Select your language"),
              items: languages.entries.map((entry) {
                return DropdownMenuItem<String>(
                  value: entry.key,
                  child: Text(entry.value),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  selectedLang = val;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: savePreferredLanguage,
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}