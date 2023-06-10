// TODO: Implement AssetExtFilter
import 'package:travel_tracker/features/travel_track/asset_ext.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:gpx/gpx.dart';

class AssetExtFilter {
  List<AssetExt> filterByTimeRange(
      List<AssetExt> assetExts, DateTime startTime, DateTime endTime) {
    return assetExts
        .where((assetExt) =>
            assetExt.asset.createDateTime.isAfter(startTime) &&
            assetExt.asset.createDateTime.isBefore(endTime))
        .toList();
  }

  List<AssetExt> filterByType(List<AssetExt> assetExts, AssetExtType type) {
    return assetExts.where((assetExt) => assetExt.type == type).toList();
  }

  List<AssetExt> filterByTag(List<AssetExt> assetExts, String tag) {
    return assetExts.where((assetExt) => assetExt.tags.contains(tag)).toList();
  }

  List<AssetExt> filterByLocationInCircle(
      List<AssetExt> assetExts, latlng.LatLng center, double radiusMeter) {
    return assetExts.where((assetExt) {
      latlng.LatLng? assetLatLng = assetExt.latLng;
      if (assetLatLng == null) return false;
      const latlng.Distance distance = latlng.Distance();
      double dis = distance(center, assetLatLng);
      if (dis <= radiusMeter) return true;
      return false;
    }).toList();
  }

  //filterByLocationInBound
  List<AssetExt> filterByLocationInBound(
      List<AssetExt> assetExts, latlng.LatLng p1, latlng.LatLng p2) {
    double minLatitude = p1.latitude < p2.latitude ? p1.latitude : p2.latitude;
    double maxLatitude = p1.latitude > p2.latitude ? p1.latitude : p2.latitude;
    double minLongitude =
        p1.longitude < p2.longitude ? p1.longitude : p2.longitude;
    double maxLongitude =
        p1.longitude > p2.longitude ? p1.longitude : p2.longitude;
    return assetExts.where((assetExt) {
      latlng.LatLng? assetLatLng = assetExt.latLng;
      if (assetLatLng == null) return false;
      double latitude = assetExt.latLng!.latitude;
      double longitude = assetExt.latLng!.longitude;
      return (latitude >= minLatitude &&
          latitude <= maxLatitude &&
          longitude >= minLongitude &&
          longitude <= maxLongitude);
    }).toList();
  }

  List<AssetExt> filterByTrkseg(List<AssetExt> assetExts, Trkseg trkseg) {
    return assetExts
        .where((assetExt) => assetExt.attachedTrksegExt?.trkseg == trkseg)
        .toList();
  }
}
