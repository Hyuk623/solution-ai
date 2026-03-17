import 'dart:convert';
import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiAiService {
  late GenerativeModel _model;

  GeminiAiService() {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY is not defined in .env file.');
    }

    _model = GenerativeModel(
      model: 'gemini-1.5-flash-latest', 
      apiKey: apiKey,
    );
  }

  /// Sends the multimodal request combining image frame and (optional) audio chunk
  Future<Map<String, dynamic>> analyzeFrame({
    required Uint8List imageBytes,
    Uint8List? audioBytes,
    required String promptContext,
  }) async {
    try {
      final promptPart = TextPart('''
$promptContext

[INSTRUCTIONS]
You are Berry Analyst. Analyze the image to detect the growth status of strawberries.
Check for: ripeness (unripe, turning, ripe, overripe), diseases/pests, sugar content estimation (Brix), and size.
You MUST provide the response in valid JSON exactly matching this format:
{
  "status": "success/error",
  "diagnosis": "Detailed state assessment (Growth stage, Health)",
  "confidence": 0.95,
  "brix_estimate": "Estimated sugar content (e.g. 10-12 Brix)",
  "repair_steps": [{"step": 1, "instruction": "Care action (e.g. Needs more water, Ready for harvest)", "target_coords": [150.0, 300.0]}],
  "safety_alert": "Pests detected or nutrition deficiency"
}
''');
      
      final parts = <Part>[];
      if (imageBytes.length > 10) {
        parts.add(DataPart('image/jpeg', imageBytes));
      }
      parts.add(promptPart);
      
      // Combine 16kHz mono audio if available
      if (audioBytes != null) {
        final audioPart = DataPart('audio/wav', audioBytes);
        parts.add(audioPart);
      }

      final content = [Content.multi(parts)];
      
      final response = await _model.generateContent(content);
      
      if (response.text != null) {
        // Find JSON block if Gemini adds markdown formatting
        String rawText = response.text!;
        if (rawText.contains('```json')) {
          rawText = rawText.split('```json')[1].split('```')[0];
        }
        return jsonDecode(rawText);
      } else {
        throw Exception("Empty response from AI");
      }
    } catch (e) {
      // Re-throw to be handled by NetworkRetry (Exponential Backoff)
      rethrow;
    }
  }
}
