import 'package:geolocator/geolocator.dart';
import 'package:gpx/gpx.dart';
import 'package:travel_tracker/features/travel_track/data_model/travel_data.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:travel_tracker/features/travel_track/data_model/travel_config.dart';
import 'package:travel_tracker/utils/datetime.dart';

class WptExt extends TravelData {
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

  WptExt({
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

  WptExt._({
    String? id,
    TravelConfig? config,
    required this.latLng,
    this.elevation,
    this.time,
  }) : super(
          id: id,
          config: config,
        );

  int compareTo(WptExt other) {
    return nullableDateTimeCompare(time, other.time);
  }

  WptExt.clone(WptExt other)
      : latLng = latlng.LatLng(
          other.latLng.latitude,
          other.latLng.longitude,
        ),
        elevation = other.ele,
        time = other.time,
        super.clone(other);

  static WptExt fromLatLng({
    required latlng.LatLng latLngs,
  }) {
    return WptExt(
      latLng: latLngs,
    );
  }

  static WptExt fromPosition({
    required Position position,
  }) {
    return WptExt(
      latLng: latlng.LatLng(
        position.latitude,
        position.longitude,
      ),
      elevation: position.altitude,
      time: position.timestamp,
    );
  }

  static List<WptExt> fromGpx({
    required Gpx gpx,
  }) {
    List<WptExt> wptExts = [];
    for (Wpt wpt in gpx.wpts) {
      if (wpt.lat == null || wpt.lon == null) {
        continue;
      }
      wptExts.add(WptExt(
        latLng: latlng.LatLng(
          wpt.lat!,
          wpt.lon!,
        ),
        elevation: wpt.ele,
        time: wpt.time,
      ));
    }
    return wptExts;
  }

  static List<WptExt> fromTrkseg({
    required Trkseg trkseg,
  }) {
    List<WptExt> trkpts = [];
    for (Wpt wpt in trkseg.trkpts) {
      if (wpt.lat == null || wpt.lon == null) {
        continue;
      }
      trkpts.add(WptExt(
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

  WptExt.fromJson(Map<String, dynamic> json)
      : latLng = latlng.LatLng(
          json['lat'],
          json['lon'],
        ),
        elevation = json['ele'],
        time = json['time'] == null ? null : DateTime.parse(json['time']),
        super.fromJson(json);

  String toString() {
    return 'WptExt(id: $id, latLng: $latLng, ele: $ele, time: $time)';
  }
}
