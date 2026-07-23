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

import 'package:flauncher/models/app.dart';
import 'package:flauncher/providers/apps_service.dart';
import 'package:flauncher/widgets/right_panel_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SearchPanel extends StatefulWidget {
  const SearchPanel({super.key});

  @override
  State<SearchPanel> createState() => _SearchPanelState();
}

class _SearchPanelState extends State<SearchPanel> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _textFieldFocusNode = FocusNode();
  bool _ignoreTextFieldKeyEvent = false;
  String _query = "";

  @override
  void dispose() {
    _controller.dispose();
    _textFieldFocusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // A focused TextField swallows the D-pad up/down keys, so intercept them at the scope level to
    // let the user move from the search field into the results list. Mirrors the launcher section form.
    final FocusScopeNode focusScopeNode = FocusScope.of(context);
    focusScopeNode.onKeyEvent = (node, keyEvent) {
      if (_textFieldFocusNode.hasFocus &&
          (keyEvent.logicalKey == LogicalKeyboardKey.arrowUp || keyEvent.logicalKey == LogicalKeyboardKey.arrowDown)) {
        if (!_ignoreTextFieldKeyEvent) {
          if (keyEvent.logicalKey == LogicalKeyboardKey.arrowUp) {
            _textFieldFocusNode.previousFocus();
          }
          if (keyEvent.logicalKey == LogicalKeyboardKey.arrowDown) {
            _textFieldFocusNode.nextFocus();
          }
        }

        _ignoreTextFieldKeyEvent = false;
      }
      else {
        _ignoreTextFieldKeyEvent = true;
      }

      return KeyEventResult.ignored;
    };
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations localizations = AppLocalizations.of(context)!;
    AppsService appsService = context.watch<AppsService>();

    final String query = _query.trim().toLowerCase();
    final List<App> results = appsService.applications
        .where((application) => !application.hidden && application.name.toLowerCase().contains(query))
        .toList(growable: false);

    return RightPanelDialog(
      width: 450,
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.9,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              autofocus: true,
              focusNode: _textFieldFocusNode,
              controller: _controller,
              textInputAction: TextInputAction.search,
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: localizations.searchApplications,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: results.isEmpty
                  ? Center(
                      child: Text(localizations.noApplicationsFound, style: Theme.of(context).textTheme.bodyMedium),
                    )
                  : ListView.builder(
                      itemCount: results.length,
                      itemBuilder: (context, index) => _SearchResultTile(
                        key: Key(results[index].packageName),
                        application: results[index],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchResultTile extends StatefulWidget {
  final App application;

  const _SearchResultTile({super.key, required this.application});

  @override
  State<_SearchResultTile> createState() => _SearchResultTileState();
}

class _SearchResultTileState extends State<_SearchResultTile> {
  late final Future<Uint8List> _iconFuture =
      Provider.of<AppsService>(context, listen: false).getAppIcon(widget.application.packageName);

  @override
  Widget build(BuildContext context) => TextButton(
        onPressed: () {
          context.read<AppsService>().launchApp(widget.application);
          Navigator.of(context).pop();
        },
        child: Row(
          children: [
            SizedBox(width: 32, height: 32, child: _icon()),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.application.name,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      );

  Widget _icon() => FutureBuilder<Uint8List>(
        future: _iconFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return Image.memory(snapshot.data!, fit: BoxFit.contain);
          }
          return const Icon(Icons.android, size: 24);
        },
      );
}
