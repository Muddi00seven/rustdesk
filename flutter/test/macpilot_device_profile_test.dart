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

  test('replacing a local address with Mac ID preserves saved preferences', () async {
    var saved = '';
    final directory = MacDeviceDirectory.load('', (raw) async => saved = raw);
    final local = MacDeviceProfile(id: '192.168.1.5', name: 'MacBook',
        favorite: true, lastUsed: DateTime.utc(2026, 10, 8));
    await directory.save([local.copyWith(id: '123456789')]);
    final mac = MacDeviceDirectory.load(saved, (_) async {}).devices.single;
    expect(mac.id, '123456789');
    expect(mac.name, 'MacBook');
    expect(mac.favorite, isTrue);
    expect(mac.lastUsed, local.lastUsed);
  });
}
