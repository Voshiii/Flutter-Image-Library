import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


void showInfoModal(BuildContext context, Map<String, dynamic> data, bool isFile) {
  // Check if the name contains .enc
  String checkItemName(){
    if(isFile) {return data["name"].substring(0, data["name"].length - 4);}
    return data["name"];
  }

  showCupertinoModalPopup(
    context: context,
    builder: (context) => Material(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground.resolveFrom(context),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),

                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    
                    child: Text(
                      "Done", 
                      style: TextStyle(
                        color: const Color.fromARGB(255, 47, 140, 216),
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
              ),

              // (Icons.folder, size: 150, color: Theme.of(context).colorScheme.primary);

              if(!isFile)...[
                Icon(Icons.folder, size: 150, color: Theme.of(context).colorScheme.primary)
              ]
              else...[
                // TODO CHANGE FROM TEMP ICON TO SPECIFIC TYPE
                Icon(Icons.file_present, size: 140, color: Theme.of(context).colorScheme.primary),
              ],
              SizedBox(height: 5),
              Text(checkItemName(), style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              // Text("Name", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              SizedBox(height: 5),

              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  children: [
                    GestureDetector(
                      // TODO Should open the item using the button
                      onTap: () {
                        // Navigator.pop(context);
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => ImageScreen(folderName: data["name"]),
                        //   ),
                        // );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: EdgeInsets.all(15),
                        margin: const EdgeInsets.symmetric(horizontal: 0),
                        child: Text("OPEN", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),),
                      ),
                    ),
                    SizedBox(height: 15),

                    Text(
                      "Information",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 15,)
                  ],
                )
              ),

              infoList(data, isFile),
            ],
          ),
        ),
      ),
    ),
  );
}

// This handles the list items
Widget infoList(dynamic data, bool isFile) {
  return ListView(
    shrinkWrap: true,
    padding: EdgeInsets.zero,
    children: [
      if(isFile)...[
        _infoTile("Kind", "File"),
      ]
      else...[
        _infoTile("Kind", "Folder"),
      ],
      _infoTile("Size", _roundValue(data["sizeBytes"])),
      if(!isFile)...[
        _infoTile("Item Count", "${data["itemCount"].toString()} items"),
      ],
      _infoTile("Created", _formatDate(data["createdAt"])),
      _infoTile("Modified", _formatDate(data["modifiedAt"])),
    ],
  );
}

// Round the bytes to two (also from bytes to MB, TB, GB, etc.)
String _roundValue(int bytes) {
  double mb = bytes / 1e6;
  String bts = bytes > 99999999 ? '' : '$bytes bytes';
  String amount;

  if (mb >= 1e6) {
    amount = '${(mb / 1e6).toStringAsFixed(2)} TB';
  } else if (mb >= 1e3) {
    amount = '${(mb / 1e3).toStringAsFixed(2)} GB';
  } else {
    amount = '${mb.toStringAsFixed(2)} MB';
  }

  return '$bts ($amount)';
}

String _formatDate(String serverDate) {
  // Parse the date string into DateTime
  DateTime dateTime = DateTime.parse(serverDate);

  // Format the DateTime
  String formattedDate = DateFormat('d MMMM yyyy, h:mm a').format(dateTime);

  return formattedDate;
}

Widget _infoTile(String title, dynamic trailing) {
  return Column(
    children: [
      Divider(height: 1, thickness: 1, color: Colors.grey),
      ListTile(
        title: Row(
          children: [
            Text(title, style: TextStyle(fontSize: 13)),
            Spacer(),
            trailing is String
                ? Text(trailing, style: TextStyle(fontSize: 13),)
                : trailing as Widget,
          ],
        ),
      ),
    ],
  );
}
