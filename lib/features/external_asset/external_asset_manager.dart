import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:photo_manager/photo_manager.dart';

class ExternalAssetManager {
  AssetPathEntity? _allAssetsPathEntity;

  // ignore: non_constant_identifier_names
  static Future<ExternalAssetManager> get FI async {
    return await GetIt.I
        .isReady<ExternalAssetManager>()
        .then((_) => GetIt.I<ExternalAssetManager>());
  }

  Future<void> initAsync() async {
    if (!(await _getPermissionAsync())) {
      debugPrint('Permission not granted');
      return;
    }
    _allAssetsPathEntity = await _getAllAssetPathAsync();
  }

  // TODO: refactor filter with filter options
  Future<List<AssetEntity>?> getAssetsFilteredByTimeAsync({
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
        await _getFilteredPathEntityAsync(filterOption);
    List<AssetEntity>? assets =
        await _getAssetsRangeAsync(filteredPathEntity, start, end);
    debugPrint('total assets: ${assets?.length}');
    return assets;
  }

  Future<AssetPathEntity?> _getAllAssetPathAsync() async {
    final List<AssetPathEntity> pathEntities =
        await PhotoManager.getAssetPathList(
      type: RequestType.all,
      hasAll: true,
      onlyAll: true,
    );
    if (pathEntities.isEmpty) {
      return null;
    }
    return pathEntities[0];
  }

  Future<bool> _getPermissionAsync() async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    return ps.isAuth;
  }

  Future<List<AssetEntity>?> _getAssetsRangeAsync(
      AssetPathEntity? filteredPathEntity, int? start, int? end) async {
    List<AssetEntity>? assets = await filteredPathEntity?.getAssetListRange(
      start: start ?? 0,
      end: end ?? await filteredPathEntity.assetCountAsync,
    );
    return assets;
  }

  Future<AssetPathEntity?> _getFilteredPathEntityAsync(
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
