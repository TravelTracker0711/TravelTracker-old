import 'package:travel_tracker/features/travel_track/travel_track_manager/travel_track_manager.dart';

class TravelTrackStateChanger {
  static void selectTravelTrack({
    required String travelTrackId,
  }) {
    TravelTrackManager.I.travelTrackMap[travelTrackId]?.isSelected = true;
    TravelTrackManager.I.notifyListeners();
  }

  static void unselectTravelTrack({
    required String travelTrackId,
  }) {
    TravelTrackManager.I.travelTrackMap[travelTrackId]?.isSelected = false;
    TravelTrackManager.I.notifyListeners();
  }

  static void toggleTravelTrackSelection({
    required String travelTrackId,
  }) {
    if (isTravelTrackSelected(travelTrackId)) {
      unselectTravelTrack(travelTrackId: travelTrackId);
    } else {
      selectTravelTrack(travelTrackId: travelTrackId);
    }
  }

  static void setTravelTrackVisible({
    required String travelTrackId,
  }) {
    TravelTrackManager.I.travelTrackMap[travelTrackId]?.isVisible = true;
    TravelTrackManager.I.notifyListeners();
  }

  static void setTravelTrackInvisible({
    required String travelTrackId,
  }) {
    TravelTrackManager.I.travelTrackMap[travelTrackId]?.isVisible = false;
    TravelTrackManager.I.notifyListeners();
  }

  static void toggleTravelTrackVisibility({
    required String travelTrackId,
  }) {
    if (isTravelTrackVisible(travelTrackId)) {
      setTravelTrackInvisible(travelTrackId: travelTrackId);
    } else {
      setTravelTrackVisible(travelTrackId: travelTrackId);
    }
  }

  static bool isTravelTrackSelected(String travelTrackId) {
    return TravelTrackManager.I.travelTrackMap[travelTrackId]?.isSelected ??
        false;
  }

  static bool isTravelTrackVisible(String travelTrackId) {
    return TravelTrackManager.I.travelTrackMap[travelTrackId]?.isVisible ??
        false;
  }
}
