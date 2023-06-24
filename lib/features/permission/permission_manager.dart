import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';

// TODO: rewrite to widget for showToast?
class PermissionManager {
  static Future<bool> requestAsync(Permission permission) async {
    if (await permission.isPermanentlyDenied) {
      await openAppSettings();
    }
    if (await permission.isGranted) {
      return true;
    }
    var status = await permission.request();
    return status.isGranted;
  }

  // TODO: maybe refactor to use permission_handler
  static Future<bool> PhotoManagerRequestAsync() async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (!ps.isAuth) {
      // TODO: open when permission permantently denied
      await PhotoManager.openSetting();
    }
    if (ps.isAuth) {
      // TODO: check what this does
      PhotoManager.setIgnorePermissionCheck(true);
    }
    return ps.isAuth;
  }
}
