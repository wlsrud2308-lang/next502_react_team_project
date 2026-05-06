import 'package:next502_app/services/api_client.dart';

/// 이미지 URL 정규화

String? normalizeImageUrl(String? url) {
  if (url == null || url.isEmpty) return null;
  if (url.startsWith('http://') || url.startsWith('https://')) return url;

  if (url.startsWith('/')) {
    return ApiClient.baseUrl + url;
  }

  return '${ApiClient.baseUrl}/$url';
}