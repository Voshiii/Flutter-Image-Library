import 'package:flutter/material.dart';

class ColoredBar extends StatelessWidget {
  final double value;       // current number
  final int maxValue;    // upper bound (max storage)

  const ColoredBar({
    super.key,
    required this.value,
    required this.maxValue,
  });

  @override
  Widget build(BuildContext context) {
    // clamp ratio between 0 and 1
    final ratio = (value / maxValue).clamp(0.0, 1.0);

    // pick color based on ratio
    final Color fillColor;
    if (ratio < 0.60) {
      fillColor = Colors.green;
    } else if (ratio < 0.80) {
      fillColor = Colors.orange;
    } else {
      fillColor = Colors.red;
    }

    return Container(
      height: 20,
      decoration: BoxDecoration(
        color: Colors.grey[300], // background
        borderRadius: BorderRadius.circular(3),
      ),
      child: Stack(
        children: [
          FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: ratio, // fill percentage
            child: Container(
              decoration: BoxDecoration(
                color: fillColor,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),

          // Show the amount of storage
          Center(child: Text(
            "${value.toString()} GB",
            style: TextStyle(
              color: Colors.black
            ),
          )),
        ],
      ),
    );
  }
}
