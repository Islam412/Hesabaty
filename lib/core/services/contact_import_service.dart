// Stub implementation for Linux Desktop.
// On real Android/iOS device, this will be replaced with the correct flutter_contacts API.
// For now, returning empty list to allow the app to build successfully on Linux.

class ImportedContact {
  final String name;
  final String phone;
  ImportedContact(this.name, this.phone);
}

class ContactImportService {
  static Future<bool> requestPermission() async {
    // Not available on Linux Desktop
    return false;
  }

  static Future<List<ImportedContact>> importAll() async {
    // Not available on Linux Desktop - will work on Android/iOS
    return [];
  }
}
