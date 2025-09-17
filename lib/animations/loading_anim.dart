import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class MyLoadAnimation extends StatelessWidget {
  const MyLoadAnimation({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: 
        RiveAnimation.asset(
        'riv_assets/fillfolder.riv',
        fit: BoxFit.contain,
      ),
    );
  }
}