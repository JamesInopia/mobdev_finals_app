import 'package:flutter/material.dart';
import 'package:mobdev_finals_app/app/app.bottomsheets.dart';
import 'package:mobdev_finals_app/app/app.dialogs.dart';
import 'package:mobdev_finals_app/app/app.locator.dart';
import 'package:mobdev_finals_app/app/app.router.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:mobdev_finals_app/services/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storageService = LinkStorageService();
  await storageService.seedHardCodedData();
  await setupLocator();
  setupDialogUi();
  setupBottomSheetUi();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: Routes.fixedLayoutView,
      onGenerateRoute: StackedRouter().onGenerateRoute,
      navigatorKey: StackedService.navigatorKey,
      navigatorObservers: [StackedService.routeObserver],
    );
  }
}
