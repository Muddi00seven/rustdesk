import 'package:flutter/material.dart';
import 'device_profile.dart';

class MacPilotDashboard extends StatelessWidget {
  final List<MacDeviceSummary> devices;
  final List<MacDeviceSummary> recent;
  final VoidCallback? onAdd;
  final ValueChanged<MacDeviceSummary> onConnect;
  final void Function(MacDeviceSummary, MacCardAction) onAction;
  final Future<void> Function() onRefresh;
  final bool saving;
  final String? error;

  const MacPilotDashboard(
      {super.key,
      required this.devices,
      required this.recent,
      required this.onAdd,
      required this.onConnect,
      required this.onAction,
      required this.onRefresh,
      this.saving = false,
      this.error});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: LayoutBuilder(builder: (context, constraints) {
        final width = constraints.maxWidth;
        final inset = width >= 700 ? 32.0 : 20.0;
        final contentWidth = width - inset * 2;
        final columns = contentWidth >= 1000
            ? 3
            : contentWidth >= 600
                ? 2
                : 1;
        final cardWidth = (contentWidth - 16 * (columns - 1)) / columns;
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(inset, 24, inset, 40),
          children: [
            if (error != null)
              Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Semantics(
                      liveRegion: true,
                      child: Text(error!,
                          style: TextStyle(color: theme.colorScheme.error)))),
            Row(children: [
              Expanded(
                  child: Text('My Macs',
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w600))),
              IconButton(
                  onPressed: saving ? null : onAdd,
                  tooltip: 'Add Mac',
                  icon: const Icon(Icons.add_rounded),
                  constraints:
                      const BoxConstraints(minWidth: 48, minHeight: 48)),
            ]),
            const SizedBox(height: 16),
            if (devices.isEmpty)
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(20)),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.computer_rounded, size: 42),
                      const SizedBox(height: 20),
                      Text('Your Mac, anywhere.',
                          style: theme.textTheme.headlineSmall),
                      const SizedBox(height: 8),
                      const Text(
                          'Save your Mac once. Connect when you need it.'),
                      const SizedBox(height: 24),
                      OutlinedButton.icon(
                          key: const ValueKey('add-first-mac'),
                          onPressed: saving ? null : onAdd,
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Add Mac')),
                    ]),
              )
            else
              Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: devices
                      .map((device) => SizedBox(
                          width: cardWidth, child: _card(context, device)))
                      .toList()),
            const SizedBox(height: 32),
            Text('Recent',
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            if (recent.isEmpty)
              const Text('Your recently used Macs will appear here.')
            else
              Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: recent
                      .map((device) => SizedBox(
                          width: cardWidth,
                          child: _card(context, device, recent: true)))
                      .toList()),
          ],
        );
      }),
    );
  }

  Widget _card(BuildContext context, MacDeviceSummary device,
      {bool recent = false}) {
    final theme = Theme.of(context);
    final label = switch (device.availability) {
      MacAvailability.online => 'Online',
      MacAvailability.offline => 'Offline',
      MacAvailability.unknown => 'Status unknown',
    };
    final statusColor = device.availability == MacAvailability.online
        ? const Color(0xff267a4a)
        : theme.disabledColor;
    return Card(
      key: ValueKey('${recent ? "recent" : "saved"}-${device.id}'),
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: theme.dividerColor.withOpacity(0.25))),
      child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Padding(
                  padding: EdgeInsets.only(top: 8, right: 12),
                  child: Icon(Icons.computer_rounded, size: 28)),
              Expanded(
                  child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(device.name,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600)))),
              PopupMenuButton<MacCardAction>(
                tooltip: 'Actions for ${device.name}',
                enabled: !saving,
                onSelected: (action) => onAction(device, action),
                itemBuilder: (_) => [
                  if (!device.saved)
                    const PopupMenuItem(
                        value: MacCardAction.save,
                        child: Text('Add to My Macs')),
                  if (device.saved) ...[
                    PopupMenuItem(
                        value: MacCardAction.favorite,
                        child: Text(
                            device.favorite ? 'Remove favorite' : 'Favorite')),
                    const PopupMenuItem(
                        value: MacCardAction.rename, child: Text('Edit Mac')),
                    const PopupMenuItem(
                        value: MacCardAction.remove, child: Text('Remove Mac')),
                  ],
                  if (!usesDirectMacAddress(device.id))
                    const PopupMenuItem(
                        value: MacCardAction.internetRelay,
                        child: Text('Connect via relay')),
                  const PopupMenuItem(
                      value: MacCardAction.diagnostics,
                      child: Text('Technical info')),
                ],
                icon: const Icon(Icons.more_horiz_rounded),
              ),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                      color: statusColor, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
              if (device.favorite)
                Semantics(
                    label: 'Favorite',
                    child: const Icon(Icons.star_rounded, size: 18)),
            ]),
            if (device.nearby)
              const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text('Nearby · LAN discovered')),
            if (usesDirectMacAddress(device.id))
              const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text('Direct address · use Mac ID for internet access')),
            if (device.lastSeen != null &&
                device.availability != MacAvailability.online)
              Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                      'Last seen ${MaterialLocalizations.of(context).formatShortDate(device.lastSeen!.toLocal())}')),
            if (device.lastUsed != null)
              Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                      'Last used ${MaterialLocalizations.of(context).formatShortDate(device.lastUsed!.toLocal())}')),
            const SizedBox(height: 16),
            Semantics(
                label: 'Connect to ${device.name}',
                child: OutlinedButton(
                    key: ValueKey(
                        'connect-${recent ? "recent" : "saved"}-${device.id}'),
                    onPressed: saving ? null : () => onConnect(device),
                    style: OutlinedButton.styleFrom(
                        minimumSize: const Size(100, 44)),
                    child: const Text('Connect'))),
          ])),
    );
  }
}
