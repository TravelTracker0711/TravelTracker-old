import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:geolocator/geolocator.dart';

// TODO: rewrite to widget for showToast?
// TODO: refactor openAppSettings, make sure user knows why they are being redirected
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
  static Future<bool> photoManagerRequestAsync() async {
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

  static Future<bool> geolocatorRequestAsync() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.always) {
      return true;
    } else if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    } else if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.whileInUse) {
      await Geolocator.openAppSettings();
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return false;
    }
    return true;
  }
}
