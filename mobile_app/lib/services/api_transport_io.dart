import 'dart:convert';
import 'dart:io';

import 'api_transport_stub.dart';

String getDefaultApiBaseUrl() {
  if (Platform.isAndroid) {
    return 'http://10.0.2.2:5000';
  }
  return 'http://127.0.0.1:5000';
}

Future<TransportResponse> performHttpRequest({
  required String method,
  required String url,
  String? jsonBody,
  Duration timeout = const Duration(seconds: 8),
}) async {
  final client = HttpClient()..connectionTimeout = timeout;
  try {
    final uri = Uri.parse(url);
    final request = await client.openUrl(method, uri).timeout(timeout);
    request.headers.set(HttpHeaders.acceptHeader, 'application/json');
    if (jsonBody != null) {
      final bytes = utf8.encode(jsonBody);
      request.headers.contentType = ContentType.json;
      request.contentLength = bytes.length;
      request.add(bytes);
    }
    final response = await request.close().timeout(timeout);
    final body = await response.transform(utf8.decoder).join().timeout(timeout);
    return TransportResponse(statusCode: response.statusCode, body: body);
  } finally {
    client.close(force: true);
  }
}
