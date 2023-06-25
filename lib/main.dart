import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:travel_tracker/features/asset/external_asset_manager.dart';
import 'package:travel_tracker/features/travel_track_recorder/gps_provider.dart';
import 'package:travel_tracker/features/travel_track/travel_track_manager/travel_track_manager.dart';
import 'package:travel_tracker/features/home_page/home_page.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_tracker/features/travel_track_recorder/travel_track_recorder.dart';
import 'package:travel_tracker/global.dart';

import 'features/travel_track/travel_track_manager/activate_travel_track_mananger.dart';

void main() {
  GetIt.I.registerLazySingletonAsync<ExternalAssetManager>(
    () async {
      final ExternalAssetManager eam = ExternalAssetManager();
      await eam.initAsync();
      return eam;
    },
  );
  GetIt.I.registerSingleton<TravelTrackManager>(TravelTrackManager());
  GetIt.I.registerSingleton<ActivateTravelTrackManager>(
      ActivateTravelTrackManager());
  GetIt.I.registerSingleton<GpsProvider>(GpsProvider());
  GetIt.I.registerSingleton<TravelTrackRecorder>(TravelTrackRecorder());

  runApp(const MyApp());
}

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(title: 'Travel Tracker'),
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<TravelTrackManager>(
          create: (_) => TravelTrackManager.I,
        ),
        ChangeNotifierProvider<ActivateTravelTrackManager>(
          create: (_) => ActivateTravelTrackManager.I,
        ),
        ChangeNotifierProvider<GpsProvider>(
          create: (_) => GpsProvider.I,
        ),
        ChangeNotifierProvider<TravelTrackRecorder>(
          create: (_) => TravelTrackRecorder.I,
        ),
      ],
      child: Consumer<TravelTrackRecorder>(
        builder: (context, travelTrackRecorder, child) => MaterialApp.router(
          routerConfig: _router,
          title: 'Travel Tracker',
          scaffoldMessengerKey: snackbarKey,
          theme: ThemeData(
            primarySwatch: travelTrackRecorder.isRecording
                ? Colors.yellow
                : travelTrackRecorder.isActivated
                    ? Colors.green
                    : Colors.blue,
            splashFactory: InkRipple.splashFactory,
            sliderTheme: const SliderThemeData(
              showValueIndicator: ShowValueIndicator.always,
            ),
          ),
        ),
      ),
    );
  }
}
