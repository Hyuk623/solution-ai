import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/diagnostic_provider.dart';
import '../widgets/guide_bottom_sheet.dart';
import '../widgets/ar_overlay_painter.dart';
import 'package:camera/camera.dart';

class DiagnosticScreen extends ConsumerStatefulWidget {
  const DiagnosticScreen({super.key});

  @override
  ConsumerState<DiagnosticScreen> createState() => _DiagnosticScreenState();
}

class _DiagnosticScreenState extends ConsumerState<DiagnosticScreen> {
  CameraController? _cameraController;
  
  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return; // Safely handle no cameras available
    
    _cameraController = CameraController(cameras.first, ResolutionPreset.medium);
    await _cameraController?.initialize();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(diagnosticProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true, 
      appBar: AppBar(
        // withOpacity 대신 최신 문법인 withValues 사용
        backgroundColor: Colors.black.withValues(alpha: 0.3),
        elevation: 0,
        title: const Text('Solution AI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        centerTitle: true,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_cameraController != null && _cameraController!.value.isInitialized) ...[
            CameraPreview(_cameraController!),
          ] else ...[
            Container(
              color: const Color(0xFF1E1E24), 
              child: const Center(child: CircularProgressIndicator(color: Colors.cyanAccent)),
            ),
          ],
          
          if (status == DiagnosticState.repairing || status == DiagnosticState.validating)
            Positioned.fill(
              child: CustomPaint(
                painter: ArOverlayPainter(
                  targetCoords: const Offset(180, 450),
                  isPulsing: true,
                ),
              ),
            ),
          
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: _buildTopStatusPill(status),
              ),
            ),
          ),
          
          if (status == DiagnosticState.scanning)
            Container(
              color: Colors.black.withValues(alpha: 0.7),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 100,
                          height: 100,
                          child: CircularProgressIndicator(
                            color: Colors.cyanAccent.withValues(alpha: 0.4),
                            strokeWidth: 2,
                          ),
                        ),
                        const SizedBox(
                          width: 80,
                          height: 80,
                          child: CircularProgressIndicator(
                            color: Colors.cyanAccent,
                            strokeWidth: 3,
                          ),
                        ),
                        const Icon(Icons.document_scanner, color: Colors.cyanAccent, size: 40),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "객체 및 상태 진단 중...",
                      style: TextStyle(
                        color: Colors.cyanAccent, 
                        fontSize: 18, 
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Ai가 화면을 실시간으로 분석하고 있습니다",
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    )
                  ],
                ),
              ),
            ),
        ],
      ),
      bottomSheet: const GuideBottomSheet(),
      floatingActionButton: _buildPremiumActionButton(status),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildTopStatusPill(DiagnosticState status) {
    String text;
    Color color;
    switch (status) {
      case DiagnosticState.idle:
        text = "카메라 준비 완료";
        color = Colors.white24;
        break;
      case DiagnosticState.scanning:
        text = "지능형 분석 진행";
        color = Colors.cyanAccent.withValues(alpha: 0.3);
        break;
      case DiagnosticState.validating:
        text = "안전 검증 중";
        color = Colors.orangeAccent.withValues(alpha: 0.4);
        break;
      case DiagnosticState.repairing:
        text = "솔루션 안내 중";
        color = Colors.greenAccent.withValues(alpha: 0.4);
        break;
      case DiagnosticState.completed:
        text = "작업 완료";
        color = Colors.blueAccent.withValues(alpha: 0.4);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            spreadRadius: 2,
          )
        ]
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (status == DiagnosticState.scanning || status == DiagnosticState.validating) ...[
            const SizedBox(
              width: 12, 
              height: 12, 
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
            ),
            const SizedBox(width: 8),
          ] else ...[
            const Icon(Icons.circle, color: Colors.white, size: 10),
            const SizedBox(width: 8),
          ],
          Text(
            text,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget? _buildPremiumActionButton(DiagnosticState status) {
    if (status == DiagnosticState.idle) {
      return Container(
        padding: const EdgeInsets.only(bottom: 20),
        child: FloatingActionButton.extended(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 8,
          onPressed: () async {
            if (_cameraController != null && _cameraController!.value.isInitialized) {
              ref.read(diagnosticProvider.notifier).startScanningWithFrame(Uint8List(0)); 
              
              try {
                final XFile image = await _cameraController!.takePicture();
                final Uint8List imageBytes = await image.readAsBytes();
                await ref.read(diagnosticProvider.notifier).startScanningWithFrame(imageBytes);
                
                final errorMsg = ref.read(diagnosticProvider.notifier).errorMessage;
                if (errorMsg != null && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("스캔 실패: \$errorMsg\n\n(*API KEY를 .env에 설정했는지 확인해주세요)"),
                      backgroundColor: Colors.redAccent,
                      duration: const Duration(seconds: 4),
                    )
                  );
                }
              } catch (e) {
                debugPrint("Error taking picture (Web environment may not support this): \$e");
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("웹 프레임 환경상 실제 카메라 캡처가 제한되어, 텍스트 모드로 [솔루션]을 요청합니다."),
                      backgroundColor: Colors.orange,
                      duration: Duration(seconds: 3),
                    )
                  );
                }
                
                final dummyBytes = Uint8List.fromList([1]);
                await ref.read(diagnosticProvider.notifier).startScanningWithFrame(dummyBytes);
                
                final errorMsg = ref.read(diagnosticProvider.notifier).errorMessage;
                if (errorMsg != null && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("API 연동 실패: \$errorMsg"),
                      backgroundColor: Colors.redAccent,
                      duration: const Duration(seconds: 4),
                    )
                  );
                }
              }
            }
          },
          icon: const Icon(Icons.view_in_ar, size: 28),
          label: const Text("솔루션 스캔", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 1.0)),
        ),
      );
    } 
    return null;
  }
}
