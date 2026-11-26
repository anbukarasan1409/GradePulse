import 'dart:convert';

import '../models/student_input.dart';
import 'api_transport_stub.dart'
    if (dart.library.io) 'api_transport_io.dart'
    if (dart.library.js_interop) 'api_transport_web.dart';

class ApiHealthStatus {
  const ApiHealthStatus({
    required this.isOnline,
    required this.modelLoaded,
    required this.message,
  });

  final bool isOnline;
  final bool modelLoaded;
  final String message;
}

class ApiException implements Exception {
  const ApiException(this.message);
  final String message;

  @override
  String toString() => message;
}

class StudentApiClient {
  StudentApiClient({String? baseUrl})
      : baseUrl = _normalizeUrl(baseUrl ?? getDefaultApiBaseUrl());

  String baseUrl;

  static String _normalizeUrl(String url) {
    final trimmed = url.trim();
    if (trimmed.endsWith('/')) {
      return trimmed.substring(0, trimmed.length - 1);
    }
    return trimmed;
  }

  void updateBaseUrl(String newUrl) {
    baseUrl = _normalizeUrl(newUrl);
  }

  Future<ApiHealthStatus> checkHealth() async {
    try {
      final res = await performHttpRequest(
        method: 'GET',
        url: '$baseUrl/health',
        timeout: const Duration(seconds: 4),
      );
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body) as Map<String, dynamic>;
        final loaded = decoded['model_loaded'] == true;
        return ApiHealthStatus(
          isOnline: true,
          modelLoaded: loaded,
          message: loaded ? 'ML Model Ready' : 'API Online (Model Missing)',
        );
      }
      return ApiHealthStatus(
        isOnline: false,
        modelLoaded: false,
        message: 'Server returned HTTP ${res.statusCode}',
      );
    } catch (_) {
      return const ApiHealthStatus(
        isOnline: false,
        modelLoaded: false,
        message: 'Backend Offline',
      );
    }
  }

  Future<PredictionResult> predict(StudentInput input) async {
    final stopwatch = Stopwatch()..start();
    try {
      final res = await performHttpRequest(
        method: 'POST',
        url: '$baseUrl/predict',
        jsonBody: jsonEncode(input.toJson()),
        timeout: const Duration(seconds: 8),
      );
      stopwatch.stop();

      final decoded = jsonDecode(res.body);
      if (res.statusCode == 200 && decoded is Map<String, dynamic>) {
        final value = (decoded['predicted_G3'] as num).toDouble();
        return PredictionResult(
          predictedG3: value.clamp(0.0, 20.0),
          input: input,
          timestamp: DateTime.now(),
          responseMs: stopwatch.elapsedMilliseconds,
        );
      }

      if (decoded is Map<String, dynamic>) {
        final err = decoded['error']?.toString() ?? 'Prediction failed.';
        final details = decoded['details'];
        if (details is Map) {
          final firstDetail = details.entries
              .map((e) => '${e.key}: ${e.value}')
              .join('\n');
          throw ApiException('$err\n$firstDetail');
        }
        throw ApiException(err);
      }

      throw ApiException('Unexpected response (${res.statusCode}).');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        'Could not reach Flask API at $baseUrl. Start backend/app.py and try again.',
      );
    }
  }
}
