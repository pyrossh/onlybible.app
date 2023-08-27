import "package:flutter/material.dart";
import "package:only_bible_app/navigation.dart";
import "package:only_bible_app/state.dart";
import "package:only_bible_app/utils.dart";
import "package:settings_ui/settings_ui.dart";

class SettingsSheet extends StatelessWidget {
  const SettingsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsList(
      contentPadding: EdgeInsets.zero,
      platform: DevicePlatform.iOS,
      lightTheme: const SettingsThemeData(
        settingsListBackground: Color(0xFFF2F2F7),
      ),
      darkTheme: const SettingsThemeData(
        settingsListBackground: Color(0xFF141415),
      ),
      sections: [
        SettingsSection(
          title: Text(context.l.settingsTitle, style: context.theme.textTheme.headlineMedium),
          margin: const EdgeInsetsDirectional.symmetric(horizontal: 20),
          tiles: [
            SettingsTile.navigation(
              leading: const Icon(Icons.book_outlined, color: Colors.blueAccent),
              title: Text(context.l.bibleTitle),
              value: Text(bible.watch(context).name),
              onPressed: changeBible,
            ),
            SettingsTile.navigation(
              leading: const Icon(Icons.color_lens_outlined, color: Colors.green),
              title: Text(context.l.themeTitle),
              trailing: ToggleButtons(
                onPressed: (int index) {
                  darkMode.set!();
                },
                highlightColor: Colors.transparent,
                borderColor: Colors.grey,
                borderRadius: const BorderRadius.all(Radius.circular(25)),
                selectedColor: darkMode.value ? Colors.lightBlue.shade300 : Colors.yellowAccent.shade700,
                selectedBorderColor: Colors.grey,
                color: Colors.grey,
                fillColor: Colors.transparent,
                constraints: const BoxConstraints(
                  minHeight: 36.0,
                  minWidth: 50.0,
                ),
                isSelected: [!darkMode.value, darkMode.value],
                children: const [
                  Icon(Icons.light_mode),
                  Icon(Icons.dark_mode),
                ],
              ),
            ),
            SettingsTile(
              title: Text(context.l.incrementFontTitle),
              leading: Icon(Icons.font_download, color: context.theme.colorScheme.onBackground),
              trailing: IconButton(
                onPressed: () => textScale.update!(0.1),
                icon: const Icon(Icons.add_circle_outline, size: 32, color: Colors.redAccent),
              ),
            ),
            SettingsTile(
              title: Text(context.l.decrementFontTitle),
              leading: Icon(Icons.font_download, color: context.theme.colorScheme.onBackground),
              trailing: IconButton(
                onPressed: () => textScale.update!(-0.1),
                icon: const Icon(Icons.remove_circle_outline, size: 32, color: Colors.blueAccent),
              ),
            ),
            SettingsTile.switchTile(
              initialValue: fontBold.watch(context),
              leading: Icon(Icons.format_bold, color: context.theme.colorScheme.onBackground),
              title: Text(context.l.boldFontTitle),
              onToggle: (value) => fontBold.set!(),
            ),
            SettingsTile.switchTile(
              initialValue: engTitles.watch(context),
              leading: Icon(Icons.abc, color: context.theme.colorScheme.onBackground),
              title: Text(context.l.engTitles),
              onToggle: (value) => engTitles.set!(),
            ),
          ],
        ),
        SettingsSection(
          title: Text(context.l.aboutUsTitle, style: context.theme.textTheme.headlineMedium),
          margin: const EdgeInsetsDirectional.symmetric(horizontal: 20, vertical: 20),
          tiles: [
            SettingsTile.navigation(
              leading: const Icon(Icons.policy_outlined, color: Colors.brown),
              title: Text(context.l.privacyPolicyTitle),
              onPressed: showPrivacyPolicy,
            ),
            SettingsTile.navigation(
              leading: const Icon(Icons.share_outlined, color: Colors.blueAccent),
              title: Text(context.l.shareAppTitle),
              onPressed: shareAppLink,
            ),
            if (!isDesktop()) // TODO: mabe support OSx if we release in that store
              SettingsTile.navigation(
                leading: Icon(Icons.star, color: Colors.yellowAccent.shade700),
                title: Text(context.l.rateAppTitle),
                onPressed: rateApp,
              ),
            SettingsTile.navigation(
              leading: Icon(Icons.info_outline, color: context.theme.colorScheme.onBackground),
              title: Text(context.l.aboutUsTitle),
              onPressed: showAboutUs,
            ),
          ],
        ),
      ],
    );
  }
}
