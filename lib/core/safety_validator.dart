// User Safety and Action Verification Logic

class SafetyValidator {
  
  /// Checks the AI parsed JSON to ensure safe progression
  static bool validateAiResponse(Map<String, dynamic> aiResponse) {
    // 1. Hazard Detection (Sparks, burn smell, water leaks)
    final alert = aiResponse['safety_alert'] as String?;
    if (alert != null && alert.isNotEmpty && alert.toLowerCase() != 'null') {
      // Trigger full-screen hazard warning (to be handled by UI/Provider)
      throw HazardException("위험 감지: \$alert! 즉시 작업을 중단하고 대피하십시오.");
    }

    // 2. Safety Lock Check
    // E.g., The system needs 90% confidence that the plug is pulled.
    // In our mock, if instruction indicates 'disconnect', confidence must be >= 0.90
    final confidence = (aiResponse['confidence'] as num?)?.toDouble() ?? 0.0;
    final diagnosis = aiResponse['diagnosis'] as String? ?? "";
    
    if (diagnosis.contains("전원") || diagnosis.contains("플러그")) {
      if (confidence < 0.90) {
        throw SafetyLockException("안전 잠금: 전원 플러그가 분리된 상태를 명확히 인식할 수 없습니다. (\$confidence)");
      }
    }
    
    return true;
  }

  /// Step-Validation Loop
  /// AI verifies if the current step (e.g. screw removed) is actually complete
  static bool verifyActionCompleted(Map<String, dynamic> newFrameAnalysis, int stepNumber) {
    // If the new frame no longer detects the screw at the target coordinate, or AI confirms "Success"
    return newFrameAnalysis['status'] == 'success';
  }
}

class HazardException implements Exception {
  final String message;
  HazardException(this.message);
}

class SafetyLockException implements Exception {
  final String message;
  SafetyLockException(this.message);
}
