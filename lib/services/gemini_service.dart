import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/shift_model.dart';

class GeminiService {
  // TODO: API Key should be secured, but for this demo we might need to ask user or use a placeholder
  // For now I will use a placeholder and ask user to provide it or I will look if I have one in env.
  // Since I cannot access env vars easily without user input, I will add a constructor or setter.
  // But for simplicity in this step, I'll assume a constant or pass it.
  // I will use a placeholder 'YOUR_API_KEY' and let the user know.
  final String apiKey;
  final String modelName;

  GeminiService(this.apiKey, {this.modelName = 'gemini-2.5-flash'});

  GenerativeModel get _model => GenerativeModel(
        model: modelName,
        apiKey: apiKey,
      );

  Future<List<ShiftModel>> analyzeImage(Uint8List imageBytes, String userName) async {
    final prompt = _buildPrompt(userName);
    final content = [
      Content.multi([
        TextPart(prompt),
        DataPart('image/png', imageBytes),
      ])
    ];

    return _sendRequest(content);
  }

  Future<List<ShiftModel>> analyzeText(String textData, String userName) async {
    final prompt = _buildPrompt(userName);
    final content = [
      Content.text('$prompt\n\nVERİ:\n$textData')
    ];

    return _sendRequest(content);
  }

  String _buildPrompt(String userName) {
    final now = DateTime.now();
    return "Bu veride $userName kişisini bul. Ayın günlerine göre vardiyaları çıkar. "
        "Şu anki tarih: ${now.year}-${now.month}. "
        "Eğer verideki tarihler geçmiş bir yıla veya aya aitse veya yıl/ay belirtilmemişse, "
        "tarihleri BU YIL (${now.year}) ve BU AY (${now.month}) olacak şekilde güncelle. "
        "Günü koru ama ay ve yılı şimdiki zamana uyarla. "
        "Yanıtı SADECE şu JSON formatında ver, başka hiçbir metin ekleme: "
        "[{'date': 'YYYY-MM-DD', 'shift': '08:00-16:00'}]";
  }

  Future<List<ShiftModel>> _sendRequest(List<Content> content) async {
    try {
      final response = await _model.generateContent(content);
      final responseText = response.text;

      debugPrint('Gemini Ham Yanıt: $responseText');

      if (responseText == null) return [];

      // Clean up markdown code blocks if present
      final cleanText = responseText.replaceAll('```json', '').replaceAll('```', '').trim();
      
      List<dynamic> jsonList;
      try {
        jsonList = jsonDecode(cleanText);
      } catch (e) {
        debugPrint('JSON Parse Hatası (İlk deneme): $e');
        // Try replacing single quotes with double quotes for keys and values
        final fixedText = cleanText.replaceAll("'", '"');
        try {
          jsonList = jsonDecode(fixedText);
        } catch (e2) {
           debugPrint('JSON Parse Hatası (İkinci deneme): $e2');
           debugPrint('Parse edilemeyen metin: $cleanText');
           return [];
        }
      }

      return jsonList.map((e) => ShiftModel.fromJson(e)).toList();
    } catch (e) {
      debugPrint('Gemini Genel Hatası: $e');
      return [];
    }
  }
}
