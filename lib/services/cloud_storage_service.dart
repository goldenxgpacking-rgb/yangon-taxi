import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'api_client.dart';

/// 云存储服务
/// 负责头像、证件照等文件上传
/// TODO: 集成云存储（Cloudinary / Firebase Storage / 腾讯云 COS）
class CloudStorageService {
  final ApiClient _client;

  CloudStorageService(this._client);

  /// 上传头像
  /// - 本地临时头像优先存本地，正式上传后替换
  /// - 支持 JPEG/PNG，最大 2MB
  Future<String?> uploadAvatar(File file) async {
    // 验证文件大小 (2MB)
    if (await file.length() > 2 * 1024 * 1024) {
      throw Exception('图片大小不能超过2MB');
    }

    if (ApiClient.mockMode) {
      await Future.delayed(const Duration(seconds: 1));
      return 'https://api.yangontaxi.com/uploads/avatars/mock_${DateTime.now().millisecondsSinceEpoch}.jpg';
    }

    try {
      final resp = await _client.uploadFile(
        '/uploads/avatar',
        file: file,
        fieldName: 'file',
        parser: (json) => json['url'] as String,
      );
      return resp.data;
    } catch (e) {
      return null;
    }
  }

  /// 上传营业执照/证件（司机端）
  Future<String?> uploadDocument(File file, String documentType) async {
    if (await file.length() > 5 * 1024 * 1024) {
      throw Exception('文件大小不能超过5MB');
    }

    if (ApiClient.mockMode) {
      await Future.delayed(const Duration(seconds: 1));
      return 'https://api.yangontaxi.com/uploads/documents/mock_${documentType}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    }

    try {
      final resp = await _client.uploadFile(
        '/uploads/document',
        file: file,
        fieldName: 'file',
        fields: {'type': documentType},
        parser: (json) => json['url'] as String,
      );
      return resp.data;
    } catch (e) {
      return null;
    }
  }

  /// 缓存头像到本地（离线时显示）
  Future<void> cacheAvatar(String url, Uint8List bytes) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final fileName = url.hashCode.abs().toString();
      final file = File('${dir.path}/avatar_cache/$fileName.jpg');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(bytes);
    } catch (e) {
      // 忽略缓存错误
    }
  }

  /// 获取缓存头像路径
  Future<String?> getCachedAvatar(String url) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final fileName = url.hashCode.abs().toString();
      final file = File('${dir.path}/avatar_cache/$fileName.jpg');
      if (await file.exists()) {
        return file.path;
      }
    } catch (_) {}
    return null;
  }

  /// 清除头像缓存
  Future<void> clearCache() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final cacheDir = Directory('${dir.path}/avatar_cache');
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
      }
    } catch (_) {}
  }
}
