import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class NoWifi extends StatelessWidget {
  const NoWifi({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 250, // Set desired width
        height: 250, // Set desired height
        child: RiveAnimation.asset(
          'riv_assets/nowifi.riv',
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}