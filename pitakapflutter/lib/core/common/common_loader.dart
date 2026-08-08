import 'package:flutter/material.dart';

class CommonLoader extends StatelessWidget {
  const CommonLoader({
    super.key,
    this.size,
    this.strokeWidth = 2,
    this.color,
    this.center = false,
  });

  const CommonLoader.page({super.key})
      : size = null,
        strokeWidth = 4,
        color = null,
        center = true;

  final double? size;
  final double strokeWidth;
  final Color? color;
  final bool center;

  @override
  Widget build(BuildContext context) {
    Widget indicator = CircularProgressIndicator(
      strokeWidth: strokeWidth,
      color: color,
    );

    if (size != null) {
      indicator = SizedBox(width: size, height: size, child: indicator);
    }

    return center ? Center(child: indicator) : indicator;
  }
}
