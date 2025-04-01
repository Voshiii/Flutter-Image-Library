import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

// class MyEmptyFolderAnim extends StatefulWidget {
//   const MyEmptyFolderAnim({super.key});

//   @override
//   State<MyEmptyFolderAnim> createState() => _MyEmptyFolderAnimState();
// }

// class _MyEmptyFolderAnimState extends State<MyEmptyFolderAnim> {
//   late RiveAnimationController _controller;

//   @override
//   void initState() {
//     super.initState();
//     _controller = SimpleAnimation('emptyfolder', autoplay: true); // Replace 'AnimationName' with the actual animation name in the Rive file.
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: RiveAnimation.asset(
//         'riv_assets/emptyfolder.riv',
//         fit: BoxFit.contain,
//         controllers: [_controller],
//       ),
//     );
//   }
// }

class MyEmptyFolderAnim extends StatelessWidget {
  const MyEmptyFolderAnim({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 300, // Set desired width
        height: 300, // Set desired height
        child: RiveAnimation.asset(
          'riv_assets/emptyfolder.riv',
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}