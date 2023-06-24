import 'dart:async';
import 'dart:io';

import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:travel_tracker/features/permission/permission_manager.dart';
import 'package:watcher/watcher.dart';

class ExternalAssetManager {
  AssetPathEntity? _allAssetsPathEntity;
  Map<String, AssetEntity>? _allAssetEntitiesMap;
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
    if (!(await PermissionManager.PhotoManagerRequestAsync())) {
      return;
    }
    _isPermissionGranted = true;
    _allAssetsPathEntity = await _getAllAssetsPathEntityAsync();
    if (_allAssetsPathEntity != null) {
      List<AssetEntity> assetEntities = await _getAssetEntitiesAsync(
        pathEntity: _allAssetsPathEntity!,
      );
      _allAssetEntitiesMap = {
        for (AssetEntity assetEntity in assetEntities)
          (await assetEntity.originFile)!.path: assetEntity,
      };
    }
  }

  // TODO: refactor filter with filter options
  Future<List<AssetEntity>?> getAssetEntitiesBetweenTimeAsync({
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
    List<AssetEntity> assetEntities = await _getAssetEntitiesAsync(
      pathEntity: filteredPathEntity,
    );
    return assetEntities;
  }

  AssetEntity? getAssetEntityByPath(String path) {
    return _allAssetEntitiesMap?[path];
  }

  Future<AssetPathEntity?> _getAllAssetsPathEntityAsync() async {
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

  Future<List<AssetEntity>> _getAssetEntitiesAsync({
    required AssetPathEntity pathEntity,
  }) async {
    List<AssetEntity> assetEntities = await pathEntity.getAssetListRange(
      start: 0,
      end: await pathEntity.assetCountAsync,
    );
    return assetEntities;
  }
}
