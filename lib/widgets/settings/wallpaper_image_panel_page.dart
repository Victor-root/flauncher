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

import 'package:flauncher/providers/wallpaper_service.dart';
import 'package:flauncher/widgets/ensure_visible.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WallpaperImagePanelPage extends StatelessWidget {
  static const String routeName = "wallpaper_image_panel";

  static const List<String> _wallpapers = [
    "assets/abstract.png",
    "assets/animal.png",
    "assets/architecture.png",
    "assets/colorful.png",
    "assets/landscape.png",
    "assets/minimal.png",
    "assets/plant.png",
    "assets/space.png",
    "assets/technology.png",
    "assets/texture.png",
  ];

  const WallpaperImagePanelPage({super.key});

  @override
  Widget build(BuildContext context) {
    AppLocalizations localizations = AppLocalizations.of(context)!;

    return Column(
      children: [
        Text(localizations.builtInWallpapers, style: Theme.of(context).textTheme.titleLarge),
        const Divider(),
        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            childAspectRatio: 16 / 9,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: _wallpapers
                .map((asset) => EnsureVisible(alignment: 0.5, child: _wallpaperCard(asset)))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _wallpaperCard(String asset) => Focus(
        key: Key("wallpaper-$asset"),
        canRequestFocus: false,
        child: Builder(
          builder: (context) => Card(
            clipBehavior: Clip.antiAlias,
            shape: Focus.of(context).hasFocus
                ? RoundedRectangleBorder(
                    side: const BorderSide(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.circular(4),
                  )
                : null,
            child: InkWell(
              autofocus: asset == _wallpapers.first,
              onTap: () {
                context.read<WallpaperService>().setWallpaperFromAsset(asset);
                Navigator.of(context).pop();
              },
              child: Image.asset(asset, fit: BoxFit.cover),
            ),
          ),
        ),
      );
}
