import 'dart:convert';

class MacDeviceProfile {
  final String id;
  final String name;
  final bool favorite;
  final DateTime? lastUsed;

  const MacDeviceProfile(
      {required this.id,
      required this.name,
      this.favorite = false,
      this.lastUsed});

  MacDeviceProfile copyWith(
          {String? name, bool? favorite, DateTime? lastUsed}) =>
      MacDeviceProfile(
          id: id,
          name: name ?? this.name,
          favorite: favorite ?? this.favorite,
          lastUsed: lastUsed ?? this.lastUsed);

  Map<String, Object?> toJson() => {
        'id': id,
        'name': name,
        'favorite': favorite,
        'lastUsed': lastUsed?.toUtc().toIso8601String(),
      };

  factory MacDeviceProfile.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final name = json['name'];
    if (id is! String ||
        id.trim().isEmpty ||
        id.length > 256 ||
        name is! String ||
        name.trim().isEmpty ||
        name.length > 80 ||
        (json['favorite'] != null && json['favorite'] is! bool)) {
      throw const FormatException('Invalid Mac profile');
    }
    final used = json['lastUsed'];
    if (used != null && (used is! String || DateTime.tryParse(used) == null)) {
      throw const FormatException('Invalid usage timestamp');
    }
    return MacDeviceProfile(
        id: id,
        name: name,
        favorite: json['favorite'] == true,
        lastUsed: used == null ? null : DateTime.parse(used).toUtc());
  }
}

class MacDeviceDirectory {
  final Future<void> Function(String) _write;
  List<MacDeviceProfile> _devices;

  List<MacDeviceProfile> get devices => List.unmodifiable(_devices);

  MacDeviceDirectory._(this._devices, this._write);

  factory MacDeviceDirectory.load(
      String raw, Future<void> Function(String) write) {
    if (raw.isEmpty) return MacDeviceDirectory._([], write);
    final value = jsonDecode(raw);
    if (value is! Map<String, dynamic> ||
        value['version'] != 1 ||
        value['devices'] is! List) {
      throw const FormatException('Unsupported device directory');
    }
    final devices = <MacDeviceProfile>[];
    final ids = <String>{};
    for (final entry in value['devices']) {
      if (entry is! Map<String, dynamic>) {
        throw const FormatException('Invalid device directory');
      }
      final device = MacDeviceProfile.fromJson(entry);
      if (!ids.add(device.id)) {
        throw const FormatException('Duplicate Mac identifier');
      }
      devices.add(device);
    }
    return MacDeviceDirectory._(devices, write);
  }

  Future<void> save(List<MacDeviceProfile> devices) async {
    final snapshot = List<MacDeviceProfile>.of(devices);
    final raw = jsonEncode(
        {'version': 1, 'devices': snapshot.map((d) => d.toJson()).toList()});
    // Publish the new directory only after persistence succeeds.
    await _write(raw);
    _devices = snapshot;
  }
}

enum MacAvailability { unknown, online, offline }

enum MacCardAction { favorite, rename, remove, save, diagnostics }

class MacDeviceSummary {
  final String id;
  final String name;
  final bool saved;
  final bool favorite;
  final bool nearby;
  final MacAvailability availability;
  final DateTime? lastSeen;
  final DateTime? lastUsed;

  const MacDeviceSummary(
      {required this.id,
      required this.name,
      this.saved = false,
      this.favorite = false,
      this.nearby = false,
      this.availability = MacAvailability.unknown,
      this.lastSeen,
      this.lastUsed});
}
