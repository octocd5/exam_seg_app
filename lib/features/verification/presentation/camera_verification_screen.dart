import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../timer/controllers/timer_controller.dart';
import '../controllers/vision_controller.dart';

class CameraVerificationScreen extends ConsumerStatefulWidget {
  final String targetObject;

  const CameraVerificationScreen({
    super.key,
    required this.targetObject,
  });

  @override
  ConsumerState<CameraVerificationScreen> createState() =>
      _CameraVerificationScreenState();
}

class _CameraVerificationScreenState
    extends ConsumerState<CameraVerificationScreen> {
  CameraController? _cameraController;
  final VisionVerificationService _visionService = VisionVerificationService();

  bool _isCameraInitialized = false;
  bool _isProcessing = false;
  bool _isSuccess = false;
  String? _errorMessage;
  VerificationResult? _lastResult;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      if (mounted) {
        setState(() {
          _errorMessage =
              'Camera permission is required to verify objects and unlock your phone.';
        });
      }
      return;
    }

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) {
          setState(() {
            _errorMessage = 'No camera found on this device.';
          });
        }
        return;
      }

      final controller = CameraController(
        cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await controller.initialize();
      if (!mounted) return;

      setState(() {
        _cameraController = controller;
        _isCameraInitialized = true;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to initialize camera: $e';
        });
      }
    }
  }

  Future<void> _captureAndVerify() async {
    if (_cameraController == null ||
        !_cameraController!.value.isInitialized ||
        _isProcessing) {
      return;
    }

    setState(() {
      _isProcessing = true;
      _lastResult = null;
    });

    try {
      final XFile photo = await _cameraController!.takePicture();
      final inputImage = InputImage.fromFilePath(photo.path);
      final result =
          await _visionService.verifyImage(inputImage, widget.targetObject);

      // Clean up temp photo
      try {
        final file = File(photo.path);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (_) {}

      if (!mounted) return;

      if (result.isMatch) {
        setState(() {
          _isSuccess = true;
          _lastResult = result;
          _isProcessing = false;
        });

        // Trigger unlock and timer stop
        await ref
            .read(timerControllerProvider.notifier)
            .onVerificationSuccess();

        // Brief delay for user celebration animation before popping
        await Future.delayed(const Duration(milliseconds: 1400));
        if (mounted) {
          Navigator.of(context).pop();
        }
      } else {
        setState(() {
          _lastResult = result;
          _isProcessing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _errorMessage = 'Error analyzing picture: $e';
        });
      }
    }
  }

  /// Simulator or fallback helper for testing in environments without physical camera
  Future<void> _simulateVerification() async {
    setState(() {
      _isProcessing = true;
    });
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    setState(() {
      _isSuccess = true;
      _isProcessing = false;
      _lastResult = VerificationResult(
        isMatch: true,
        matchedLabel: widget.targetObject,
        confidence: 0.95,
      );
    });

    await ref.read(timerControllerProvider.notifier).onVerificationSuccess();

    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _visionService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildChallengeBanner(),
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  _buildCameraView(),
                  if (_isSuccess) _buildSuccessOverlay(),
                  if (_isProcessing) _buildProcessingOverlay(),
                ],
              ),
            ),
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildChallengeBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
      ),
      child: Column(
        children: [
          const Text(
            'To unlock your phone and stop the timer:',
            style: TextStyle(fontSize: 13, color: Colors.white70),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Take a picture of: ',
                  style: TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                      fontWeight: FontWeight.w500)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFF59E0B),
                  ),
                ),
                child: Text(
                  widget.targetObject,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFBBF24),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCameraView() {
    if (_errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.warning_amber_rounded,
                size: 56, color: Colors.amber),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: openAppSettings,
              child: const Text('Open App Settings'),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: _simulateVerification,
              icon: const Icon(Icons.bug_report),
              label: const Text('Simulate Scan (Testing)'),
            ),
          ],
        ),
      );
    }

    if (!_isCameraInitialized || _cameraController == null) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF10B981)),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: AspectRatio(
        aspectRatio: _cameraController!.value.aspectRatio,
        child: Stack(
          alignment: Alignment.center,
          fit: StackFit.expand,
          children: [
            CameraPreview(_cameraController!),
            // Target Viewfinder Reticle
            Center(
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.7),
                    width: 2.5,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessingOverlay() {
    return Container(
      color: Colors.black54,
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Color(0xFFF59E0B)),
            SizedBox(height: 16),
            Text(
              'Analyzing with ML Kit...',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessOverlay() {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 80,
              color: Color(0xFF10B981),
            ),
            const SizedBox(height: 16),
            Text(
              'Verified: ${_lastResult?.matchedLabel ?? widget.targetObject}!',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_lastResult?.confidence != null) ...[
              const SizedBox(height: 6),
              Text(
                'Confidence: ${((_lastResult!.confidence!) * 100).toStringAsFixed(0)}%',
                style: const TextStyle(color: Color(0xFF10B981), fontSize: 16),
              ),
            ],
            const SizedBox(height: 12),
            const Text(
              'Focus Lock Released 🎉',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      color: const Color(0xFF0F172A),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_lastResult != null && !_lastResult!.isMatch) ...[
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
              ),
              child: Column(
                children: [
                  Text(
                    'No "${widget.targetObject}" detected.',
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  if (_lastResult!.detectedLabels.isNotEmpty)
                    Text(
                      'AI recognized: ${_lastResult!.detectedLabels.take(3).join(', ')}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
            ),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white70),
                tooltip: 'Back to Timer',
                onPressed: () => Navigator.of(context).pop(),
              ),
              GestureDetector(
                onTap: _isProcessing ? null : _captureAndVerify,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    color: const Color(0xFFF59E0B),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    size: 34,
                    color: Colors.black,
                  ),
                ),
              ),
              // Simulator test button in case camera has issues
              IconButton(
                icon: const Icon(Icons.check_circle_outline,
                    color: Colors.white38),
                tooltip: 'Simulate Valid Scan (Testing)',
                onPressed: _simulateVerification,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
