import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/diagnostic_provider.dart';

class GuideBottomSheet extends ConsumerWidget {
  const GuideBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(diagnosticProvider);

    final analysis = ref.watch(diagnosticProvider.notifier).analysisResult;
    final brix = analysis?['brix_estimate'] ?? "분석 중...";
    final diagnosis = analysis?['diagnosis'] ?? "생육 상태 분석 중입니다.";
    final firstStep = (analysis?['repair_steps'] as List?)?.first ?? {};
    final instruction = firstStep['instruction'] ?? "딸기를 카메라 정중앙에 위치시켜 주세요.";

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15), 
            blurRadius: 20, 
            spreadRadius: 5,
            offset: const Offset(0, 10),
          )
        ]
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Wrap content height
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  status == DiagnosticState.validating ? "품질 검증 진행 중..." : "AI 생육 분석 결과",
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.black87),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5))
                ),
                child: Text(brix, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 13)),
              )
            ],
          ),
          const SizedBox(height: 16),
          Text(
            diagnosis,
            style: const TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "추천 조치: $instruction",
            style: const TextStyle(fontSize: 14, color: Colors.black54, height: 1.5),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    analysis?['safety_alert'] ?? "특이사항 없음: 현재 정상 생육 범위 내에 있습니다.",
                    style: const TextStyle(color: Colors.green, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.wb_sunny_outlined, color: Colors.orange),
              ),
              const SizedBox(width: 12),
              const Text("상태: 최적 생육 온도", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 14)),
              const Spacer(),
              if (status == DiagnosticState.repairing)
                ElevatedButton.icon(
                  onPressed: () {
                    ref.read(diagnosticProvider.notifier).requestValidation();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    elevation: 5,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  label: const Text("생육 기록하기", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
            ],
          )
        ],
      ),
    );
  }
}
