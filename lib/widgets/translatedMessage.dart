import 'package:flutter/material.dart';
import 'package:helloworld/services/translationServices.dart';

class TranslatableMessageBubble extends StatefulWidget {
  final String text;
  final bool isMe;
  final String preferredLang;      // target language for the viewer
  final String sourceLang;         // message's source language (from Firestore)
  final String? timestampString;

  const TranslatableMessageBubble({
    Key? key,
    required this.text,
    required this.isMe,
    required this.preferredLang,
    required this.sourceLang,
    this.timestampString,
  }) : super(key: key);

  @override
  State<TranslatableMessageBubble> createState() =>
      _TranslatableMessageBubbleState();
}

class _TranslatableMessageBubbleState extends State<TranslatableMessageBubble> {
  String? translated;

  @override
  void initState() {
    super.initState();
    _translate();
  }

  Future<void> _translate() async {
    try {
      final result = await TranslationService.translateText(
        widget.text,
        widget.sourceLang,
        widget.preferredLang,
      );
      if (!mounted) return;
      // Only set if different to avoid duplicate lines
      if (result != widget.text) {
        setState(() => translated = result);
      }
    } catch (_) {
      // Keep original if translation fails
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: widget.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: widget.isMe ? Colors.green[200] : Colors.blue[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Original text immediately
            Text(widget.text),
            // Translated text once ready
            if (translated != null) ...[
              const SizedBox(height: 6),
              Text(
                translated!,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black87,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            if (widget.timestampString != null) ...[
              const SizedBox(height: 4),
              Text(
                widget.timestampString!,
                style: const TextStyle(fontSize: 10, color: Colors.black54),
              ),
            ],
          ],
        ),
      ),
    );
  }
}