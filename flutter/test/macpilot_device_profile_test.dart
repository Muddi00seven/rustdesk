import 'dart:convert';
import 'package:flutter_hbb/macpilot/device_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('saved Mac preferences survive reload and never serialize credentials',
      () async {
    var saved = '';
    final directory = MacDeviceDirectory.load('', (raw) async => saved = raw);
    await directory.save([
      MacDeviceProfile(
          id: '123456789',
          name: 'Home Mac mini',
          favorite: true,
          lastUsed: DateTime.utc(2026, 10, 7))
    ]);
    final reloaded = MacDeviceDirectory.load(saved, (_) async {});
    expect(reloaded.devices.single.name, 'Home Mac mini');
    expect(reloaded.devices.single.favorite, isTrue);
    expect(reloaded.devices.single.lastUsed, DateTime.utc(2026, 10, 7));
    final json = jsonDecode(saved)['devices'].single as Map;
    expect(json.keys, unorderedEquals(['id', 'name', 'favorite', 'lastUsed']));
  });

  test('failed persistence keeps the previously saved Macs', () async {
    final directory = MacDeviceDirectory.load(
        '', (_) async => throw StateError('unavailable'));
    await expectLater(
        directory.save([const MacDeviceProfile(id: '123456789', name: 'Mac')]),
        throwsStateError);
    expect(directory.devices, isEmpty);
  });

  test('unsupported or corrupt data is refused rather than overwritten', () {
    expect(
        () =>
            MacDeviceDirectory.load('{"version":2,"devices":[]}', (_) async {}),
        throwsFormatException);
    expect(
        () => MacDeviceDirectory.load(
            '{"version":1,"devices":[{"id":"123","name":""}]}', (_) async {}),
        throwsFormatException);
  });
}
