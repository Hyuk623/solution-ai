import 'dart:math';

class NetworkRetry {
  /// Executes an async network operation with Exponential Backoff.
  /// Used primarily for Gemini API to handle rate limits or brief outages.
  static Future<T> withBackoff<T>(Future<T> Function() action, {int maxRetries = 5}) async {
    int attempt = 0;
    while (attempt < maxRetries) {
      try {
        return await action();
      } catch (e) {
        attempt++;
        if (attempt >= maxRetries) {
          // If 5 attempts fail, we activate the offline fallback exception
          throw OfflineFallbackException("네트워크 연결에 지속적으로 실패했습니다. 오프라인 기본 안전 매뉴얼을 로드합니다. (\u0024e)");
        }
        
        // Exponential backoff: 2^attempt * 500ms (500ms, 1s, 2s, 4s...)
        final delayMs = pow(2, attempt).toInt() * 500;
        await Future.delayed(Duration(milliseconds: delayMs));
      }
    }
    throw Exception("Unreachable");
  }
}

class OfflineFallbackException implements Exception {
  final String message;
  OfflineFallbackException(this.message);
}
