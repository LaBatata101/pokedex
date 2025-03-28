class HttpStatusException implements Exception {
  final int statusCode;
  final String url;
  final String message;

  HttpStatusException(
    this.statusCode,
    this.url, {
    this.message = 'HTTP request failed',
  });

  @override
  String toString() {
    return 'HttpStatusException($statusCode): $message for $url';
  }
}
