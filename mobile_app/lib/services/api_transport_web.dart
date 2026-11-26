import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'api_transport_stub.dart';

String getDefaultApiBaseUrl() => 'http://127.0.0.1:5000';

Future<TransportResponse> performHttpRequest({
  required String method,
  required String url,
  String? jsonBody,
  Duration timeout = const Duration(seconds: 8),
}) async {
  final headers = JSObject();
  headers['Accept'] = 'application/json'.toJS;
  if (jsonBody != null) {
    headers['Content-Type'] = 'application/json'.toJS;
  }

  final init = JSObject();
  init['method'] = method.toJS;
  init['headers'] = headers;
  if (jsonBody != null) {
    init['body'] = jsonBody.toJS;
  }

  final promise = globalContext.callMethod<JSPromise<JSObject>>(
    'fetch'.toJS,
    url.toJS,
    init,
  );
  final response = await promise.toDart.timeout(timeout);
  final status = (response['status'] as JSNumber).toDartInt;
  final textPromise = response.callMethod<JSPromise<JSString>>('text'.toJS);
  final text = (await textPromise.toDart.timeout(timeout)).toDart;
  return TransportResponse(statusCode: status, body: text);
}
