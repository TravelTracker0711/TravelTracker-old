import 'package:latlong2/latlong.dart' as latlng;
import 'package:photo_manager/photo_manager.dart';

latlng.LatLng? photoManagerLatLngToLatLong2(LatLng photoManagerLatLng) {
  if (photoManagerLatLng.latitude == null ||
      photoManagerLatLng.longitude == null) {
    return null;
  }
  return latlng.LatLng(
    photoManagerLatLng.latitude!,
    photoManagerLatLng.longitude!,
  );
}
