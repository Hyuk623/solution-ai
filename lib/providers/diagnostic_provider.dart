import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/gemini_ai_service.dart';

enum AnalysisState { idle, loading, done, error }

class AnalysisResult {
  final String diagnosis;
  final String ripeness;
  final String brixEstimate;
  final double confidence;
  final String careInstruction;
  final String? alert;

  AnalysisResult({
    required this.diagnosis,
    required this.ripeness,
    required this.brixEstimate,
    required this.confidence,
    required this.careInstruction,
    this.alert,
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    return AnalysisResult(
      diagnosis: json['diagnosis'] as String? ?? '-',
      ripeness: json['ripeness'] as String? ?? '-',
      brixEstimate: json['brix_estimate'] as String? ?? '-',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      careInstruction: json['care_instruction'] as String? ?? '-',
      alert: json['alert'] as String?,
    );
  }
}

class DiagnosticNotifier extends StateNotifier<AnalysisState> {
  DiagnosticNotifier() : super(AnalysisState.idle);

  AnalysisResult? result;
  String? errorMessage;

  Future<void> analyze(Uint8List imageBytes) async {
    state = AnalysisState.loading;
    errorMessage = null;
    result = null;

    try {
      final service = GeminiAiService();
      final json = await service.analyzeStrawberry(imageBytes: imageBytes);
      result = AnalysisResult.fromJson(json);
      state = AnalysisState.done;
    } catch (e) {
      debugPrint('Analysis error: $e');
      errorMessage = e.toString();
      state = AnalysisState.error;
    }
  }

  void reset() {
    result = null;
    errorMessage = null;
    state = AnalysisState.idle;
  }
}

final diagnosticProvider =
    StateNotifierProvider<DiagnosticNotifier, AnalysisState>(
  (ref) => DiagnosticNotifier(),
);
