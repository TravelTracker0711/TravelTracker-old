import 'dart:async';
import 'dart:io';

import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:watcher/watcher.dart';

class ExternalAssetManager {
  AssetPathEntity? _allAssetsPathEntity;
  Map<String, AssetEntity>? _allAssetsMap;
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
    if (_allAssetsPathEntity != null) {
      List<AssetEntity> assets = await _getAssetsAsync(
        pathEntity: _allAssetsPathEntity!,
      );
      _allAssetsMap = {
        for (AssetEntity asset in assets) (await asset.originFile)!.path: asset,
      };

      Map.fromIterable(
        assets,
        key: (asset) => asset.id,
        value: (asset) => asset,
      );
    }
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
    AssetPathEntity? filteredPathEntity = await _getFilteredPathEntityAsync(
      filterOption: timeRangefilterOption,
    );
    if (filteredPathEntity == null) {
      return null;
    }
    List<AssetEntity> assets = await _getAssetsAsync(
      pathEntity: filteredPathEntity,
    );
    return assets;
  }

  AssetEntity? getAssetByPath(String path) {
    return _allAssetsMap?[path];
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
