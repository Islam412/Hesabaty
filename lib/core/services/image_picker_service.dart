import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

class ImagePickerService {
  static final _picker = ImagePicker();

  static Future<String?> pickAndSave({bool fromCamera = false}) async {
    final source = fromCamera ? ImageSource.camera : ImageSource.gallery;
    final x = await _picker.pickImage(source: source, maxWidth: 1600, imageQuality: 85);
    if (x == null) return null;
    final dir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory('${dir.path}/images');
    if (!await imagesDir.exists()) await imagesDir.create(recursive: true);
    final name = '${const Uuid().v4()}${p.extension(x.path)}';
    final dest = '${imagesDir.path}/$name';
    await File(x.path).copy(dest);
    return dest;
  }
}
