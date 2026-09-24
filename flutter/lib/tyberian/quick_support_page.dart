import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hbb/common.dart';
import 'package:flutter_hbb/models/server_model.dart';
import 'package:flutter_hbb/tyberian/distribution_config.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class TyberianQuickSupportPage extends StatefulWidget {
  const TyberianQuickSupportPage({super.key});

  @override
  State<TyberianQuickSupportPage> createState() =>
      _TyberianQuickSupportPageState();
}

class _TyberianQuickSupportPageState extends State<TyberianQuickSupportPage> {
  Timer? _idTimer;

  @override
  void initState() {
    super.initState();
    gFFI.serverModel.fetchID();
    _idTimer = Timer.periodic(
        const Duration(seconds: 1), (_) => gFFI.serverModel.fetchID());
  }

  @override
  void dispose() {
    _idTimer?.cancel();
    super.dispose();
  }

  void _copy(BuildContext context, String value) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Copied')));
  }

  Future<void> _open(String value) async {
    final uri = Uri.tryParse(value);
    if (uri != null) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<ServerModel>();
    final activeClients = model.clients.where((client) => !client.disconnected);
    final connected = activeClients.isNotEmpty;
    final ready = model.connectStatus == 1;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Center(
                    child: Text('T',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 44,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 18),
                Text(TyberianDistribution.productName,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(connected
                    ? 'Remote support session in progress'
                    : 'Ready for remote support'),
                const SizedBox(height: 28),
                _CredentialCard(
                  label: 'YOUR ID',
                  controller: model.serverId,
                  onCopy: () => _copy(context, model.serverId.text),
                ),
                const SizedBox(height: 14),
                _CredentialCard(
                  label: 'TEMPORARY PASSWORD',
                  controller: model.serverPasswd,
                  onCopy: () => _copy(context, model.serverPasswd.text),
                ),
                const SizedBox(height: 22),
                const Text(
                  'Give your ID and password to your support technician.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.circle,
                        size: 13,
                        color: connected
                            ? Colors.orange
                            : ready
                                ? Colors.green
                                : Colors.grey),
                    const SizedBox(width: 8),
                    Text(connected
                        ? 'Technician connected${activeClients.first.name.isEmpty ? '' : ': ${activeClients.first.name}'}'
                        : ready
                            ? 'Ready for connection'
                            : 'Connecting to support service…'),
                  ],
                ),
                const SizedBox(height: 18),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  children: [
                    TextButton.icon(
                      onPressed: () => _showPermissions(context, model),
                      icon: const Icon(Icons.tune),
                      label: const Text('Session permissions'),
                    ),
                    TextButton.icon(
                      onPressed: () => _showAbout(context),
                      icon: const Icon(Icons.info_outline),
                      label: const Text('About & licenses'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPermissions(BuildContext context, ServerModel model) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Incoming session permissions'),
        content: StatefulBuilder(builder: (context, setState) {
          Widget permission(String label, bool value, Future Function() toggle) {
            return SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(label),
              value: value,
              onChanged: (_) async {
                await toggle();
                setState(() {});
              },
            );
          }

          return Column(mainAxisSize: MainAxisSize.min, children: [
            permission('Keyboard and mouse', model.inputOk, model.toggleInput),
            permission('Audio', model.audioOk, model.toggleAudio),
            permission('Clipboard', model.clipboardOk, model.toggleClipboard),
            permission('File transfer', model.fileOk, model.toggleFile),
          ]);
        }),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Done')),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: TyberianDistribution.productName,
      applicationLegalese:
          '${TyberianDistribution.companyName}\nBased on RustDesk. Licensed under GNU AGPL v3.\n'
          'RustDesk copyright and third-party notices are preserved in the source distribution.',
      children: [
        const SizedBox(height: 12),
        TextButton(
            onPressed: () => _open(TyberianDistribution.sourceUrl),
            child: const Text('View corresponding source code')),
        if (TyberianDistribution.supportUrl.isNotEmpty)
          TextButton(
              onPressed: () => _open(TyberianDistribution.supportUrl),
              child: const Text('Support website')),
        if (TyberianDistribution.supportEmail.isNotEmpty)
          TextButton(
              onPressed: () =>
                  _open('mailto:${TyberianDistribution.supportEmail}'),
              child: Text(TyberianDistribution.supportEmail)),
      ],
    );
  }
}

class _CredentialCard extends StatelessWidget {
  const _CredentialCard(
      {required this.label, required this.controller, required this.onCopy});

  final String label;
  final TextEditingController controller;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  TextField(
                    controller: controller,
                    readOnly: true,
                    decoration: const InputDecoration.collapsed(hintText: ''),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600, letterSpacing: 1.2),
                  ),
                ],
              ),
            ),
            IconButton(
                tooltip: 'Copy',
                onPressed: onCopy,
                icon: const Icon(Icons.copy)),
          ]),
        ),
      );
}
