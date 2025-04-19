import 'package:flutter/material.dart';


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
          ListTile(
            title: Text(
              'Recently Deleted',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 19
                ),
              ),
            trailing: Icon(Icons.chevron_right),
            onTap: () {},
          ),

          ListTile(
            title: Text(
              'Favorites',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 19
                ),
              ),
            trailing: Icon(Icons.chevron_right),
            onTap: () {},
          ),

          ListTile(
            title: Text(
              'Logout',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 19
                ),
              ),
            trailing: Icon(Icons.chevron_right),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
