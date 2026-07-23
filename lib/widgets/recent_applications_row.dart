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
import 'package:flauncher/models/category.dart';
import 'package:flauncher/providers/settings_service.dart';
import 'package:flauncher/widgets/app_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RecentApplicationsRow extends StatelessWidget {
  final List<App> applications;

  const RecentApplicationsRow({super.key, required this.applications});

  @override
  Widget build(BuildContext context) {
    AppLocalizations localizations = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Selector<SettingsService, bool>(
          selector: (context, service) => service.showCategoryTitles,
          builder: (context, showCategoryTitles, _) {
            if (showCategoryTitles) {
              return Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 8),
                child: Text(
                  localizations.recentApplications,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(shadows: [const Shadow(color: Colors.black54, offset: Offset(1, 1), blurRadius: 8)]),
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
        SizedBox(
          height: Category.RowHeight.toDouble(),
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            scrollDirection: Axis.horizontal,
            itemCount: applications.length,
            itemBuilder: (context, index) => Padding(
              key: Key("recent_${applications[index].packageName}"),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: AppCard(
                category: null,
                application: applications[index],
                autofocus: index == 0,
                onMove: (_) {},
                onMoveEnd: () {},
              ),
            ),
          ),
        ),
      ],
    );
  }
}
