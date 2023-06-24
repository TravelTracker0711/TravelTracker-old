import 'package:latlong2/latlong.dart' as latlng;
import 'package:photo_manager/photo_manager.dart';

extension LatLong2ToPhotoManager on latlng.LatLng {
  LatLng toPhotoManagerLatLng() {
    return LatLng(
      latitude: latitude,
      longitude: longitude,
    );
  }
}

extension PhotoManagerToLatLong2 on LatLng {
  latlng.LatLng? toLatLong2() {
    if (latitude == null || longitude == null) {
      return null;
    }
    return latlng.LatLng(
      latitude!,
      longitude!,
    );
  }
}

extension LatLong2Clone on latlng.LatLng {
  latlng.LatLng clone() {
    return latlng.LatLng(
      latitude,
      longitude,
    );
  }
}
