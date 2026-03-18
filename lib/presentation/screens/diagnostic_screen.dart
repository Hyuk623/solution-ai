import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/diagnostic_provider.dart';
import '../widgets/guide_bottom_sheet.dart';
import 'package:image_picker/image_picker.dart' show ImagePicker, ImageSource, XFile;

class DiagnosticScreen extends ConsumerStatefulWidget {
  const DiagnosticScreen({super.key});

  @override
  ConsumerState<DiagnosticScreen> createState() => _DiagnosticScreenState();
}

class _DiagnosticScreenState extends ConsumerState<DiagnosticScreen> {
  final ImagePicker _picker = ImagePicker();
  
  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final Uint8List imageBytes = await image.readAsBytes();
        await ref.read(diagnosticProvider.notifier).startScanningWithFrame(imageBytes);
      }
    } catch (e) {
      debugPrint("Gallery Pick Error: $e");
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        final Uint8List imageBytes = await image.readAsBytes();
        await ref.read(diagnosticProvider.notifier).startScanningWithFrame(imageBytes);
      }
    } catch (e) {
      debugPrint("Camera Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(diagnosticProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Berry Analyst AI', 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2)
        ),
        centerTitle: true,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF1E293B).withOpacity(0.8),
                    const Color(0xFF0F172A),
                  ],
                ),
              ),
            ),
          ),
          
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (status == DiagnosticState.idle) ...[
                    const Icon(Icons.eco_rounded, size: 80, color: Colors.greenAccent),
                    const SizedBox(height: 24),
                    const Text(
                      "딸기를 진단할 준비가 완료되었습니다",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildActionCard(
                          icon: Icons.camera_alt_outlined,
                          label: "사진 촬영",
                          onTap: _takePhoto,
                        ),
                        const SizedBox(width: 20),
                        _buildActionCard(
                          icon: Icons.photo_library_outlined,
                          label: "갤러리 업로드",
                          onTap: _pickImageFromGallery,
                        ),
                      ],
                    ),
                  ] else if (status == DiagnosticState.scanning) ...[
                    const CircularProgressIndicator(color: Colors.greenAccent),
                    const SizedBox(height: 24),
                    const Text(
                      "AI가 분석 중입니다...",
                      style: TextStyle(color: Colors.greenAccent, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ] else ...[
                    const GuideBottomSheet(),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 40),
            const SizedBox(height: 12),
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
