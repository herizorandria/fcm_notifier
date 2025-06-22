import 'package:flutter/material.dart';
class BottomNavBarClipper extends CustomClipper<Path> {

  @override
  Path getClip(Size size) {
    final double fabRadius = 38;
    final double centerX = size.width / 2;
    final double notchWidth = fabRadius * 1.8;
    final double notchDepth = fabRadius * 1.1;

    Path path = Path()
      ..lineTo(centerX - notchWidth / 2, 0)
      ..quadraticBezierTo(
        centerX,
        notchDepth,
        centerX + notchWidth / 2,
        0,
      )
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
