import 'package:flutter/material.dart';
import 'package:flutter_hbb/macpilot/dashboard.dart';
import 'package:flutter_hbb/macpilot/device_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget dashboard(
          {List<MacDeviceSummary> devices = const [],
          VoidCallback? onAdd,
          ValueChanged<MacDeviceSummary>? onConnect,
          void Function(MacDeviceSummary, MacCardAction)? onAction,
          double textScale = 1}) =>
      MaterialApp(
          builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(textScale)),
              child: child!),
          home: Scaffold(
              body: MacPilotDashboard(
                  devices: devices,
                  recent: const [],
                  onAdd: onAdd ?? () {},
                  onConnect: onConnect ?? (_) {},
                  onAction: onAction ?? (_, __) {},
                  onRefresh: () async {})));

  testWidgets('empty dashboard makes adding a Mac actionable', (tester) async {
    var added = false;
    await tester.pumpWidget(dashboard(onAdd: () => added = true));
    expect(find.text('My Macs'), findsOneWidget);
    expect(find.text('Your Mac, anywhere.'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('add-first-mac')));
    expect(added, isTrue);
  });

  testWidgets('friendly names lead cards and connect selects the correct Mac',
      (tester) async {
    String? connected;
    await tester.pumpWidget(dashboard(devices: const [
      MacDeviceSummary(id: '123456789', name: 'Home Mac mini', saved: true),
    ], onConnect: (device) => connected = device.id));
    expect(find.text('Home Mac mini'), findsOneWidget);
    expect(find.text('123456789'), findsNothing);
    expect(find.text('Status unknown'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('connect-saved-123456789')));
    expect(connected, '123456789');
  });

  testWidgets('large text stays usable and favorite action targets the card',
      (tester) async {
    tester.view.physicalSize = const Size(768, 1024);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    MacCardAction? selected;
    await tester.pumpWidget(dashboard(
        textScale: 2,
        devices: const [
          MacDeviceSummary(
              id: '123456789',
              name: 'Home Mac mini',
              saved: true,
              availability: MacAvailability.online)
        ],
        onAction: (_, action) => selected = action));
    await tester.tap(find.byTooltip('Actions for Home Mac mini'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Favorite'));
    await tester.pumpAndSettle();
    expect(selected, MacCardAction.favorite);
    expect(tester.takeException(), isNull);
  });
}
