import 'package:geolocator/geolocator.dart';
import 'package:gpx/gpx.dart' as gpx_pkg;
import 'package:travel_tracker/features/travel_track/data_model/travel_data.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:travel_tracker/features/travel_track/data_model/travel_config.dart';
import 'package:travel_tracker/utils/datetime.dart';

class Wpt extends TravelData {
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
    this.time,
  })  : latLng = latlng.LatLng(
          latLng.latitude,
          latLng.longitude,
        ),
        super(
          config: config,
        );

  Wpt._({
    String? id,
    TravelConfig? config,
    required this.latLng,
    this.elevation,
    this.time,
  }) : super(
          id: id,
          config: config,
        );

  int compareTo(Wpt other) {
    return nullableDateTimeCompare(time, other.time);
  }

  Wpt.clone(Wpt other)
      : latLng = latlng.LatLng(
          other.latLng.latitude,
          other.latLng.longitude,
        ),
        elevation = other.ele,
        time = other.time,
        super.clone(other);

  static Wpt fromLatLng({
    required latlng.LatLng latLngs,
  }) {
    return Wpt(
      latLng: latLngs,
    );
  }

  static Wpt fromPosition({
    required Position position,
  }) {
    return Wpt(
      latLng: latlng.LatLng(
        position.latitude,
        position.longitude,
      ),
      elevation: position.altitude,
      time: position.timestamp,
    );
  }

  static List<Wpt> fromGpx({
    required gpx_pkg.Gpx gpx,
  }) {
    List<Wpt> wpts = [];
    for (gpx_pkg.Wpt wpt in gpx.wpts) {
      if (wpt.lat == null || wpt.lon == null) {
        continue;
      }
      wpts.add(Wpt(
        latLng: latlng.LatLng(
          wpt.lat!,
          wpt.lon!,
        ),
        elevation: wpt.ele,
        time: wpt.time,
      ));
    }
    return wpts;
  }

  static List<Wpt> fromTrkseg({
    required gpx_pkg.Trkseg trkseg,
  }) {
    List<Wpt> trkpts = [];
    for (gpx_pkg.Wpt wpt in trkseg.trkpts) {
      if (wpt.lat == null || wpt.lon == null) {
        continue;
      }
      trkpts.add(Wpt(
        latLng: latlng.LatLng(
          wpt.lat!,
          wpt.lon!,
        ),
        elevation: wpt.ele,
        time: wpt.time,
      ));
    }
    return trkpts;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = super.toJson();
    json.addAll({
      'lat': latLng.latitude,
      'lon': latLng.longitude,
    });
    if (ele != null) {
      json['ele'] = ele;
    }
    if (time != null) {
      json['time'] = time!.toIso8601String();
    }
    return json;
  }

  Wpt.fromJson(Map<String, dynamic> json)
      : latLng = latlng.LatLng(
          json['lat'],
          json['lon'],
        ),
        elevation = json['ele'],
        time = json['time'] == null ? null : DateTime.parse(json['time']),
        super.fromJson(json);

  String toString() {
    return 'Wpt(id: $id, latLng: $latLng, ele: $ele, time: $time)';
  }
}
