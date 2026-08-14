import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

class ImagePickerService {
  static final _picker = ImagePicker();

  static Future<String?> _saveX(XFile x) async {
    final dir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory('${dir.path}/images');
    if (!await imagesDir.exists()) await imagesDir.create(recursive: true);
    final name = '${const Uuid().v4()}${p.extension(x.path)}';
    final dest = '${imagesDir.path}/$name';
    await File(x.path).copy(dest);
    return dest;
  }

  static Future<String?> pickAndSave({bool fromCamera = false}) async {
    try {
      final x = await _picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 1600,
        imageQuality: 85,
      );
      if (x == null) return null;
      return _saveX(x);
    } catch (_) {
      if (fromCamera) {
        try {
          final x = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 1600, imageQuality: 85);
          if (x == null) return null;
          return _saveX(x);
        } catch (_) {
          return null;
        }
      }
      return null;
    }
  }
}
