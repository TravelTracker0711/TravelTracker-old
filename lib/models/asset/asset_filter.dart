import 'package:travel_tracker/models/asset/asset.dart';
import 'package:travel_tracker/models/wpt/wpt.dart';

class AssetFilter {
  List<Asset> filterByTimeRange({
    required List<Asset> assets,
    required DateTime startTime,
    required DateTime endTime,
  }) {
    return assets.where((asset) {
      DateTime? time = asset.createdDateTime;
      if (time == null) {
        return false;
      }
      return time.isAfter(startTime) && time.isBefore(endTime);
    }).toList();
  }

  List<Asset> filterByType({
    required List<Asset> assets,
    required AssetType type,
  }) {
    return assets.where((asset) => asset.type == type).toList();
  }

  /// must contain all tags
  List<Asset> filterByTags({
    required List<Asset> assets,
    required List<String> tags,
  }) {
    return assets.where((asset) {
      List<String> assetTags = asset.config.tags;
      for (String tag in tags) {
        if (!assetTags.contains(tag)) return false;
      }
      return true;
    }).toList();
  }

  List<Asset> filterByDistanceToCenter({
    required List<Asset> assets,
    required Wpt center,
    required double radiusInMeter,
  }) {
    return assets.where((asset) {
      Wpt? assetCoordinates = asset.coordinates;
      if (assetCoordinates == null) {
        return false;
      }
      double dis = center.distanceTo(assetCoordinates);
      if (dis <= radiusInMeter) {
        return true;
      }
      return false;
    }).toList();
  }

  List<Asset> filterByCoordinatesInBound({
    required List<Asset> assets,
    required Wpt corner1,
    required Wpt corner2,
  }) {
    double minLatitude = corner1.lat < corner2.lat ? corner1.lat : corner2.lat;
    double maxLatitude = corner1.lat > corner2.lat ? corner1.lat : corner2.lat;
    double minLongitude = corner1.lon < corner2.lon ? corner1.lon : corner2.lon;
    double maxLongitude = corner1.lon > corner2.lon ? corner1.lon : corner2.lon;
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

  List<Asset> filterByTrksegId(List<Asset> assets, String trksegId) {
    return assets.where((asset) => asset.attachedTrksegId == trksegId).toList();
  }
}
