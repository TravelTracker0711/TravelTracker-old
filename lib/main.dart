import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:travel_tracker/features/travel_track/travel_track_manager.dart';
import 'package:travel_tracker/home_page.dart';

import 'features/external_asset/external_asset_manager.dart';

void main() {
  GetIt.I.registerLazySingletonAsync<ExternalAssetManager>(
    () async {
      final ExternalAssetManager eam = ExternalAssetManager();
      await eam.initAsync();
      return eam;
    },
  );
  GetIt.I.registerSingleton<TravelTrackManager>(TravelTrackManager());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<TravelTrackManager>(
          create: (_) => TravelTrackManager.I,
        ),
      ],
      child: MaterialApp(
        title: 'Travel Tracker',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          splashFactory: InkRipple.splashFactory,
        ),
        home: const HomePage(title: 'Travel Tracker Home Page'),
      ),
    );
  }
}
