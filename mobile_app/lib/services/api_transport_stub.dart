class TransportResponse {
  const TransportResponse({required this.statusCode, required this.body});
  final int statusCode;
  final String body;
}

String getDefaultApiBaseUrl() => 'http://127.0.0.1:5000';

Future<TransportResponse> performHttpRequest({
  required String method,
  required String url,
  String? jsonBody,
  Duration timeout = const Duration(seconds: 8),
}) {
  throw UnsupportedError('Platform HTTP transport is unavailable.');
}
