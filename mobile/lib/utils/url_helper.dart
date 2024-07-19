import 'package:immich_mobile/entities/store.entity.dart';
import 'package:logging/logging.dart';
import 'package:punycode_converter/punycode_converter.dart';

String sanitizeUrl(String url) {
  // Add schema if none is set
  final urlWithSchema =
      url.trimLeft().startsWith(RegExp(r"https?://")) ? url : "https://$url";

  // Remove trailing slash(es)
  final trimmed = urlWithSchema.trimRight().replaceFirst(RegExp(r"/+$"), "");
  try {
    final uri = Uri.parse(trimmed);
    return uri.punyEncoded.toString();
  } on PunycodeException catch (e, st) {
    return trimmed;
  }
}

String? getServerUrlForDisplay() {
  final serverUrl = Store.tryGet(StoreKey.serverEndpoint);
  final serverUri = serverUrl != null ? Uri.tryParse(serverUrl) : null;
  if (serverUri == null) {
    return null;
  }

  final decodedHost = Punycode.domainDecode(serverUri.host);
  final log = Logger("UrlHelper");
  final serverString = serverUri.hasPort
      ? "${serverUri.scheme}://$decodedHost:${serverUri.port}"
      : "${serverUri.scheme}://$decodedHost";
  log.info("getServerUrl: $serverString");
  return serverString;
}
