import 'package:location/location.dart' as loc;
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

  static bool _locationServiceEnabled = false;
  static loc.PermissionStatus _locationPermissionGranted =
      loc.PermissionStatus.denied;

  static bool get locationServiceEnabled => _locationServiceEnabled;
  static loc.PermissionStatus get locationPermissionGranted =>
      _locationPermissionGranted;

  static Future<bool> locationRequestAsync(loc.Location location) async {
    if (locationServiceEnabled &&
        locationPermissionGranted == loc.PermissionStatus.granted) {
      return true;
    }

    _locationServiceEnabled = await location.serviceEnabled();
    if (!_locationServiceEnabled) {
      _locationServiceEnabled = await location.requestService();
      if (!_locationServiceEnabled) {
        return false;
      }
    }

    _locationPermissionGranted = await location.hasPermission();
    if (_locationPermissionGranted == loc.PermissionStatus.denied) {
      _locationPermissionGranted = await location.requestPermission();
      if (_locationPermissionGranted != loc.PermissionStatus.granted) {
        return false;
      }
    }

    return true;
  }
}
