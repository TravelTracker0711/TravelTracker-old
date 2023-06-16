import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_tracker/features/travel_track_recorder/travel_track_recorder.dart';

class HomePageFloatingActionButton extends StatelessWidget {
  const HomePageFloatingActionButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TravelTrackRecorder travelTrackRecorder =
        context.watch<TravelTrackRecorder>();
    return SizedBox(
      width: 80 + 48 * 2,
      height: 56 * 2,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: 80,
              height: 80,
              child: FittedBox(
                child: FloatingActionButton(
                  onPressed: () {
                    if (!travelTrackRecorder.isRecording) {
                      travelTrackRecorder.startRecordingAsync();
                      return;
                    } else {
                      travelTrackRecorder.pauseRecording();
                      return;
                    }
                  },
                  child: !travelTrackRecorder.isRecording
                      ? const Icon(Icons.play_arrow)
                      : const Icon(Icons.pause),
                ),
              ),
            ),
          ),
          if (travelTrackRecorder.isActivated)
            Align(
              alignment: Alignment.bottomLeft,
              child: FloatingActionButton(
                mini: true,
                onPressed: () {
                  travelTrackRecorder.stopRecording();
                },
                child: const Icon(Icons.stop),
              ),
            ),
        ],
      ),
    );
  }
}
