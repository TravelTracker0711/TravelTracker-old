import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:travel_tracker/home_page.dart';

import 'features/external_asset/external_asset_manager.dart';

void main() {
  GetIt.I.registerLazySingletonAsync<ExternalAssetManager>(
    () async {
      final ExternalAssetManager eam = ExternalAssetManager();
      await eam.init();
      return eam;
    },
    // instanceName: 'ExternalAssetManager',
  );
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        splashFactory: InkRipple.splashFactory,
      ),
      home: const HomePage(title: 'Flutter Demo Home Page'),
    );
  }
}