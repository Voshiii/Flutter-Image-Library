import 'package:flutter/material.dart';
import 'package:photo_album/components/settings_page_comp/logout_popup.dart';
import 'package:photo_album/pages/account_screen.dart';
import 'package:photo_album/pages/theme_screen.dart';


class MySettingsPage extends StatelessWidget {
  const MySettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    appBar: AppBar(
      title: Text("Settings"),
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Material(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.grey, width: 2),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // _buildTile(context, title: 'Favorites (NOT IMPLEMENTED)', onTap: () {}),
            _buildDivider(),
            // TODO: Implement or rename for user to login with faceID or passcode
            _buildTile(context, title: 'Account', onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => UserAccount()),
              );
            }),

            _buildDivider(),
            _buildTile(context, title: 'Theme', onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => MyThemePage()),
              );
            }),

            _buildDivider(),
            _buildTile(context, title: 'Permissions', onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => Placeholder()),
              );
            }),

            _buildDivider(),
            _buildTile(context, title: 'Logout', textColor: Colors.red, onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) => LogoutPopup(),
              );
            }),
          ],
        ),
      ),
    ),
  );

  }
}

Widget _buildTile(BuildContext context, {
  required String title,
  required VoidCallback onTap,
  Color? textColor,
}) {
  return ListTile(
    tileColor: Theme.of(context).colorScheme.secondary,
    title: Text(
      title,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 19,
        color: textColor ?? Theme.of(context).textTheme.bodyLarge!.color,
      ),
    ),
    trailing: Icon(Icons.chevron_right),
    onTap: onTap,
  );
}

Widget _buildDivider() => Divider(height: 1, thickness: 1.5, color: Colors.grey);

