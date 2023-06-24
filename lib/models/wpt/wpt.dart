import 'package:geolocator/geolocator.dart';
import 'package:gpx/gpx.dart' as gpx_pkg;
import 'package:latlong2/latlong.dart' as latlng;
import 'package:travel_tracker/models/travel_config/travel_config.dart';
import 'package:travel_tracker/utils/datetime.dart';
import 'package:travel_tracker/utils/latlng.dart';

part 'factory.dart';
part 'conversion.dart';
part 'utils.dart';

class Wpt {
  final TravelConfig config;
  final latlng.LatLng latLng;
  final double? elevation;
  final DateTime? time;
  // TODO: add these, reference position.dart in geolocator package
  // final double? accuracy;
  // final double? heading;
  // final double? speed;
  // final double? speedAccuracy;
  // final int? floor;

  double get lat => latLng.latitude;
  double get lon => latLng.longitude;
  double? get ele => elevation;

  Wpt({
    TravelConfig? config,
    required latlng.LatLng latLng,
    this.elevation,
    DateTime? time,
  })  : config = config?.clone() ?? TravelConfig(),
        latLng = latLng.clone(),
        time = time?.toUtc();

  Wpt clone() => Wpt(
        config: config,
        latLng: latLng,
        elevation: elevation,
        time: time,
      );

  int compareTo(Wpt other) {
    return nullableDateTimeCompare(time, other.time);
  }

  @override
  String toString() {
    return 'Wpt(config: $config, latLng: $latLng, ele: $ele, time: $time)';
  }
}
