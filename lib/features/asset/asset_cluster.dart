import 'package:get_it/get_it.dart';
import 'package:latlong2/latlong.dart';
import 'package:travel_tracker/features/asset/data_model/asset_ext.dart';
import 'package:travel_tracker/features/travel_track/data_model/travel_track.dart';
import 'package:travel_tracker/features/travel_track/travel_track_manager.dart';
import 'dart:math';

class AssetCluster {
  List<AssetExt> _assetExts = <AssetExt>[];
  int teamNumber = 5;

  List<LatLng> getRandomPoints() {
    double minLatitude = double.infinity;
    double maxLatitude = double.negativeInfinity;
    double minLongitude = double.infinity;
    double maxLongitude = double.negativeInfinity;

    for (AssetExt assetExt in _assetExts) {
      if (assetExt.coordinates != null) {
        double latitude = assetExt.coordinates!.latLng.latitude;
        double longitude = assetExt.coordinates!.latLng.longitude;

        if (latitude < minLatitude) {
          minLatitude = latitude;
        }
        if (latitude > maxLatitude) {
          maxLatitude = latitude;
        }

        if (longitude < minLongitude) {
          minLongitude = longitude;
        }
        if (longitude > maxLongitude) {
          maxLongitude = longitude;
        }
      }
    }
    List<LatLng> randomPoints = [];
    Random random = Random();

    for (int i = 0; i < teamNumber; i++) {
      double latitude =
          random.nextDouble() * (maxLatitude - minLatitude) + minLatitude;
      double longitude =
          random.nextDouble() * (maxLongitude - minLongitude) + minLongitude;
      randomPoints.add(LatLng(latitude, longitude));
    }

    return randomPoints;
  }

  double dis(double x, double y, double kx, double ky) {
    return sqrt(pow(kx - x, 2) + pow(ky - y, 2));
  }

  // 分群
  List<List<AssetExt>> cluster(List<LatLng> teamCenter) {
    List<List<AssetExt>> teams = [];
    for (int i = 0; i < teamNumber; i++) {
      teams.add([]);
    }
    for (AssetExt asset in _assetExts) {
      double minDis = double.infinity;
      int team = 0;

      for (int j = 0; j < teamNumber; j++) {
        double distant = dis(
            asset.coordinates!.latLng.latitude,
            asset.coordinates!.latLng.longitude,
            teamCenter[j].latitude,
            teamCenter[j].longitude);

        if (distant < minDis) {
          minDis = distant;
          team = j;
        }
      }
      teams[team].add(asset);
    }

    return teams;
  }

  List<LatLng> findNewCenter(
      List<List<AssetExt>> teams, List<LatLng> teamCenter) {
    List<LatLng> newCenter = [];
    for (int i = 0; i < teamNumber; i++) {
      double sumlat = 0;
      double sumlon = 0;

      if (teams[i].isEmpty) {
        newCenter.add(teamCenter[i]);
      }

      for (int j = 0; j < teams[i].length; j++) {
        sumlat += teams[i][j].coordinates!.latLng.latitude;
        sumlon += teams[i][j].coordinates!.latLng.longitude;
      }

      newCenter.add(LatLng(sumlat / teams[i].length, sumlon / teams[i].length));
    }

    return newCenter;
  }

  void kmeans() {
    List<List<AssetExt>> teams = [];
    List<LatLng> teamCenter = <LatLng>[];
    TravelTrackManager travelTrackManager = GetIt.I<TravelTrackManager>();
    TravelTrack? travelTrack = travelTrackManager.activeTravelTrack;
    _assetExts = travelTrack!.assetExts;

    teamCenter = getRandomPoints();
    while (true) {
      teams = cluster(teamCenter);
      List<LatLng> newCenter = findNewCenter(teams, teamCenter);
      if (teamCenter == newCenter) {
        break;
      }
    }

    for (int i = 0; i < teams.length; i++) {
      List<String> assetExtIdGroup = [];

      for (AssetExt assetExt in teams[i]) {
        assetExtIdGroup.add(assetExt.id);
      }

      travelTrack.addAssetExtIdGroupAsync(assetExtIdGroup);
    }
  }
}
