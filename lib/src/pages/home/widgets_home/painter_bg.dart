import 'package:flutter/material.dart';
import 'package:autoparnet_cotiza/config/sng_manager.dart';
import 'package:autoparnet_cotiza/vars/globals.dart';

class PainterBG extends CustomPainter {

  final globals = getSngOf<Globals>();
  
  @override
  void paint(Canvas canvas, Size size) {
    
    Paint paint = Paint();
    
    paint.color = globals.colors['blackLigt'];
    Path path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height * 0.72);
    path.lineTo(0, size.height * 0.85);
    path.close();

    return canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;

}