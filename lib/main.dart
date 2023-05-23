import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:travel_tracker/features/travel_track/travel_track_manager.dart';
import 'package:travel_tracker/home_page.dart';

import 'features/external_asset/external_asset_manager.dart';

void main() {
  GetIt.I.registerLazySingletonAsync<ExternalAssetManager>(
    () async {
      final ExternalAssetManager eam = ExternalAssetManager();
      await eam.init();
      return eam;
    },
  );
  GetIt.I.registerLazySingletonAsync<TravelTrackManager>(
    () async {
      final TravelTrackManager ttm = TravelTrackManager();
      await ttm.init();
      return ttm;
    },
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(context) {
    return MaterialApp(
      title: 'Travel Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        splashFactory: InkRipple.splashFactory,
      ),
      home: const HomePage(title: 'Travel Tracker Home Page'),
    );
  }
}
