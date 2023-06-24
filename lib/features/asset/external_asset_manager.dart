import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:travel_tracker/features/asset/photo_manager_extension.dart';
import 'package:travel_tracker/features/permission/permission_manager.dart';

class ExternalAssetManager with ChangeNotifier {
  bool _isInitializing = false;
  bool _isReady = false;
  AssetPathEntity? _allAssetsPathEntity;
  List<AssetEntity> _allAssetEntities = [];
  Map<String, AssetEntity> _allAssetEntitiesMap = {};

  bool get isReady => _isReady;
  AssetPathEntity? get allAssetsPathEntity => _allAssetsPathEntity;
  List<AssetEntity> get allAssetEntities => List<AssetEntity>.unmodifiable(
        _allAssetEntities,
      );
  Map<String, AssetEntity> get allAssetEntitiesMap =>
      Map<String, AssetEntity>.unmodifiable(
        _allAssetEntitiesMap,
      );

  // ignore: non_constant_identifier_names
  static Future<ExternalAssetManager> get FI async {
    return GetIt.I.getAsync<ExternalAssetManager>();
  }

  Future<void> initAsync() async {
    if (_isInitializing) {
      return;
    }
    _isInitializing = true;

    if (!(await PermissionManager.PhotoManagerRequestAsync())) {
      return;
    }

    await fetchAllAssetEntitiesAsync();
    PhotoManager.addChangeCallback((value) async {
      await fetchAllAssetEntitiesAsync();
    });
    _isReady = true;
  }

  Future<AssetEntity?> getAssetEntityAsync({
    required String id,
  }) async {
    AssetEntity? assetEntity = _allAssetEntitiesMap[id];
    return assetEntity;
  }

  Future<List<AssetEntity>?> getFilteredAssetEntitiesAsync({
    required FilterOptionGroup filterOptionGroup,
  }) async {
    AssetPathEntity? filteredPathEntity =
        await _allAssetsPathEntity?.fetchPathProperties(
      filterOptionGroup: filterOptionGroup,
    );
    List<AssetEntity>? assetEntities =
        await filteredPathEntity?.getAllAssetEntitiesAsync();
    return assetEntities;
  }

  Future<List<AssetEntity>?> getAssetEntitiesBetweenTimeAsync({
    DateTime? minDate,
    DateTime? maxDate,
    bool isTimeAsc = true,
  }) async {
    FilterOptionGroup timeRangefilterOption = _getTimeRangeFilterOptionGroup(
      minDate: minDate,
      maxDate: maxDate,
      isTimeAsc: isTimeAsc,
    );
    List<AssetEntity>? assetEntities = await getFilteredAssetEntitiesAsync(
      filterOptionGroup: timeRangefilterOption,
    );
    return assetEntities;
  }

  Future<void> fetchAllAssetEntitiesAsync() async {
    _allAssetsPathEntity =
        await PhotoManagerExtension.getAllAssetsPathEntityAsync();
    if (_allAssetsPathEntity == null) {
      _allAssetEntities = [];
      _allAssetEntitiesMap = {};
    } else {
      _allAssetEntities =
          await _allAssetsPathEntity!.getAllAssetEntitiesAsync();
      _allAssetEntitiesMap = _allAssetEntities.toMap();
    }
    notifyListeners();
  }

  FilterOptionGroup _getTimeRangeFilterOptionGroup({
    DateTime? minDate,
    DateTime? maxDate,
    required bool isTimeAsc,
  }) {
    final FilterOptionGroup filterOptionGroup = FilterOptionGroup(
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
    return filterOptionGroup;
  }
}
