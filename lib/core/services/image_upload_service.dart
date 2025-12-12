import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

/// Handles saving picked images locally and uploading to Firebase Storage.
class ImageUploadService {
  ImageUploadService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

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

  /// Uploads an image to Firebase Storage and returns the download URL.
  Future<String> uploadProductImage({
    required File file,
    required String productId,
  }) async {
    try {
      final ref = _storage.ref().child('products/$productId/image.jpg');
      await ref.putFile(file);
      return ref.getDownloadURL();
    } on FirebaseException catch (e) {
      throw Exception('Image upload failed: ${e.message ?? e.code}');
    } catch (e) {
      throw Exception('Image upload failed: $e');
    }
  }

  /// Convenience helper to save locally then upload, returning download URL.
  Future<String> saveAndUpload({
    required XFile pickedImage,
    required String productId,
  }) async {
    final localFile = await saveLocalCopy(pickedImage);
    return uploadProductImage(file: localFile, productId: productId);
  }
}
