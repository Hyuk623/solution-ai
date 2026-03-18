import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/diagnostic_provider.dart';
import '../widgets/guide_bottom_sheet.dart';
import '../widgets/ar_overlay_painter.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart' show ImagePicker, ImageSource;

class DiagnosticScreen extends ConsumerStatefulWidget {
  const DiagnosticScreen({super.key});

  @override
  ConsumerState<DiagnosticScreen> createState() => _DiagnosticScreenState();
}

class _DiagnosticScreenState extends ConsumerState<DiagnosticScreen> {
  CameraController? _cameraController;
  final ImagePicker _picker = ImagePicker();
  
  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return; 
    
    _cameraController = CameraController(cameras.first, ResolutionPreset.medium);
    await _cameraController?.initialize();
    if (mounted) setState(() {});
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final Uint8List imageBytes = await image.readAsBytes();
        ref.read(diagnosticProvider.notifier).startScanningWithFrame(Uint8List(0)); 
        await ref.read(diagnosticProvider.notifier).startScanningWithFrame(imageBytes);
      }
    } catch (e) {
      debugPrint("Gallery Pick Error: $e");
    }
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
        backgroundColor: Colors.black.withOpacity(0.3),
        elevation: 0,
        title: const Text('Berry Analyst AI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: status == DiagnosticState.idle ? _pickImageFromGallery : null,
            icon: const Icon(Icons.photo_library_outlined, color: Colors.white),
          )
        ],
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
              color: Colors.black.withOpacity(0.7),
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
                            color: Colors.cyanAccent.withOpacity(0.4),
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
                        const Icon(Icons.eco_outlined, color: Colors.cyanAccent, size: 40),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "딸기 생육 상태 분석 중...",
                      style: TextStyle(
                        color: Colors.cyanAccent, 
                        fontSize: 18, 
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "AI가 잎의 색상과 열매의 성숙도를 체크합니다",
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
        text = "진단 준비 완료";
        color = Colors.white24;
        break;
      case DiagnosticState.scanning:
        text = "생육 분석 중";
        color = Colors.cyanAccent.withOpacity(0.3);
        break;
      case DiagnosticState.validating:
        text = "기록 검증 중";
        color = Colors.orangeAccent.withOpacity(0.4);
        break;
      case DiagnosticState.repairing:
        text = "분석 결과 요약";
        color = Colors.greenAccent.withOpacity(0.4);
        break;
      case DiagnosticState.completed:
        text = "자동 기록 완료";
        color = Colors.blueAccent.withOpacity(0.4);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
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
              } catch (e) {
                debugPrint("Camera capture error: $e");
                final dummyBytes = Uint8List.fromList([1]);
                await ref.read(diagnosticProvider.notifier).startScanningWithFrame(dummyBytes);
              }
            }
          },
          icon: const Icon(Icons.eco, size: 28, color: Colors.green),
          label: const Text("생육 상태 진단", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 1.0)),
        ),
      );
    } 
    return null;
  }
}
