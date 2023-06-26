// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:travel_tracker/features/permission/permission_manager.dart';
// import 'package:travel_tracker/features/travel_track_recorder/gps_provider.dart';
// import 'package:travel_tracker/models/wpt/wpt.dart';

// extension GeolocatorGpsAccuracy on GpsAccuracy {
//   LocationAccuracy toGeolocator() {
//     switch (this) {
//       case GpsAccuracy.powerSave:
//         return LocationAccuracy.lowest;
//       case GpsAccuracy.lowest:
//         return LocationAccuracy.lowest;
//       case GpsAccuracy.low:
//         return LocationAccuracy.low;
//       case GpsAccuracy.medium:
//         return LocationAccuracy.medium;
//       case GpsAccuracy.high:
//         return LocationAccuracy.high;
//       case GpsAccuracy.best:
//         return LocationAccuracy.best;
//       case GpsAccuracy.bestForNavigation:
//         return LocationAccuracy.bestForNavigation;
//       case GpsAccuracy.reduced:
//         return LocationAccuracy.reduced;
//       default:
//         throw Exception('Unknown GpsAccuracy: $this');
//     }
//   }
// }

// class GeolocatorGpsProvider extends GpsProvider {
//   bool _isInitialized = false;
//   bool _isRecording = false;
//   bool _isNewPoint = false;
//   LocationSettings _locationSettings = const LocationSettings(
//     accuracy: LocationAccuracy.best,
//     distanceFilter: 10,
//   );
//   StreamSubscription<Position>? _positionStreamSubscription;
//   Wpt? _wpt;

//   @override
//   bool get isInitialized => _isInitialized;
//   @override
//   bool get isRecording => _isRecording;
//   @override
//   bool get isNewPoint => _isNewPoint;

//   @override
//   Wpt? get wpt => _wpt;

//   @override
//   Future<void> initAsync() async {
//     await PermissionManager.geolocatorRequestAsync();
//     _isInitialized = true;
//     notifyListeners();
//   }

//   @override
//   Future<void> startRecordingAsync() async {
//     if (_isRecording) {
//       return;
//     }
//     if (await PermissionManager.geolocatorRequestAsync() == false) {
//       // TODO: handle permission not granted
//       return;
//     }
//     debugPrint('GeolocatorGpsProvider.startRecording');
//     _positionStreamSubscription = Geolocator.getPositionStream(
//       locationSettings: _locationSettings,
//     ).listen(_positionStreamListener);
//     _isRecording = true;
//   }

//   @override
//   void stopRecording() {
//     if (!_isRecording) {
//       return;
//     }
//     debugPrint("stopRecording");
//     _positionStreamSubscription?.cancel();
//     _positionStreamSubscription = null;
//     _isRecording = false;
//     notifyListeners();
//   }

//   @override
//   void toggleRecording() {
//     if (_isRecording) {
//       stopRecording();
//     } else {
//       startRecordingAsync();
//     }
//   }

//   @override
//   void setGpsSettings({
//     GpsAccuracy? accuracy,
//     double? distanceFilter,
//     double? intervalMilli,
//   }) {
//     _locationSettings = LocationSettings(
//       accuracy: accuracy?.toGeolocator() ?? _locationSettings.accuracy,
//       distanceFilter:
//           distanceFilter?.toInt() ?? _locationSettings.distanceFilter,
//     );
//   }

//   void _positionStreamListener(Position? pos) {
//     if (pos == null) {
//       return;
//     }
//     Wpt newWpt = WptFactory.fromPosition(position: pos);
//     if (_wpt != null && _wpt!.latLng == newWpt.latLng) {
//       debugPrint('GeolocatorGpsProvider: same wpt');
//       return;
//     }
//     _wpt = newWpt;
//     debugPrint('GeolocatorGpsProvider: new wpt: $_wpt');
//     notifyListeners(isNewPoint: true);
//   }

//   @override
//   void notifyListeners({
//     bool isNewPoint = false,
//   }) {
//     _isNewPoint = isNewPoint;
//     super.notifyListeners();
//   }
// }
