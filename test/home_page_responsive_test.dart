import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ping_my_therapist/screens/home_page.dart';

void main() {
  testWidgets('home cards fit narrow and wide phones', (tester) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    for (final size in [const Size(320, 640), const Size(430, 932)]) {
      tester.view.physicalSize = size;
      await tester.pumpWidget(MaterialApp(home: HomePage(key: ValueKey(size))));
      await tester.pumpAndSettle();

      expect(find.text('Recommended for today'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('home header stretches and springs back after a pull', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MaterialApp(home: HomePage()));
    await tester.pumpAndSettle();

    final header = find.byKey(const ValueKey('home-header'));
    final initialHeight = tester.getSize(header).height;
    final gesture = await tester.startGesture(const Offset(170, 160));
    await gesture.moveBy(const Offset(0, 150));
    await tester.pump();

    expect(tester.getSize(header).height, greaterThan(initialHeight));

    await gesture.up();
    await tester.pumpAndSettle();
    expect(tester.getSize(header).height, closeTo(initialHeight, 1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('home mood card opens tracker and Android back returns home', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MaterialApp(home: HomePage()));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Mood Tracker'),
      280,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mood Tracker'));
    await tester.pumpAndSettle();

    var navigation = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(navigation.selectedIndex, 1);
    expect(find.text('How are you feeling right now?'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    navigation = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(navigation.selectedIndex, 0);
    expect(find.text('Recommended for today'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
