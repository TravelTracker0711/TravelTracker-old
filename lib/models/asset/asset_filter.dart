// TODO: Implement AssetFilter
import 'package:latlong2/latlong.dart' as latlng;
import 'package:travel_tracker/models/asset/asset.dart';
import 'package:travel_tracker/models/wpt/wpt.dart';

class AssetFilter {
  List<Asset> filterByTimeRange(
      List<Asset> assets, DateTime startTime, DateTime endTime) {
    return assets
        .where((asset) =>
            asset.assetEntity.createDateTime.isAfter(startTime) &&
            asset.assetEntity.createDateTime.isBefore(endTime))
        .toList();
  }

  List<Asset> filterByType(List<Asset> assets, AssetType type) {
    return assets.where((asset) => asset.type == type).toList();
  }

  List<Asset> filterByTag(List<Asset> assets, String tag) {
    return assets.where((asset) => asset.config.tags.contains(tag)).toList();
  }

  List<Asset> filterByLocationInCircle(
      List<Asset> assets, Wpt center, double radiusMeter) {
    return assets.where((asset) {
      Wpt? assetCoordinates = asset.coordinates;
      if (assetCoordinates == null) return false;
      const latlng.Distance distance = latlng.Distance();
      double dis = distance(center.latLng, assetCoordinates.latLng);
      if (dis <= radiusMeter) return true;
      return false;
    }).toList();
  }

  //filterByLocationInBound
  List<Asset> filterByLocationInBound(List<Asset> assets, Wpt p1, Wpt p2) {
    double minLatitude = p1.lat < p2.lat ? p1.lat : p2.lat;
    double maxLatitude = p1.lat > p2.lat ? p1.lat : p2.lat;
    double minLongitude = p1.lon < p2.lon ? p1.lon : p2.lon;
    double maxLongitude = p1.lon > p2.lon ? p1.lon : p2.lon;
    return assets.where((asset) {
      Wpt? assetCoordinates = asset.coordinates;
      if (assetCoordinates == null) return false;
      double latitude = assetCoordinates.lat;
      double longitude = assetCoordinates.lon;
      return (latitude >= minLatitude &&
          latitude <= maxLatitude &&
          longitude >= minLongitude &&
          longitude <= maxLongitude);
    }).toList();
  }

  List<Asset> filterByTrkseg(List<Asset> assets, String trksegId) {
    return assets.where((asset) => asset.attachedTrksegId == trksegId).toList();
  }
}
