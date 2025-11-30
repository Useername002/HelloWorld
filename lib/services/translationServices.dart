import 'dart:convert';
import 'package:http/http.dart' as http;

class TranslationService {
  static Future<String> translateText(
      String text,
      String sourceLang,
      String targetLang,
      ) async {
    // 1) Guard clauses
    if (text.trim().isEmpty) return text;
    if (sourceLang == targetLang) return text;

    // 2) Use autodetect if source seems invalid
    final normalizedSource =
    (sourceLang.isEmpty || sourceLang.length < 2) ? 'auto' : sourceLang;

    // 3) URL-encode the text
    final q = Uri.encodeQueryComponent(text);

    final url = Uri.parse(
      "https://api.mymemory.translated.net/get?q=$q&langpair=$normalizedSource|$targetLang",
    );

    try {
      final response = await http.get(url);

      if (response.statusCode != 200) {
        // Non-200: return original
        return text;
      }

      final data = jsonDecode(response.body);

      // Primary result
      String translated = (data["responseData"]?["translatedText"] as String?) ?? text;

      // 4) If the primary seems wrong, scan matches for the exact target
      final matches = (data["matches"] as List?) ?? const [];
      String? bestByTarget;
      double bestScore = -1.0;

      for (final m in matches) {
        final target = (m["target"] as String?) ?? '';
        final translation = (m["translation"] as String?) ?? '';
        final matchScore = (m["match"] is num) ? (m["match"] as num).toDouble() : 0.0;

        // Prefer entries whose target equals the requested language (or starts with it, e.g., hi-IN)
        final targetMatches = target == targetLang || target.startsWith("$targetLang-");
        if (targetMatches && matchScore > bestScore && translation.isNotEmpty) {
          bestScore = matchScore;
          bestByTarget = translation;
        }
      }

      if (bestByTarget != null) {
        translated = bestByTarget!;
      }

      // Basic sanity: if translation is identical to input and languages differ, keep original fallback
      // (Some entries echo input; you can choose to return translated anyway.)
      return translated.isNotEmpty ? translated : text;
    } catch (_) {
      // Network or parse error: fall back
      return text;
    }
  }
}