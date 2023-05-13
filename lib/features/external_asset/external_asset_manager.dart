import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

// singleton
class ExternalAssetManager {
  AssetPathEntity? _allAssetsPath;

  Future<void> init() async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (!ps.isAuth) {
      debugPrint('Permission not granted');
      return;
    }

    final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
      type: RequestType.all,
      hasAll: true,
      onlyAll: true,
    );
    _allAssetsPath = paths[0];
  }

  Future<List<AssetEntity>?> getAssets({
    DateTime? minDate,
    DateTime? maxDate,
    int? start,
    int? end,
    bool timeAsc = false,
  }) async {
    if (_allAssetsPath == null) {
      debugPrint('Path is null');
      return null;
    }

    final FilterOptionGroup filterOption = FilterOptionGroup(
      updateTimeCond: DateTimeCond(
        min: minDate ?? DateTime.fromMillisecondsSinceEpoch(0),
        max: maxDate ?? DateTime.now(),
      ),
      orders: [
        OrderOption(
          type: OrderOptionType.createDate,
          asc: timeAsc,
        ),
      ],
    );

    AssetPathEntity? filteredPath = await _allAssetsPath?.fetchPathProperties(
      filterOptionGroup: filterOption,
    );

    List<AssetEntity>? assets = await filteredPath?.getAssetListRange(
      start: start ?? 0,
      end: end ?? await _allAssetsPath!.assetCountAsync,
    );
    debugPrint('total assets: ${assets?.length}');
    return assets;
  }

}