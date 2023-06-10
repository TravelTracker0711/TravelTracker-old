import 'package:travel_tracker/features/travel_track/data_model/travel_config.dart';
import 'package:uuid/uuid.dart';

class TravelData {
  late final String id;
  late final TravelConfig config;

  TravelData({
    String? id,
    TravelConfig? config,
  }) {
    this.id = id ?? const Uuid().v4();
    if (config == null) {
      this.config = TravelConfig();
    } else {
      this.config = TravelConfig.clone(config);
    }
  }

  TravelData.clone(TravelData other)
      : config = TravelConfig.clone(other.config) {
    id = const Uuid().v4();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'config': config.toJson(),
    };
  }
}
