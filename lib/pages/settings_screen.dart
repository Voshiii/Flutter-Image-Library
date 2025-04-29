import 'package:flutter/material.dart';
import 'package:photo_album/components/logout_popup.dart';
import 'package:photo_album/pages/theme_screen.dart';


class MySettingsPage extends StatelessWidget {
  const MySettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
      ),
      body: ListView(
        children: [
          Divider(height: 1, thickness: 1.5, color: Colors.grey,),
          ListTile(
            tileColor: Theme.of(context).colorScheme.secondary,
            title: Text(
              'Favorites (NOT IMPLEMENTED)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 19
                ),
              ),
            trailing: Icon(Icons.chevron_right),
            onTap: () {},
          ),

          Divider(height: 1, thickness: 1.5, color: Colors.grey,),
          ListTile(
            tileColor: Theme.of(context).colorScheme.secondary,
            title: Text(
              'Theme',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 19
                ),
              ),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MyThemePage(),
                ),
              );
            },
          ),

          Divider(height: 1, thickness: 1.5, color: Colors.grey,),

          ListTile(
            tileColor: Theme.of(context).colorScheme.secondary,
            title: Text(
              'Logout',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 19
                ),
              ),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) => LogoutPopup(),
              );
            },
          ),
          Divider(height: 1, thickness: 1.5, color: Colors.grey,),
        ],
      ),
    );
  }
}
