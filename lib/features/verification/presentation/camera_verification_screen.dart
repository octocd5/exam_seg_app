import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/localization/locale_controller.dart';
import '../../timer/controllers/timer_controller.dart';
import '../controllers/vision_controller.dart';

enum _CameraErrorType {
  permissionDenied,
  noCamera,
  initFailed,
  analyzeFailed,
}

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
  _CameraErrorType? _errorType;
  String? _errorDetails;
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
          _errorType = _CameraErrorType.permissionDenied;
        });
      }
      return;
    }

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) {
          setState(() {
            _errorType = _CameraErrorType.noCamera;
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
          _errorType = _CameraErrorType.initFailed;
          _errorDetails = e.toString();
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
          _errorType = _CameraErrorType.analyzeFailed;
          _errorDetails = e.toString();
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

  String _resolveErrorMessage(AppStrings strings) {
    return switch (_errorType) {
      _CameraErrorType.permissionDenied => strings.cameraPermissionRequired,
      _CameraErrorType.noCamera => strings.cameraNotFound,
      _CameraErrorType.initFailed => strings.cameraInitFailed(_errorDetails ?? ''),
      _CameraErrorType.analyzeFailed => strings.cameraAnalyzingError(_errorDetails ?? ''),
      null => '',
    };
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(appStringsProvider);

    return Scaffold(
      backgroundColor: kTimerStandbyBackgroundColor,
      appBar: AppBar(
        backgroundColor: kTimerStandbyBackgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: kTimerStandbyTextColor),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildChallengeBanner(strings),
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  _buildCameraView(strings),
                  if (_isSuccess) _buildSuccessOverlay(strings),
                  if (_isProcessing) _buildProcessingOverlay(strings),
                ],
              ),
            ),
            _buildBottomControls(strings),
          ],
        ),
      ),
    );
  }

  Widget _buildChallengeBanner(AppStrings strings) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        color: Color(0xFF282724),
        border: Border(
          bottom: BorderSide(
            color: Color(0xFF383633),
            width: 1.5,
          ),
        ),
      ),
      child: Column(
        children: [
          Text(
            strings.cameraUnlockInstructions,
            style: TextStyle(
              fontSize: 13,
              color: kTimerStandbyTextColor.withValues(alpha: 0.65),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                strings.cameraTakePicOf,
                style: const TextStyle(
                  fontSize: 15,
                  color: kTimerStandbyTextColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: kTimerStandbyButtonColor.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: kTimerStandbyButtonColor.withValues(alpha: 0.5),
                    width: 1.2,
                  ),
                ),
                child: Text(
                  strings.translateObject(widget.targetObject),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: kTimerStandbyButtonColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCameraView(AppStrings strings) {
    if (_errorType != null) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.warning_rounded,
              size: 56,
              color: kTimerStandbyButtonColor,
            ),
            const SizedBox(height: 16),
            Text(
              _resolveErrorMessage(strings),
              textAlign: TextAlign.center,
              style: const TextStyle(color: kTimerStandbyTextColor, fontSize: 15),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: openAppSettings,
              style: ElevatedButton.styleFrom(
                backgroundColor: kTimerStandbyButtonColor,
                foregroundColor: kTimerStandbyButtonTextColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(strings.cameraOpenSettings),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: _simulateVerification,
              icon: const Icon(Icons.bug_report, color: kTimerStandbyButtonColor),
              label: Text(
                strings.cameraSimulateScan,
                style: const TextStyle(color: kTimerStandbyButtonColor),
              ),
            ),
          ],
        ),
      );
    }

    if (!_isCameraInitialized || _cameraController == null) {
      return const Center(
        child: CircularProgressIndicator(color: kTimerStandbyButtonColor),
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
                    color: kTimerStandbyButtonColor.withValues(alpha: 0.75),
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

  Widget _buildProcessingOverlay(AppStrings strings) {
    return Container(
      color: kTimerStandbyBackgroundColor.withValues(alpha: 0.75),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: kTimerStandbyButtonColor),
            const SizedBox(height: 16),
            Text(
              strings.cameraAnalyzing,
              style: const TextStyle(
                color: kTimerStandbyTextColor,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessOverlay(AppStrings strings) {
    final matched = strings.translateObject(_lastResult?.matchedLabel ?? widget.targetObject);

    return Container(
      color: kTimerStandbyBackgroundColor.withValues(alpha: 0.90),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 80,
              color: kTimerStandbyButtonColor,
            ),
            const SizedBox(height: 16),
            Text(
              strings.cameraVerified(matched),
              style: const TextStyle(
                color: kTimerStandbyTextColor,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_lastResult?.confidence != null) ...[
              const SizedBox(height: 6),
              Text(
                strings.cameraConfidence(((_lastResult!.confidence!) * 100).toInt()),
                style: const TextStyle(
                  color: kTimerStandbyButtonColor,
                  fontSize: 16,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Text(
              strings.cameraFocusLockReleased,
              style: TextStyle(
                color: kTimerStandbyTextColor.withValues(alpha: 0.70),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls(AppStrings strings) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF282724),
        border: Border(
          top: BorderSide(
            color: Color(0xFF383633),
            width: 1.0,
          ),
        ),
      ),
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
                    strings.cameraNoObjectDetected(
                      strings.translateObject(widget.targetObject),
                    ),
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  if (_lastResult!.detectedLabels.isNotEmpty)
                    Text(
                      strings.cameraAIRecognized(
                        _lastResult!.detectedLabels
                            .take(3)
                            .map((l) => strings.translateObject(l))
                            .join(', '),
                      ),
                      style: TextStyle(
                        color: kTimerStandbyTextColor.withValues(alpha: 0.7),
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
                icon: Icon(
                  Icons.arrow_back,
                  color: kTimerStandbyTextColor.withValues(alpha: 0.75),
                ),
                tooltip: strings.cameraBackTooltip,
                onPressed: () => Navigator.of(context).pop(),
              ),
              GestureDetector(
                onTap: _isProcessing ? null : _captureAndVerify,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: kTimerStandbyTextColor, width: 3.5),
                    color: kTimerStandbyButtonColor,
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    size: 34,
                    color: kTimerStandbyButtonTextColor,
                  ),
                ),
              ),
              // Simulator test button in case camera has issues
              IconButton(
                icon: Icon(
                  Icons.check_circle_outline,
                  color: kTimerStandbyTextColor.withValues(alpha: 0.40),
                ),
                tooltip: strings.cameraSimulateValidScanTooltip,
                onPressed: _simulateVerification,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
