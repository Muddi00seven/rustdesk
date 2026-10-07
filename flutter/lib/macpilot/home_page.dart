import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../common.dart';
import '../models/peer_model.dart';
import '../models/platform_model.dart';
import '../mobile/pages/home_page.dart';
import '../mobile/pages/settings_page.dart';
import 'branding.dart';
import 'dashboard.dart';
import 'device_profile.dart';

class MacPilotHomePage extends StatefulWidget {
  const MacPilotHomePage({super.key});
  @override
  State<MacPilotHomePage> createState() => _MacPilotHomePageState();
}

class _MacPilotHomePageState extends State<MacPilotHomePage>
    with WidgetsBindingObserver {
  static const _storageKey = 'macpilot.devices.v1';
  static const _listener = 'MacPilotDashboard';
  MacDeviceDirectory? _directory;
  final _availability = <String, MacAvailability>{};
  final _lastSeen = <String, DateTime>{};
  Timer? _statusTimer;
  StreamSubscription? _links;
  bool _saving = false;
  bool _refreshing = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    try {
      _directory = MacDeviceDirectory.load(
          bind.getLocalFlutterOption(k: _storageKey),
          (value) => bind.setLocalFlutterOption(k: _storageKey, v: value));
    } catch (_) {
      _loadError =
          'Saved Macs could not be loaded. Use Advanced to connect; your saved data has been preserved.';
    }
    gFFI.recentPeersModel.addListener(_peersChanged);
    gFFI.lanPeersModel.addListener(_peersChanged);
    platformFFI.registerEventHandler('callback_query_onlines', _listener,
        (event) async {
      if (!mounted) return;
      final now = DateTime.now().toUtc();
      final knownIds = {
        ...?_directory?.devices.map((d) => d.id),
        ..._recentMacs.map((p) => p.id)
      };
      setState(() {
        for (final id in _ids(event['onlines']).where(knownIds.contains)) {
          _availability[id] = MacAvailability.online;
          _lastSeen[id] = now;
        }
        for (final id in _ids(event['offlines']).where(knownIds.contains)) {
          _availability[id] = MacAvailability.offline;
        }
      });
    });
    _links = listenUniLinks();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
    _statusTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      if (mounted &&
          ModalRoute.of(context)?.isCurrent == true &&
          WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed) {
        _refresh();
      }
    });
  }

  Iterable<String> _ids(dynamic value) => value is String
      ? value.split(',').map((id) => id.trim()).where((id) => id.isNotEmpty)
      : const [];

  void _peersChanged() {
    if (mounted) setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      setState(_availability.clear);
      _refresh();
    }
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    _links?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    gFFI.recentPeersModel.removeListener(_peersChanged);
    gFFI.lanPeersModel.removeListener(_peersChanged);
    platformFFI.unregisterEventHandler('callback_query_onlines', _listener);
    super.dispose();
  }

  List<Peer> get _recentMacs => gFFI.recentPeersModel.peers
      .where((peer) => peer.platform == 'Mac OS')
      .toList();

  Future<void> _refresh() async {
    if (!mounted || _refreshing) return;
    _refreshing = true;
    setState(_availability.clear);
    try {
      await Future.wait([bind.mainLoadRecentPeers(), bind.mainLoadLanPeers()]);
      final ids = {
        ...?_directory?.devices.map((d) => d.id),
        ..._recentMacs.map((p) => p.id)
      };
      if (ids.isNotEmpty) await bind.queryOnlines(ids: ids.take(20).toList());
    } catch (_) {
      if (mounted) {
        setState(_availability.clear);
        _notice('Could not refresh Mac availability. Pull down to retry.');
      }
    } finally {
      _refreshing = false;
    }
  }

  MacDeviceSummary _summary(String id, String name,
          {MacDeviceProfile? profile}) =>
      MacDeviceSummary(
          id: id,
          name: name,
          saved: profile != null,
          favorite: profile?.favorite ?? false,
          lastUsed: profile?.lastUsed,
          lastSeen: _lastSeen[id],
          availability: _availability[id] ?? MacAvailability.unknown,
          nearby: gFFI.lanPeersModel.peers.any((peer) => peer.id == id));

  List<MacDeviceSummary> get _devices {
    final devices = _directory?.devices.toList() ?? <MacDeviceProfile>[];
    devices.sort((a, b) {
      if (a.favorite != b.favorite) return a.favorite ? -1 : 1;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return devices.map((d) => _summary(d.id, d.name, profile: d)).toList();
  }

  List<MacDeviceSummary> get _recent {
    final profiles = {
      for (final d in _directory?.devices ?? <MacDeviceProfile>[]) d.id: d
    };
    final result = <String, MacDeviceSummary>{};
    for (final profile in profiles.values.where((d) => d.lastUsed != null)) {
      result[profile.id] = _summary(profile.id, profile.name, profile: profile);
    }
    for (final peer in _recentMacs) {
      final profile = profiles[peer.id];
      final name = profile?.name ??
          (peer.alias.isNotEmpty
              ? peer.alias
              : peer.hostname.isNotEmpty
                  ? peer.hostname
                  : 'Mac');
      result.putIfAbsent(
          peer.id, () => _summary(peer.id, name, profile: profile));
    }
    final devices = result.values.toList();
    devices.sort((a, b) =>
        (b.lastUsed ?? DateTime(1970)).compareTo(a.lastUsed ?? DateTime(1970)));
    return devices.take(6).toList();
  }

  void _notice(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<bool> _save(List<MacDeviceProfile> devices) async {
    final directory = _directory;
    if (_saving || directory == null) return false;
    setState(() => _saving = true);
    try {
      await directory.save(devices);
      if (mounted) setState(() {});
      return true;
    } catch (_) {
      _notice('Your Macs could not be saved. Please try again.');
      return false;
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _connect(MacDeviceSummary device) async {
    if (_saving) return;
    if (device.saved) {
      await _save(_directory!.devices
          .map((d) => d.id == device.id
              ? d.copyWith(lastUsed: DateTime.now().toUtc())
              : d)
          .toList());
    }
    if (!mounted) return;
    try {
      await connect(context, device.id);
    } catch (_) {
      _notice('The connection could not start. Try again or use Advanced.');
    }
  }

  Future<void> _edit({MacDeviceSummary? device}) async {
    if (_directory == null || _saving) return;
    final name = TextEditingController(text: device?.name ?? '');
    final address = TextEditingController(text: device?.id ?? '');
    final form = GlobalKey<FormState>();
    final result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(device == null ? 'Add Mac' : 'Rename Mac'),
              content: SizedBox(
                  width: 420,
                  child: Form(
                      key: form,
                      child: SingleChildScrollView(
                          child:
                              Column(mainAxisSize: MainAxisSize.min, children: [
                        TextFormField(
                            controller: name,
                            autofocus: true,
                            maxLength: 80,
                            textCapitalization: TextCapitalization.words,
                            decoration: const InputDecoration(
                                labelText: 'Mac name',
                                hintText: 'Home Mac mini'),
                            validator: (value) =>
                                value == null || value.trim().isEmpty
                                    ? 'Enter a name for your Mac'
                                    : null),
                        if (device == null) ...[
                          const SizedBox(height: 16),
                          const Text(
                              'Enter the identifier shown on your Mac, or its local network address.'),
                          const SizedBox(height: 12),
                          TextFormField(
                              controller: address,
                              maxLength: 256,
                              autocorrect: false,
                              enableSuggestions: false,
                              keyboardType: TextInputType.url,
                              decoration: const InputDecoration(
                                  labelText: 'Connection address'),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Enter a connection address';
                                }
                                if (RegExp(r'://|[?&#\r\n]').hasMatch(value)) {
                                  return 'Enter only an identifier or host address, without a link or credentials';
                                }
                                return null;
                              }),
                        ],
                      ])))),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel')),
                TextButton(
                    onPressed: () {
                      if (form.currentState?.validate() == true) {
                        Navigator.pop(context, true);
                      }
                    },
                    child: const Text('Save')),
              ],
            ));
    final enteredName = name.text.trim();
    final id = address.text.trim().replaceAll(' ', '');
    name.dispose();
    address.dispose();
    if (result != true || !mounted) return;
    final devices = _directory!.devices.toList();
    final index = devices.indexWhere((d) => d.id == id);
    if (index < 0) {
      devices.add(MacDeviceProfile(id: id, name: enteredName));
    } else {
      devices[index] = devices[index].copyWith(name: enteredName);
    }
    if (await _save(devices)) _refresh();
  }

  Future<void> _action(MacDeviceSummary device, MacCardAction action) async {
    if (action == MacCardAction.diagnostics) {
      await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
                title: Text('Technical info · ${device.name}'),
                content: SingleChildScrollView(
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      const Text('Connection identifier'),
                      SelectableText(device.id),
                      const SizedBox(height: 16),
                      Text('Availability: ${device.availability.name}'),
                      Text(
                          'LAN discovery: ${device.nearby ? "Seen nearby" : "Not known"}'),
                      const SizedBox(height: 16),
                      const Text(
                          'The connection route, latency and display statistics are available during a session.'),
                    ])),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Done'))
                ],
              ));
      return;
    }
    if (_directory == null || _saving) return;
    if (action == MacCardAction.rename) {
      await _edit(device: device);
      return;
    }
    final devices = _directory!.devices.toList();
    if (action == MacCardAction.remove) {
      final remove = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
                title: Text('Remove ${device.name}?'),
                content: const Text(
                    'This removes the Mac from My Macs. It does not revoke access on the Mac.'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel')),
                  TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Remove')),
                ],
              ));
      if (remove != true || !mounted) return;
      devices.removeWhere((d) => d.id == device.id);
    } else if (action == MacCardAction.save) {
      if (!devices.any((d) => d.id == device.id)) {
        devices.add(MacDeviceProfile(id: device.id, name: device.name));
      }
    } else if (action == MacCardAction.favorite) {
      final index = devices.indexWhere((d) => d.id == device.id);
      if (index < 0) return;
      devices[index] =
          devices[index].copyWith(favorite: !devices[index].favorite);
    }
    await _save(devices);
  }

  Future<void> _openAdvanced() async {
    // The original connection page owns its own deep-link subscription.
    await _links?.cancel();
    _links = null;
    if (!mounted) return;
    try {
      await Navigator.push(
          context, MaterialPageRoute(builder: (_) => HomePage()));
    } finally {
      if (mounted) _links = listenUniLinks();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Row(mainAxisSize: MainAxisSize.min, children: [
            ExcludeSemantics(
                child: SvgPicture.asset(MacPilotBrand.logo,
                    width: 28, height: 28)),
            const SizedBox(width: 10),
            const Flexible(
                child: Text(MacPilotBrand.productName,
                    maxLines: 1, overflow: TextOverflow.ellipsis)),
          ]),
          actions: [
            IconButton(
                tooltip: 'Refresh Macs',
                onPressed: _refresh,
                icon: const Icon(Icons.refresh_rounded)),
            IconButton(
                tooltip: 'Settings',
                icon: const Icon(Icons.tune_rounded),
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => Scaffold(
                            appBar: AppBar(title: const Text('Settings')),
                            body: SettingsPage())))),
            PopupMenuButton<String>(
                tooltip: 'More',
                onSelected: (_) => _openAdvanced(),
                itemBuilder: (_) => [
                      const PopupMenuItem(
                          value: 'advanced', child: Text('Advanced'))
                    ]),
          ],
        ),
        body: SafeArea(
            child: MacPilotDashboard(
                devices: _devices,
                recent: _recent,
                onAdd: _directory == null ? null : () => _edit(),
                onConnect: _connect,
                onAction: _action,
                onRefresh: _refresh,
                saving: _saving,
                error: _loadError)),
      );
}
