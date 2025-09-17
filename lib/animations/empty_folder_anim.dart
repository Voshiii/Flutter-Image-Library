import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class MyEmptyFolderAnim extends StatelessWidget {
  const MyEmptyFolderAnim({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 300,
        height: 300,
        child: RiveAnimation.asset(
          'riv_assets/emptyfolder.riv',
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}