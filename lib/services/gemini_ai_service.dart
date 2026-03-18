import 'dart:convert';
import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiAiService {
  late final GenerativeModel _model;

  GeminiAiService() {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY is not defined in .env file.');
    }
    _model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: apiKey,
    );
  }

  Future<Map<String, dynamic>> analyzeStrawberry({
    required Uint8List imageBytes,
  }) async {
    const prompt = '''
You are an expert strawberry analyst. Analyze this image and evaluate the strawberries.
Return ONLY valid JSON with no markdown, in exactly this format:
{
  "status": "success",
  "diagnosis": "Brief assessment of growth stage and health",
  "ripeness": "Green/Turning/Ripe/Overripe",
  "brix_estimate": "Estimated Brix value (e.g. 10-12 Brix)",
  "confidence": 0.90,
  "care_instruction": "Main recommended action",
  "alert": "Any detected disease or pest, or null if none"
}
''';

    final parts = <Part>[];
    if (imageBytes.length > 10) {
      parts.add(DataPart('image/jpeg', imageBytes));
    }
    parts.add(TextPart(prompt));

    final response = await _model.generateContent([Content.multi(parts)]);

    if (response.text == null) {
      throw Exception('Empty response from Gemini');
    }

    String rawText = response.text!.trim();
    if (rawText.contains('```json')) {
      rawText = rawText.split('```json')[1].split('```')[0].trim();
    } else if (rawText.contains('```')) {
      rawText = rawText.split('```')[1].split('```')[0].trim();
    }

    return jsonDecode(rawText) as Map<String, dynamic>;
  }
}
