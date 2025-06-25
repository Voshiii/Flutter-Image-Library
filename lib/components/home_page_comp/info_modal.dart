import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:photo_album/pages/image_screen.dart';


void showInfoModal(BuildContext context, Map<String, dynamic> data) {
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
                    // padding: EdgeInsets.all(10),
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

              Icon(Icons.folder, size: 150, color: Colors.blue),
              SizedBox(height: 5),
              Text(data["name"], style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              SizedBox(height: 5),

              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ImageScreen(folderName: data["name"]),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
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
                  ],
                )
              ),

              infoList(data),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget infoList(dynamic data) {
  return ListView(
    shrinkWrap: true,
    padding: EdgeInsets.zero,
    children: [
      _infoTile("Kind", "Folder"),
      _infoTile("Size", _roundValue(data["sizeBytes"])),
      _infoTile("Number of items", data["itemCount"].toString()),
      _infoTile("Created", _formatDate(data["createdAt"])),
      _infoTile("Modified", _formatDate(data["modifiedAt"])),
    ],
  );
}

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

  // return '$bts bytes ($amount)';
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
            // Text(title, style: TextStyle(fontSize: 13, color: const Color.fromARGB(156, 0, 0, 0)),),
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
