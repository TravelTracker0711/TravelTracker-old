// TODO: Implement AssetExtFilter
import 'package:latlong2/latlong.dart' as latlng;
import 'package:travel_tracker/features/asset/data_model/asset_ext.dart';
import 'package:travel_tracker/features/travel_track/data_model/wpt.dart';

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
    return assetExts
        .where((assetExt) => assetExt.config.tags.contains(tag))
        .toList();
  }

  List<AssetExt> filterByLocationInCircle(
      List<AssetExt> assetExts, Wpt center, double radiusMeter) {
    return assetExts.where((assetExt) {
      Wpt? assetCoordinates = assetExt.coordinates;
      if (assetCoordinates == null) return false;
      const latlng.Distance distance = latlng.Distance();
      double dis = distance(center.latLng, assetCoordinates.latLng);
      if (dis <= radiusMeter) return true;
      return false;
    }).toList();
  }

  //filterByLocationInBound
  List<AssetExt> filterByLocationInBound(
      List<AssetExt> assetExts, Wpt p1, Wpt p2) {
    double minLatitude = p1.lat < p2.lat ? p1.lat : p2.lat;
    double maxLatitude = p1.lat > p2.lat ? p1.lat : p2.lat;
    double minLongitude = p1.lon < p2.lon ? p1.lon : p2.lon;
    double maxLongitude = p1.lon > p2.lon ? p1.lon : p2.lon;
    return assetExts.where((assetExt) {
      Wpt? assetCoordinates = assetExt.coordinates;
      if (assetCoordinates == null) return false;
      double latitude = assetCoordinates.lat;
      double longitude = assetCoordinates.lon;
      return (latitude >= minLatitude &&
          latitude <= maxLatitude &&
          longitude >= minLongitude &&
          longitude <= maxLongitude);
    }).toList();
  }

  List<AssetExt> filterByTrkseg(List<AssetExt> assetExts, String trksegId) {
    return assetExts
        .where((assetExt) => assetExt.attachedTrksegId == trksegId)
        .toList();
  }
}
