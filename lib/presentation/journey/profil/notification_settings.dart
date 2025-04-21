import 'package:flutter/material.dart';
//import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:faris/presentation/widgets/icon_widget.dart';

class NotificationSettings extends StatelessWidget {
  static const keyBonplan = 'key-bonplan';
  static const keyActivity = 'key-activity';
  static const keyNewsletter = 'key-newsletter';
  static const keyUpdates = 'key-updates';

  const NotificationSettings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
    /*return SimpleSettingsTile(
      title: "Notifications",
      subtitle: "Newsletter, Mises à jours",
      leading: IconWidget(icon: Icons.notifications, color: Colors.orangeAccent),
      child: SettingsScreen(
          title: "Notifications",
          children: [
            buildBonPlan(),
            buildTontineActivity(),
            buildNewsletter(),
            buildAppUpdates(),
          ]
      ),
    );*/
  }

  /*Widget buildBonPlan(){
    return SwitchSettingsTile(
      settingKey: keyBonplan,
      title: "Bon plan pour vous",
      subtitle: "",
      leading: IconWidget(icon: Icons.card_giftcard, color: Colors.blueAccent),
    );
  }

  Widget buildTontineActivity(){
    return SwitchSettingsTile(
      settingKey: keyActivity,
      title: "Activités des tontines",
      subtitle: "",
      leading: IconWidget(icon: Icons.group, color: Colors.orangeAccent),
    );
  }

  Widget buildNewsletter(){
    return SwitchSettingsTile(
      settingKey: keyNewsletter,
      title: "Newsletter",
      subtitle: "",
      leading: IconWidget(icon: Icons.text_snippet, color: Colors.redAccent),
    );
  }

  Widget buildAppUpdates(){
    return SwitchSettingsTile(
      settingKey: keyUpdates,
      title: "Détails du compte",
      subtitle: "",
      leading: IconWidget(icon: Icons.access_time, color: Colors.greenAccent),
    );
  }*/
}
