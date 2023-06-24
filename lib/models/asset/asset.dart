import 'dart:io';

import 'package:photo_manager/photo_manager.dart' as pm;
import 'package:latlong2/latlong.dart' as latlong;
import 'package:travel_tracker/models/travel_config/travel_config.dart';
import 'package:travel_tracker/models/trkseg/trkseg.dart';
import 'package:travel_tracker/models/wpt/wpt.dart';
import 'package:travel_tracker/utils/latlng.dart';

part 'factory.dart';
part 'conversion.dart';

enum AssetType {
  image,
  video,
  audio,
  text,
  unknown;

  @override
  String toString() {
    switch (this) {
      case AssetType.audio:
        return 'AssetType.audio';
      case AssetType.video:
        return 'AssetType.video';
      case AssetType.image:
        return 'AssetType.image';
      case AssetType.text:
        return 'AssetType.text';
      case AssetType.unknown:
        return 'AssetType.unknown';
      default:
        return 'AssetType.unknown';
    }
  }
}

class Asset {
  final TravelConfig config;
  final File file;
  final AssetType type;
  final DateTime createdDateTime;
  Wpt? coordinates;
  String? attachedTrksegId;

  DateTime get lastModifiedDateTime {
    // TODO: check if AssetEntity.createDataTime and lastModifiedDateTime are the same
    assert(createdDateTime != file.lastModifiedSync().toUtc(),
        'createdDateTime and lastModifiedDateTime are the same');
    return file.lastModifiedSync().toUtc();
  }

  String get fileFullPath => file.path;

  Asset({
    TravelConfig? config,
    required this.file,
    required this.type,
    required DateTime createdDateTime,
    Wpt? coordinates,
    this.attachedTrksegId,
  })  : config = config?.clone() ?? TravelConfig(),
        createdDateTime = createdDateTime.toUtc(),
        coordinates = coordinates?.clone();

  int compareTo(Asset other) {
    return createdDateTime.compareTo(other.createdDateTime);
  }
}
