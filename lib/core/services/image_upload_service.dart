import 'dart:convert';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Handles saving picked images locally and uploading to Cloudinary.
class ImageUploadService {
  ImageUploadService({
    String? cloudNameOverride,
    String? uploadPresetOverride,
    String? folderOverride,
  })  : _cloudName = cloudNameOverride ?? _defaultCloudName,
        _uploadPreset = uploadPresetOverride ?? _defaultUploadPreset,
        _folder = folderOverride ?? _defaultFolder;

  static const _defaultCloudName = 'duwazgw9f';
  static const _defaultUploadPreset = 'jusel_unsigned';
  static const _defaultFolder = 'jusel/products';
  static const _defaultUserFolder = 'jusel/users';

  final String _cloudName;
  final String _uploadPreset;
  final String _folder;

  /// Saves a picked image to app documents directory for temporary caching.
  Future<File> saveLocalCopy(XFile pickedImage) async {
    final docsDir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory('${docsDir.path}/product_images');
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }

    final fileName =
        'product_${DateTime.now().millisecondsSinceEpoch}_${pickedImage.name}';
    final targetPath = '${imagesDir.path}/$fileName';

    final file = File(pickedImage.path);
    return file.copy(targetPath);
  }

  /// Uploads an image to Cloudinary and returns the secure URL.
  Future<String> uploadProductImage({
    required File file,
    required String productId,
  }) async {
    // Verify file exists and is readable
    if (!await file.exists()) {
      throw Exception('Image file does not exist at path: ${file.path}');
    }
    final fileSize = await file.length();
    if (fileSize == 0) {
      throw Exception('Image file is empty');
    }
    if (productId.trim().isEmpty) {
      throw Exception('Invalid product id for image upload');
    }

    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
    );

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = _uploadPreset
      ..fields['folder'] = _folder
      ..fields['public_id'] = productId // deterministic path per product
      ..files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
          filename: _buildFileName(file, productId),
          contentType: _inferContentType(file),
        ),
      );

    final response = await http.Response.fromStream(await request.send());
    if (response.statusCode != 200) {
      throw Exception(
        'Cloudinary upload failed (${response.statusCode}): ${response.body}',
      );
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final secureUrl = body['secure_url'] as String?;
    if (secureUrl == null || secureUrl.isEmpty) {
      throw Exception('Cloudinary upload succeeded but secure_url was missing');
    }
    return secureUrl;
  }

  /// Convenience helper to save locally then upload, returning download URL.
  Future<String> saveAndUpload({
    required XFile pickedImage,
    required String productId,
  }) async {
    final localFile = await saveLocalCopy(pickedImage);
    return uploadProductImage(file: localFile, productId: productId);
  }

  MediaType? _inferContentType(File file) {
    final ext = p.extension(file.path).toLowerCase();
    switch (ext) {
      case '.png':
        return MediaType('image', 'png');
      case '.webp':
        return MediaType('image', 'webp');
      default:
        return MediaType('image', 'jpeg'); // default to jpeg
    }
  }

  String _buildFileName(File file, String productId) {
    final ext = p.extension(file.path);
    final safeExt = ext.isNotEmpty ? ext : '.jpg';
    return 'product_$productId$safeExt';
  }

  /// Uploads a user profile image to Cloudinary and returns the secure URL.
  Future<String> uploadUserProfileImage({
    required File file,
    required String userId,
  }) async {
    // Verify file exists and is readable
    if (!await file.exists()) {
      throw Exception('Image file does not exist at path: ${file.path}');
    }
    final fileSize = await file.length();
    if (fileSize == 0) {
      throw Exception('Image file is empty');
    }
    if (userId.trim().isEmpty) {
      throw Exception('Invalid user id for image upload');
    }

    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
    );

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = _uploadPreset
      ..fields['folder'] = _defaultUserFolder
      ..fields['public_id'] = userId // deterministic path per user
      ..files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
          filename: _buildUserFileName(file, userId),
          contentType: _inferContentType(file),
        ),
      );

    final response = await http.Response.fromStream(await request.send());
    if (response.statusCode != 200) {
      throw Exception(
        'Cloudinary upload failed (${response.statusCode}): ${response.body}',
      );
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final secureUrl = body['secure_url'] as String?;
    if (secureUrl == null || secureUrl.isEmpty) {
      throw Exception('Cloudinary upload succeeded but secure_url was missing');
    }
    return secureUrl;
  }

  String _buildUserFileName(File file, String userId) {
    final ext = p.extension(file.path);
    final safeExt = ext.isNotEmpty ? ext : '.jpg';
    return 'user_$userId$safeExt';
  }
}
