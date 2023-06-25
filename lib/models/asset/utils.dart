part of 'asset.dart';

extension AssetTypeUtils on AssetType {
  bool get hasThumbnail {
    switch (this) {
      case AssetType.image:
        return true;
      case AssetType.video:
        return true;
      case AssetType.audio:
        return false;
      case AssetType.text:
        return false;
      case AssetType.unknown:
        return false;
      case AssetType.unset:
        return false;
      default:
        return false;
    }
  }
}

extension AssetUtils on Asset {
  FutureBuilder get futureThumbnail {
    return FutureBuilder<void>(
      future: fetchEntityDataAsync(),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (entity != null) {
            if (!type.hasThumbnail) {
              return Icon(
                type.icon,
              );
            }
            return Image(
              image: pm.AssetEntityImageProvider(
                entity!,
                isOriginal: false,
              ),
              fit: BoxFit.cover,
            );
          }
          return Icon(
            type.icon,
          );
        }
        return const CircularProgressIndicator();
      },
    );
  }
}

extension AssetsUtils on List<Asset> {
  void setCoordinatesByTrkseg({
    required Trkseg trkseg,
    bool overrideOriginCoordinates = true,
  }) {
    List<Wpt> trkptsWithTime = trkseg.trkpts.where((trkpt) {
      return trkpt.time != null;
    }).toList();
    int trkptIndex = 0;
    for (Asset asset in this) {
      if (overrideOriginCoordinates == false && asset.coordinates != null) {
        continue;
      }
      trkptIndex = _getNextTrkptIndexByAssetTime(
        trkptsWithTime: trkptsWithTime,
        asset: asset,
        trkptIndex: trkptIndex,
      );
      latlong.LatLng latLng = _getInterpolatedLatLngByAssetTime(
        trkptsWithTime: trkptsWithTime,
        trkptIndex: trkptIndex,
        asset: asset,
      );
      asset._coordinates = Wpt(
        latLng: latLng,
      );
      asset.attachedTrksegId = trkseg.id;
    }
  }

  static int _getNextTrkptIndexByAssetTime({
    required List<Wpt> trkptsWithTime,
    required Asset asset,
    required int trkptIndex,
  }) {
    if (asset.createdDateTime == null) {
      return trkptIndex;
    }
    // find first trkpt with time >= asset createdDateTime
    while (trkptIndex < trkptsWithTime.length - 1) {
      DateTime nextTrkptTime = trkptsWithTime[trkptIndex + 1].time!;
      DateTime assetTime = asset.createdDateTime!;
      if (assetTime.isBefore(nextTrkptTime)) {
        break;
      }
      trkptIndex++;
    }
    return trkptIndex;
  }

  static latlong.LatLng _getInterpolatedLatLngByAssetTime({
    required List<Wpt> trkptsWithTime,
    required Asset asset,
    required int trkptIndex,
  }) {
    latlong.LatLng latLng = latlong.LatLng(
      trkptsWithTime[trkptIndex].lat,
      trkptsWithTime[trkptIndex].lon,
    );

    if (asset.createdDateTime == null) {
      return latLng;
    }
    if (trkptIndex < trkptsWithTime.length - 1) {
      int assetMs = asset.createdDateTime!.millisecondsSinceEpoch;
      int curMs = trkptsWithTime[trkptIndex].time!.millisecondsSinceEpoch;
      int nxtMs = trkptsWithTime[trkptIndex + 1].time!.millisecondsSinceEpoch;
      double interpRatio = (assetMs - curMs) / (nxtMs - curMs);
      double curLat = trkptsWithTime[trkptIndex].lat;
      double curLon = trkptsWithTime[trkptIndex].lon;
      double nxtLat = trkptsWithTime[trkptIndex + 1].lat;
      double nxtLon = trkptsWithTime[trkptIndex + 1].lon;
      // TODO: varify the accuracy of the interpolation
      // (cur + (nxt - cur) * interpRatio) may be correct
      // in the Mercator projection
      latLng = latlong.LatLng(
        curLat + (nxtLat - curLat) * interpRatio,
        curLon + (nxtLon - curLon) * interpRatio,
      );
    }
    return latLng;
  }
}
