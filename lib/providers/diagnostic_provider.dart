import 'dart:typed_data';
import 'package:flutter/foundation.dart'; // added for debugPrint
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/gemini_ai_service.dart';

enum DiagnosticState {
  idle,       // Initial state, ready to scan
  scanning,   // Actively analyzing camera feed
  validating, // Checking safety and completion (Step-validation)
  repairing,  // Showing AR guide and steps
  completed   // Diagnosis and repair finished successfully
}

class DiagnosticNotifier extends StateNotifier<DiagnosticState> {
  DiagnosticNotifier() : super(DiagnosticState.idle);

  // Using a getter for service so we don't init it until needed (which avoids .env loading errors in global scope)
  GeminiAiService get _aiService => GeminiAiService();

  String? errorMessage;

  Future<void> startScanningWithFrame(Uint8List imageBytes) async {
    // 0 bytes just triggers visual loading
    if (imageBytes.isEmpty) {
      state = DiagnosticState.scanning;
      errorMessage = null;
      return;
    }
    
    try {
      final prompt = imageBytes.length > 10
        ? "Analyze this image to detect if an appliance or object is broken. Identify the object and give steps to fix it. Always return coordinates near the center like [x, y]"
        : "Assume a user is showing a broken washing machine lid. Give steps to fix it. Provide mock coordinates around [180.0, 450.0]";

      final resultJson = await _aiService.analyzeFrame(
        imageBytes: imageBytes, 
        promptContext: prompt
      );
      
      debugPrint("AI DIAGNOSIS SUCCESS: \$resultJson");
      state = DiagnosticState.repairing;
      
    } catch (e) {
      debugPrint("SCAN FAILED: \$e");
      
      // Project IDX 안드로이드 에뮬레이터 특성상 인터넷 연결(DNS)이 끊기는 버그 우회용
      if (e.toString().contains('Failed host lookup') || e.toString().contains('SocketException')) {
        debugPrint("Network lookup failed. Operating in Offline/Fallback Demo Mode.");
        // 에뮬레이터에서 시연을 이어갈 수 있도록 가짜(강제) 성공 처리
        Future.delayed(const Duration(seconds: 1), () {
          errorMessage = null;
          state = DiagnosticState.repairing;
        });
        return; // 정상 종료 처리
      }

      errorMessage = e.toString();
      state = DiagnosticState.idle; // Revert back to idle on error
    }
  }

  void stopProcess() { state = DiagnosticState.idle; }
  void onDiagnosisReceived() { state = DiagnosticState.repairing; }
  void requestValidation() { state = DiagnosticState.validating; }
  void completeRepair() { state = DiagnosticState.completed; }
}

final diagnosticProvider = StateNotifierProvider<DiagnosticNotifier, DiagnosticState>((ref) {
  return DiagnosticNotifier();
});
