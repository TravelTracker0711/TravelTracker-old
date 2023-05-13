import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:gpx/gpx.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:travel_tracker/features/external_asset/external_asset_manager.dart';
import 'package:latlong2/latlong.dart' as latlng;

class GpxModel with ChangeNotifier {
  final List<Gpx> _gpxs = <Gpx>[];
  final List<TrksegWithAssets> _trksegWithAssets = <TrksegWithAssets>[];
  int _lastTrksegIndex = 0;

  List<Gpx> get gpxs => _gpxs;
  List<TrksegWithAssets> get trksegWithAssets => _trksegWithAssets;
  Gpx? get lastGpx => _gpxs.isNotEmpty ? _gpxs.last : null;
  List<TrksegWithAssets> get lastTrksegWithAssets =>
      _trksegWithAssets.sublist(_lastTrksegIndex);

  Future<void> addGpx(Gpx gpx) async {
    _gpxs.add(gpx);
    _lastTrksegIndex = _trksegWithAssets.length;
    for (Trk trk in gpx.trks) {
      for (Trkseg trkseg in trk.trksegs) {
        _trksegWithAssets.add(await TrksegWithAssets.create(trkseg: trkseg));
      }
    }
    notifyListeners();
  }
}

class TrksegWithAssets {
  TrksegWithAssets(
      {required this.trkseg, required this.customAssets}) ;

  static Future<TrksegWithAssets> create(
      {required Trkseg trkseg, List<AssetEntity>? assets}) async {
    assets ??= await GetIt.I
        .isReady<ExternalAssetManager>()
        .then((_) async => GetIt.I<ExternalAssetManager>().getAssets(
              minDate: trkseg.trkpts.first.time,
              maxDate: trkseg.trkpts.last.time,
              timeAsc: true,
            ));

    List<CustomAsset> customAssets = <CustomAsset>[];

    if (assets != null) {
      int trkptIndex = 0;
      for (AssetEntity asset in assets) {
        latlng.LatLng? latLng;
        if (asset.latitude != null && asset.longitude != null) {
          latLng = latlng.LatLng(
            asset.latitude!,
            asset.longitude!,
          );
        } else {
          while (trkptIndex < trkseg.trkpts.length - 1 &&
              (trkseg.trkpts[trkptIndex + 1].time
                      !.isBefore(asset.createDateTime))) {
            trkptIndex++;
            debugPrint('${trkseg.trkpts[trkptIndex].time} ${asset.createDateTime}');
          }
          latLng = latlng.LatLng(
            trkseg.trkpts[trkptIndex].lat!,
            trkseg.trkpts[trkptIndex].lon!,
          );
          debugPrint('${asset.title} ${trkptIndex} ${asset.createDateTime} ${latLng}');
        }
        CustomAsset customAsset = CustomAsset(asset: asset, latLng: latLng);
        customAssets.add(customAsset);
      }
    }
    return TrksegWithAssets(trkseg: trkseg, customAssets: customAssets);
  }

  Trkseg trkseg;
  List<CustomAsset> customAssets;
}

class CustomAsset {
  CustomAsset({required this.asset, required this.latLng});

  AssetEntity asset;
  latlng.LatLng latLng;
}
