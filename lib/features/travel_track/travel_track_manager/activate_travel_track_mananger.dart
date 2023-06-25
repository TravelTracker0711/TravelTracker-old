import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:photo_manager/photo_manager.dart' as pm;
import 'package:travel_tracker/features/asset/external_asset_manager.dart';
import 'package:travel_tracker/features/travel_track/travel_track_manager/travel_track_manager.dart';
import 'package:travel_tracker/models/asset/asset.dart';
import 'package:travel_tracker/models/travel_track/travel_track.dart';

class ActivateTravelTrackManager with ChangeNotifier {
  String? _activeTravelTrackId;
  VoidCallback? _externalAssetManagerListener;

  Map<String, TravelTrack> get _travelTrackMap =>
      TravelTrackManager.I.travelTrackMap;
  String? get activeTravelTrackId => _activeTravelTrackId;
  TravelTrack? get activeTravelTrack => _travelTrackMap[_activeTravelTrackId];
  bool get isActivateTravelTrackExist =>
      _travelTrackMap.containsKey(_activeTravelTrackId);

  static ActivateTravelTrackManager get I =>
      GetIt.I<ActivateTravelTrackManager>();

  void setActiveTravelTrack({
    required String travelTrackId,
  }) {
    if (isActivateTravelTrackExist) {
      activeTravelTrack?.removeListener(_activateTravelTrackListener);
      ExternalAssetManager.FI.then((ExternalAssetManager eam) {
        eam.removeListener(_externalAssetManagerListener!);
      });
    }
    if (!_travelTrackMap.containsKey(travelTrackId)) {
      return;
    }
    _activeTravelTrackId = travelTrackId;
    activeTravelTrack!.addListener(_activateTravelTrackListener);
    ExternalAssetManager.FI.then((ExternalAssetManager eam) {
      _externalAssetManagerListener = _getExternalAssetManagerListener(
        eam,
        activeTravelTrack!,
      );
      eam.addListener(_externalAssetManagerListener!);
    });
    notifyListeners();
  }

  void unsetActiveTravelTrack() {
    if (isActivateTravelTrackExist) {
      activeTravelTrack?.removeListener(_activateTravelTrackListener);
      ExternalAssetManager.FI.then((ExternalAssetManager eam) {
        eam.removeListener(_externalAssetManagerListener!);
      });
      _activeTravelTrackId = null;
      notifyListeners();
    }
  }

  _activateTravelTrackListener() {
    notifyListeners();
  }

  VoidCallback _getExternalAssetManagerListener(
    ExternalAssetManager eam,
    TravelTrack travelTrack,
  ) {
    return () async {
      travelTrack.updateDateTime();
      for (pm.AssetEntity assetEntity in eam.addedAssetEntitieIds) {
        Asset? asset = await AssetFactory.fromAssetEntityAsync(
          assetEntity: assetEntity,
        );
        if (asset == null) {
          continue;
        }
        travelTrack.addAsset(asset: asset);
      }
    };
  }
}
