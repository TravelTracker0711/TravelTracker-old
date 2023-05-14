import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

// singleton
class ExternalAssetManager {
  AssetPathEntity? _allAssetsPathEntity;

  Future<void> init() async {
    if (!(await _getPermission())) {
      debugPrint('Permission not granted');
      return;
    }
    _allAssetsPathEntity = await _getAllAssetPath();
  }

  Future<List<AssetEntity>?> getAssetsFilteredByTime({
    DateTime? minDate,
    DateTime? maxDate,
    bool isTimeAsc = false,
    int? start,
    int? end,
  }) async {
    if (!_isAllAssetsPathEntityReady()) {
      debugPrint('all asset path not ready');
      return null;
    }
    FilterOptionGroup filterOption =
        _getFilterOption(minDate, maxDate, isTimeAsc);
    AssetPathEntity? filteredPathEntity =
        await _getFilteredPathEntity(filterOption);
    List<AssetEntity>? assets =
        await _getAssetsRange(filteredPathEntity, start, end);
    debugPrint('total assets: ${assets?.length}');
    return assets;
  }

  Future<AssetPathEntity> _getAllAssetPath() async {
    final List<AssetPathEntity> pathEntities =
        await PhotoManager.getAssetPathList(
      type: RequestType.all,
      hasAll: true,
      onlyAll: true,
    );
    return pathEntities[0];
  }

  Future<bool> _getPermission() async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    return ps.isAuth;
  }

  Future<List<AssetEntity>?> _getAssetsRange(
      AssetPathEntity? filteredPathEntity, int? start, int? end) async {
    List<AssetEntity>? assets = await filteredPathEntity?.getAssetListRange(
      start: start ?? 0,
      end: end ?? await filteredPathEntity.assetCountAsync,
    );
    return assets;
  }

  Future<AssetPathEntity?> _getFilteredPathEntity(
      FilterOptionGroup filterOption) async {
    AssetPathEntity? filteredPathEntity =
        await _allAssetsPathEntity?.fetchPathProperties(
      filterOptionGroup: filterOption,
    );
    return filteredPathEntity;
  }

  FilterOptionGroup _getFilterOption(
      DateTime? minDate, DateTime? maxDate, bool isTimeAsc) {
    final FilterOptionGroup filterOption = FilterOptionGroup(
      updateTimeCond: DateTimeCond(
        min: minDate ?? DateTime.fromMillisecondsSinceEpoch(0),
        max: maxDate ?? DateTime.now(),
      ),
      orders: [
        OrderOption(
          type: OrderOptionType.createDate,
          asc: isTimeAsc,
        ),
      ],
    );
    return filterOption;
  }

  bool _isAllAssetsPathEntityReady() {
    return _allAssetsPathEntity != null;
  }
}
