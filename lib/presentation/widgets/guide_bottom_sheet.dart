import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/diagnostic_provider.dart';

class GuideBottomSheet extends ConsumerWidget {
  const GuideBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(diagnosticProvider);

    if (status == DiagnosticState.idle || status == DiagnosticState.scanning) {
      return const SizedBox.shrink(); // Hide if not in repair/validation
    }

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
              Text(
                status == DiagnosticState.validating ? "안전 검증 진행 중..." : "1. 하단 나사 제거",
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.black87),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.5))
                ),
                child: const Text("전체 4단계 중 1단계", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 12)),
              )
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            "지정된 노란색 표시 영역의 나사를 십자 드라이버를 사용하여 제거해 주세요.",
            style: TextStyle(fontSize: 15, color: Colors.black87, height: 1.5),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.5)),
            ),
            child: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "주의: 반드시 기기의 전원 플러그가 분리되었는지 확인하세요.",
                    style: TextStyle(color: Colors.deepOrange, fontSize: 13, fontWeight: FontWeight.w600),
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
                child: const Icon(Icons.build_circle, color: Colors.black54),
              ),
              const SizedBox(width: 12),
              const Text("필요 자재: 십자 드라이버", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 14)),
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
                  icon: const Icon(Icons.camera_alt, size: 18),
                  label: const Text("작업 확인하기", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              if (status == DiagnosticState.validating)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(color: Colors.black, strokeWidth: 3),
                ),
            ],
          )
        ],
      ),
    );
  }
}
