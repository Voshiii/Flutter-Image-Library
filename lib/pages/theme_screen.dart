import 'package:flutter/material.dart';
import 'package:photo_album/themes/theme_provider.dart';
import 'package:provider/provider.dart';

class MyThemePage extends StatefulWidget {
  const MyThemePage({super.key});

  @override
  State<MyThemePage> createState() => _MyThemePageState();
}

class _MyThemePageState extends State<MyThemePage> {
  final List<Map<String, String>> themeOptions = [
    {"label": "Light Mode", "value": "light"},
    {"label": "Dark Mode", "value": "dark"},
    {"label": "Same as device", "value": "device"},
  ];

  var currentTheme;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  void _loadTheme() async {
    currentTheme = await Provider.of<ThemeProvider>(context, listen: false).getCurrentTheme();
    setState(() {}); // Refresh the UI after loading
  }

  @override
  Widget build(BuildContext context) {
    // final currentTheme = Provider.of<ThemeProvider>(context).getCurrentTheme();

    return Scaffold(
      appBar: AppBar(title: Text("Theme")),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(25),
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
            child: Column(
              children: List.generate(themeOptions.length * 2 - 1, (index) {
                if (index.isOdd) {
                  return Divider(height: 1, thickness: 0.5, color: Colors.grey);
                }
            
                final option = themeOptions[index ~/ 2];
                final isSelected = currentTheme == option["value"];
            
                return GestureDetector(
                  onTap: () {
                    Provider.of<ThemeProvider>(context, listen: false)
                      .setThemeData(option["value"]!);
                    _loadTheme();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    padding: const EdgeInsets.only(top: 15, bottom: 10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(option["label"]!),
                          Icon(
                            Icons.check,
                            color: isSelected ? Colors.blue : Colors.transparent,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
