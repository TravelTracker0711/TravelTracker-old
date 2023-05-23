import 'package:flutter/material.dart';
import 'package:gpx/gpx.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:travel_tracker/features/external_asset/external_asset_manager.dart';
import 'package:latlong2/latlong.dart' as latlng;

// TODO: refactor this file into travel_track folder
class GpxModel with ChangeNotifier {
  final List<Gpx> _gpxs = <Gpx>[];
  final List<TrksegWithAssets> _trksegsWithAssets = <TrksegWithAssets>[];

  List<Gpx> get gpxs => _gpxs;
  List<TrksegWithAssets> get trksegsWithAssets => _trksegsWithAssets;

  Future<void> addGpx(Gpx gpx) async {
    _gpxs.add(gpx);
    _trksegsWithAssets.addAll(await _getAllTrksegWithAssets(gpx));
    notifyListeners();
  }

  Future<List<TrksegWithAssets>> _getAllTrksegWithAssets(Gpx gpx) async {
    List<TrksegWithAssets> trksegsWithAssets = <TrksegWithAssets>[];
    for (Trk trk in gpx.trks) {
      for (Trkseg trkseg in trk.trksegs) {
        trksegsWithAssets.add(await TrksegWithAssets.create(trkseg: trkseg));
      }
    }
    return trksegsWithAssets;
  }
}

class TrksegWithAssets {
  TrksegWithAssets({required this.trkseg, required this.extendedAssets});

  Trkseg trkseg;
  List<ExtendedAsset> extendedAssets;

  static Future<TrksegWithAssets> create(
      {required Trkseg trkseg, List<AssetEntity>? assets}) async {
    assets ??= await _getAssetsInTrkseg(assets, trkseg);
    List<ExtendedAsset> extendedAssets = _locateAssetsInTrkseg(trkseg, assets);
    return TrksegWithAssets(trkseg: trkseg, extendedAssets: extendedAssets);
  }

  static List<ExtendedAsset> _locateAssetsInTrkseg(
      Trkseg trkseg, List<AssetEntity>? assets) {
    List<ExtendedAsset> extendedAssets = <ExtendedAsset>[];
    if (assets == null) {
      return extendedAssets;
    }
    int trkptIndex = 0;
    for (AssetEntity asset in assets) {
      while (trkptIndex < trkseg.trkpts.length - 1 &&
          (trkseg.trkpts[trkptIndex + 1].time!.isBefore(asset.createDateTime))) {
        trkptIndex++;
      }
      latlng.LatLng latLng = latlng.LatLng(
        trkseg.trkpts[trkptIndex].lat!,
        trkseg.trkpts[trkptIndex].lon!,
      );
      ExtendedAsset extendedAsset = ExtendedAsset(asset: asset, latLng: latLng);
      extendedAssets.add(extendedAsset);
    }
    return extendedAssets;
  }

  static Future<List<AssetEntity>?> _getAssetsInTrkseg(List<AssetEntity>? assets, Trkseg trkseg) async {
    ExternalAssetManager eam = await ExternalAssetManager.FI;
    assets ??= await eam.getAssetsFilteredByTime(
      minDate: trkseg.trkpts.first.time,
      maxDate: trkseg.trkpts.last.time,
      isTimeAsc: true,
    );
    return assets;
  }
}

class ExtendedAsset {
  ExtendedAsset({required this.asset, required this.latLng});

  AssetEntity asset;
  latlng.LatLng latLng;
}
