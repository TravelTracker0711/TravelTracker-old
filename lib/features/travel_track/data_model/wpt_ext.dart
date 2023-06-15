import 'package:gpx/gpx.dart';
import 'package:travel_tracker/features/travel_track/data_model/travel_data.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:travel_tracker/features/travel_track/data_model/travel_config.dart';
import 'package:travel_tracker/utils/datetime.dart';

class WptExt extends TravelData {
  final latlong.LatLng latLng;
  final double? ele;
  final DateTime? time;

  double get lat => latLng.latitude;
  double get lon => latLng.longitude;

  WptExt({
    TravelConfig? config,
    required latlong.LatLng latLng,
    this.ele,
    this.time,
  })  : latLng = latlong.LatLng(
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
    this.ele,
    this.time,
  }) : super(
          id: id,
          config: config,
        );

  int compareTo(WptExt other) {
    return nullableDateTimeCompare(time, other.time);
  }

  WptExt.clone(WptExt other)
      : latLng = latlong.LatLng(
          other.latLng.latitude,
          other.latLng.longitude,
        ),
        ele = other.ele,
        time = other.time,
        super.clone(other);

  static WptExt fromLatLng({
    required latlong.LatLng latLngs,
  }) {
    return WptExt(
      latLng: latLngs,
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
        latLng: latlong.LatLng(
          wpt.lat!,
          wpt.lon!,
        ),
        ele: wpt.ele,
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
        latLng: latlong.LatLng(
          wpt.lat!,
          wpt.lon!,
        ),
        ele: wpt.ele,
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

  String toString() {
    return 'WptExt(id: $id, latLng: $latLng, ele: $ele, time: $time)';
  }
}
