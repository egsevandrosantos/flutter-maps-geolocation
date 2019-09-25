import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<bool> checkPermission(PermissionGroup permissionGroup) async {
    PermissionStatus permission = await PermissionHandler().checkPermissionStatus(permissionGroup);
    return permission == PermissionStatus.granted;
  }

  Future<void> requestPermission(PermissionGroup permissionGroup) async {
    await PermissionHandler().requestPermissions([permissionGroup]);
  }
}