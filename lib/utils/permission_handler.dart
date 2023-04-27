import "package:permission_handler/permission_handler.dart";

class PermissionHandler {
  final Map<String, Permission> _permissions = {
    "microphone": Permission.microphone,
    "storage": Permission.storage,
  };

  Future<bool> requestPermissions(List<String> keys) async {
    // Request permissions for each key
    Map<Permission, PermissionStatus> statuses = await [
      for (final key in keys) _permissions[key]!,
    ].request();

    // Check if all permissions are granted
    bool allGranted = statuses.values.every((status) => status.isGranted);

    return allGranted;
  }
}
