import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

class VerificationResult {
  final bool isMatch;
  final String? matchedLabel;
  final double? confidence;
  final List<String> detectedLabels;

  const VerificationResult({
    required this.isMatch,
    this.matchedLabel,
    this.confidence,
    this.detectedLabels = const [],
  });
}

class VisionVerificationService {
  late final ImageLabeler _labeler;
  bool _isProcessing = false;

  VisionVerificationService({double confidenceThreshold = 0.65}) {
    final options = ImageLabelerOptions(confidenceThreshold: confidenceThreshold);
    _labeler = ImageLabeler(options: options);
  }

  Future<VerificationResult> verifyImage(
      InputImage inputImage, String targetLabel) async {
    if (_isProcessing) {
      return const VerificationResult(isMatch: false);
    }
    _isProcessing = true;

    try {
      final labels = await _labeler.processImage(inputImage);
      final detected = labels
          .map((l) => '${l.label} (${(l.confidence * 100).toStringAsFixed(0)}%)')
          .toList();

      for (final label in labels) {
        if (label.label.toLowerCase().contains(targetLabel.toLowerCase()) ||
            targetLabel.toLowerCase().contains(label.label.toLowerCase())) {
          return VerificationResult(
            isMatch: true,
            matchedLabel: label.label,
            confidence: label.confidence,
            detectedLabels: detected,
          );
        }
      }

      return VerificationResult(
        isMatch: false,
        detectedLabels: detected,
      );
    } finally {
      _isProcessing = false;
    }
  }

  /// Original boolean helper
  Future<bool> processFrame(InputImage inputImage, String targetLabel) async {
    final result = await verifyImage(inputImage, targetLabel);
    return result.isMatch;
  }

  void dispose() {
    _labeler.close();
  }
}
