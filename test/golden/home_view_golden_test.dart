import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mobdev_finals_app/app/app.locator.dart';
import 'package:mobdev_finals_app/ui/views/template/app_template.dart';

void main() {
  setUpAll(() => setupLocator());
  tearDownAll(() => locator.reset());

  testGoldens('FixedLayoutView - default state', (tester) async {
    await loadAppFonts();

    // Set device pixel ratio and size
    await tester.binding.setSurfaceSize(const Size(393, 852));
    tester.view.devicePixelRatio = 1.0; // updated API

    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(size: Size(393, 852), devicePixelRatio: 1.0),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: FixedLayoutView(), // no body/initialIndex anymore
        ),
      ),
    );

    await screenMatchesGolden(tester, 'fixed_layout_default');
  });
}
