import 'dart:convert';
import 'dart:developer';
import 'package:crypto/crypto.dart';
//its working but agora want own token which on server 
class AgoraTokenBuilder {
  /// Generates a temporary token for testing
  static String generateToken({
    required String appId,
    required String appCertificate,
    required String channelName,
    required int uid,
    int expireTimeInSeconds = 3600,
  }) {
    int currentTs = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    int expireTs = currentTs + expireTimeInSeconds;

    final content = utf8.encode('$appId$channelName$uid$expireTs');
    final hash = Hmac(sha256, utf8.encode(appCertificate)).convert(content);

    final token = '$appId:$expireTs:${hash.toString()}';

    // ✅ Log token and UID
    log('🔑 Generated Token for UID $uid: $token');

    return token;
  }
}
