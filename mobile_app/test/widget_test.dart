import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/main.dart';

void main() {
  testWidgets('Dashboard renders and navigates smoothly to Predict Form',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const StudentPerformanceApp(checkHealthOnLaunch: false),
    );
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('Student Performance Prediction'), findsOneWidget);
    expect(find.text('Model Fit (R²)'), findsOneWidget);
    expect(find.text('New Prediction'), findsOneWidget);

    await tester.tap(find.text('New Prediction'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 450));

    expect(find.text('Student Assessment Form'), findsOneWidget);
    expect(find.text('First Period Grade (G1)'), findsOneWidget);
  });
}
