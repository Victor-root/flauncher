/*
 * FLauncher
 * Copyright (C) 2021  Étienne Fesser
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

import 'package:flauncher/providers/apps_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DefaultLauncherPanelPage extends StatefulWidget {
  static const String routeName = "default_launcher_panel";

  const DefaultLauncherPanelPage({super.key});

  @override
  State<DefaultLauncherPanelPage> createState() => _DefaultLauncherPanelPageState();
}

class _DefaultLauncherPanelPageState extends State<DefaultLauncherPanelPage> {
  bool? _isDefault;
  String _launcherPackage = "";
  bool _shizukuAvailable = false;
  bool _shizukuHasPermission = false;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    AppsService appsService = context.read<AppsService>();
    bool isDefault = await appsService.isDefaultLauncher();
    String launcherPackage = isDefault ? "" : await appsService.getDefaultLauncherPackage();
    bool shizukuAvailable = await appsService.shizukuAvailable();
    bool shizukuHasPermission = shizukuAvailable && await appsService.shizukuHasPermission();

    if (mounted) {
      setState(() {
        _isDefault = isDefault;
        _launcherPackage = launcherPackage;
        _shizukuAvailable = shizukuAvailable;
        _shizukuHasPermission = shizukuHasPermission;
      });
    }
  }

  Future<void> _setDefaultViaShizuku() async {
    AppLocalizations localizations = AppLocalizations.of(context)!;
    await context.read<AppsService>().disableLauncherViaShizuku(_launcherPackage);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(localizations.shizukuDone)));
    await _refresh();
  }

  Future<void> _requestShizukuPermission() async {
    await context.read<AppsService>().shizukuRequestPermission();
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations localizations = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(localizations.defaultLauncher, style: Theme.of(context).textTheme.titleLarge),
        const Divider(),
        Expanded(
          child: SingleChildScrollView(child: _content(context, localizations)),
        ),
      ],
    );
  }

  Widget _content(BuildContext context, AppLocalizations localizations) {
    if (_isDefault == null) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_isDefault!) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.greenAccent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(localizations.defaultLauncherActive, style: Theme.of(context).textTheme.bodyMedium),
              ),
            ],
          ),
          const Divider(),
          _checkAgainButton(localizations, autofocus: true),
        ],
      );
    }

    final bool hasPackage = _launcherPackage.isNotEmpty && _launcherPackage != "android";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(localizations.defaultLauncherInactive, style: Theme.of(context).textTheme.bodyMedium),
        if (_shizukuHasPermission)
          TextButton(
            autofocus: true,
            onPressed: hasPackage ? _setDefaultViaShizuku : null,
            child: Row(
              children: [
                const Icon(Icons.bolt),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(localizations.defaultLauncherSetWithShizuku, style: Theme.of(context).textTheme.bodyMedium),
                ),
              ],
            ),
          )
        else if (_shizukuAvailable)
          TextButton(
            autofocus: true,
            onPressed: _requestShizukuPermission,
            child: Row(
              children: [
                const Icon(Icons.bolt),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(localizations.grantShizukuPermission, style: Theme.of(context).textTheme.bodyMedium),
                ),
              ],
            ),
          ),
        const SizedBox(height: 12),
        Text(localizations.defaultLauncherInstructions, style: Theme.of(context).textTheme.bodySmall),
        if (hasPackage) ...[
          const SizedBox(height: 8),
          _commandBox("adb shell pm disable-user --user 0 $_launcherPackage"),
          const SizedBox(height: 12),
          Text(localizations.defaultLauncherReenableInstructions, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
          _commandBox("adb shell pm enable $_launcherPackage"),
        ],
        const Divider(),
        TextButton(
          autofocus: !_shizukuAvailable,
          onPressed: () => context.read<AppsService>().openHomeSettings(),
          child: Row(
            children: [
              const Icon(Icons.home_outlined),
              const SizedBox(width: 8),
              Expanded(
                child: Text(localizations.defaultLauncherOpenSettings, style: Theme.of(context).textTheme.bodyMedium),
              ),
            ],
          ),
        ),
        _checkAgainButton(localizations),
      ],
    );
  }

  Widget _checkAgainButton(AppLocalizations localizations, {bool autofocus = false}) => TextButton(
        autofocus: autofocus,
        onPressed: _refresh,
        child: Row(
          children: [
            const Icon(Icons.refresh),
            const SizedBox(width: 8),
            Expanded(
              child: Text(localizations.checkAgain, style: Theme.of(context).textTheme.bodyMedium),
            ),
          ],
        ),
      );

  Widget _commandBox(String command) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(4),
        ),
        child: SelectableText(
          command,
          style: Theme.of(context).textTheme.bodySmall!.copyWith(fontFamily: "monospace"),
        ),
      );
}
