import 'dart:io';

import 'package:photo_manager/photo_manager.dart' as pm;
import 'package:latlong2/latlong.dart' as latlong;
import 'package:travel_tracker/features/asset/external_asset_manager.dart';
import 'package:travel_tracker/models/travel_config/travel_config.dart';
import 'package:travel_tracker/models/trkseg/trkseg.dart';
import 'package:travel_tracker/models/wpt/wpt.dart';
import 'package:travel_tracker/utils/latlng.dart';

part 'factory.dart';
part 'conversion.dart';
part 'utils.dart';

enum AssetType {
  image,
  video,
  audio,
  text,
  unknown,
}

class Asset {
  final TravelConfig config;
  final pm.AssetEntity assetEntity;
  final AssetType type;
  final String fileFullPath;
  Wpt? coordinates;
  String? attachedTrksegId;

  DateTime get createDateTime => assetEntity.createDateTime;

  Asset({
    TravelConfig? config,
    required this.assetEntity,
    required this.type,
    required this.fileFullPath,
    Wpt? coordinates,
    this.attachedTrksegId,
  })  : config = config?.clone() ?? TravelConfig(),
        coordinates = coordinates?.clone();

  int compareTo(Asset other) {
    return createDateTime.compareTo(other.createDateTime);
  }
}
