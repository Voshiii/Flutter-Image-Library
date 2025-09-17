// ! DEPRICATED
// ! CAN BE USED FOR FUTURE CONTENT

// import 'package:flutter/material.dart';
// import 'package:photo_album/services/delete_service.dart';
// import 'package:photo_album/services/fetch_service.dart';

// class MyImagePopUp extends StatefulWidget {
//   final String folderName;
//   final String img;
//   // final Uint8List img;
//   final String imgName;
//   final Future<void> Function()? reloadImages;

//   const MyImagePopUp({
//     super.key, 
//     required this.folderName,
//     required this.img,
//     required this.imgName,
//     required this.reloadImages,
//   }); // Constructor

//   @override
//   MyDeleteDialogState createState() => MyDeleteDialogState();
// }

// class MyDeleteDialogState extends State<MyImagePopUp> {
//   final DeleteService _deleteService = DeleteService();
//   dynamic data;
//   bool _isdeleting = false;
//   final FetchService fetchService = FetchService();

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: Center(
//         child: Column(
//           children: [
//             // Image.memory(widget.img),
//             Image.network(widget.img),
//         ]),
        
//       ),
//       actions: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               decoration: BoxDecoration(
//                 color: _isdeleting ? Colors.grey  : Colors.red,
//                 borderRadius: BorderRadius.circular(10),  
//               ),
//               child: TextButton(
//                 onPressed: () async {
//                   // Code to delete image
//                   if(!_isdeleting){
//                     setState(() {
//                       _isdeleting = true;
//                     });

//                     await _deleteService.deleteFile(widget.folderName, widget.imgName);
//                     await widget.reloadImages?.call();
//                     await Future.delayed(Duration(seconds: 1));
//                     setState(() {
//                       _isdeleting = false;
//                     });
//                     if(!context.mounted) return;
//                     Navigator.of(context).pop();
//                   }
//                 },
//                 child: Text(
//                   "Delete",
//                   style: TextStyle(color: _isdeleting ? const Color.fromARGB(255, 55, 55, 55) : Colors.black, fontSize: 15),
//                 ),
//               ),
//             ),

//             SizedBox(width: 20,),

//             Container(
//               decoration: BoxDecoration(
//                 color: _isdeleting ? Colors.grey : Colors.green,
//                 borderRadius: BorderRadius.circular(10),  
//               ),
//               child: TextButton(
//                 onPressed: () async {
//                   if (_isdeleting){
//                     return;
//                   }

//                   // Save to gallery
//                   // fetchService.downloadAndSaveImage(widget.img);

//                 },
//                 child: Text(
//                   "Save",
//                   style: TextStyle(color: _isdeleting ? const Color.fromARGB(255, 55, 55, 55) : Colors.black, fontSize: 15),
//                 ),
//               ),
//             ),
            
//             SizedBox(width: 20,),

//             Container(
//               decoration: BoxDecoration(
//                 color: const Color.fromARGB(255, 214, 214, 214),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: TextButton(
//                 onPressed: () {
//                   if (_isdeleting) return;
//                   Navigator.pop(context);
//                 }, 
//                 child: Text(
//                   "Cancel",
//                   style: TextStyle(color: _isdeleting ? const Color.fromARGB(255, 55, 55, 55) : Colors.black, fontSize: 15),
//                 )
//               ),
//             ),
//           ],
//         )
//       ],
//     );
//   }
// }
