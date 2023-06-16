import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:photo_manager/photo_manager.dart';

class ExternalAssetManager {
  AssetPathEntity? _allAssetsPathEntity;
  bool _isInitialized = false;
  bool _isPermissionGranted = false;

  bool get isInitialized => _isInitialized;
  bool get isPermissionGranted => _isPermissionGranted;

  // ignore: non_constant_identifier_names
  static Future<ExternalAssetManager> get FI async {
    return await GetIt.I
        .isReady<ExternalAssetManager>()
        .then((_) => GetIt.I<ExternalAssetManager>());
  }

  Future<void> initAsync() async {
    if (_isInitialized) {
      return;
    }
    _isInitialized = true;
    if (!(await _checkPermissionAsync())) {
      return;
    }
    _isPermissionGranted = true;
    _allAssetsPathEntity = await _getAllAssetPathAsync();
  }

  // TODO: refactor filter with filter options
  Future<List<AssetEntity>?> getAssetsBetweenTimeAsync({
    DateTime? minDate,
    DateTime? maxDate,
    bool isTimeAsc = true,
  }) async {
    if (!_isAllAssetsPathEntityReady()) {
      return null;
    }
    FilterOptionGroup timeRangefilterOption = _getTimeRangeFilterOption(
      minDate: minDate,
      maxDate: maxDate,
      isTimeAsc: isTimeAsc,
    );
    debugPrint("minDate : ${minDate}\nmaxDate : $maxDate");
    AssetPathEntity? filteredPathEntity = await _getFilteredPathEntityAsync(
      filterOption: timeRangefilterOption,
    );
    // debugPrint("asset : ${assets}");
    debugPrint("filteredPathEntity : ${filteredPathEntity}");
    if (filteredPathEntity == null) {
      return null;
    }
    List<AssetEntity> assets = await _getAssetsAsync(
      pathEntity: filteredPathEntity,
    );
    return assets;
  }

  Future<bool> _checkPermissionAsync() async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    return ps.isAuth;
  }

  Future<AssetPathEntity?> _getAllAssetPathAsync() async {
    final List<AssetPathEntity> pathEntities =
        await PhotoManager.getAssetPathList(
      type: RequestType.all,
      hasAll: true,
      onlyAll: true,
    );
    debugPrint(pathEntities.toString());
    if (pathEntities.isEmpty) {
      return null;
    }
    return pathEntities[0];
  }

  bool _isAllAssetsPathEntityReady() {
    return _allAssetsPathEntity != null;
  }

  FilterOptionGroup _getTimeRangeFilterOption({
    DateTime? minDate,
    DateTime? maxDate,
    required bool isTimeAsc,
  }) {
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

  Future<AssetPathEntity?> _getFilteredPathEntityAsync({
    required FilterOptionGroup filterOption,
  }) async {
    AssetPathEntity? filteredPathEntity =
        await _allAssetsPathEntity?.fetchPathProperties(
      filterOptionGroup: filterOption,
    );
    return filteredPathEntity;
  }

  Future<List<AssetEntity>> _getAssetsAsync({
    required AssetPathEntity pathEntity,
  }) async {
    List<AssetEntity> assets = await pathEntity.getAssetListRange(
      start: 0,
      end: await pathEntity.assetCountAsync,
    );
    return assets;
  }
}
