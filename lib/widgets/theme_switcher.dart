import 'package:flutter/material.dart';
import 'package:irish_bus_refresh/providers/theme_provider.dart';
import 'package:provider/provider.dart';

import '../models/app_theme.dart';

class ThemeSwitcher extends StatelessWidget {
  var _containerWidth = 450;

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (c, themeProvider, _) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            for(AppTheme theme in appThemes)
              GestureDetector(
                onTap: (theme.mode == themeProvider.selectedThemeMode) ? null : () => themeProvider.setSelectedThemeMode(theme.mode),
                child: AnimatedContainer(
                  height: 80,
                  duration: const Duration(milliseconds: 200),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Theme.of(context).cardColor.withOpacity(0.5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: Icon(theme.icon),
                          ),
                          Text(
                            theme.title,
                            style: Theme.of(context).textTheme.subtitle2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
          ]
        ),
      );
  }
}

List<AppTheme> appThemes = [
  AppTheme(
    mode: ThemeMode.light,
    title: 'Light',
    icon: Icons.brightness_5_rounded,
  ),
  AppTheme(
    mode: ThemeMode.dark,
    title: 'Dark',
    icon: Icons.brightness_2_rounded,
  ),
  AppTheme(
    mode: ThemeMode.system,
    title: 'Auto',
    icon: Icons.brightness_4_rounded,
  ),
];