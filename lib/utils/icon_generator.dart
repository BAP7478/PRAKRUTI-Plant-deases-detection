import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

class IconGenerator {
  static Future<void> generateAppIcon() async {
    // Create a custom painter for the leaf icon
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    
    // Set the size (1024x1024)
    const size = Size(1024, 1024);
    
    // Draw background (circular green background)
    final backgroundPaint = Paint()
      ..color = const Color(0xFF4CAF50)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2,
      backgroundPaint,
    );
    
    // Draw the leaf icon (simplified version of eco_rounded)
    final leafPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    // Create a path for the leaf shape
    final leafPath = Path();
    final center = Offset(size.width / 2, size.height / 2);
    final leafSize = size.width * 0.4;
    
    // Simplified leaf shape
    leafPath.moveTo(center.dx, center.dy - leafSize / 2);
    leafPath.quadraticBezierTo(
      center.dx + leafSize / 3,
      center.dy - leafSize / 4,
      center.dx + leafSize / 2,
      center.dy,
    );
    leafPath.quadraticBezierTo(
      center.dx + leafSize / 3,
      center.dy + leafSize / 4,
      center.dx,
      center.dy + leafSize / 2,
    );
    leafPath.quadraticBezierTo(
      center.dx - leafSize / 3,
      center.dy + leafSize / 4,
      center.dx - leafSize / 2,
      center.dy,
    );
    leafPath.quadraticBezierTo(
      center.dx - leafSize / 3,
      center.dy - leafSize / 4,
      center.dx,
      center.dy - leafSize / 2,
    );
    
    canvas.drawPath(leafPath, leafPaint);
    
    // Add a stem
    final stemPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    
    canvas.drawLine(
      Offset(center.dx, center.dy + leafSize / 4),
      Offset(center.dx, center.dy + leafSize / 2),
      stemPaint,
    );
    
    // Finish recording
    final picture = recorder.endRecording();
    
    // Convert to image
    final image = await picture.toImage(1024, 1024);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();
    
    // Save the file
    final file = File('assets/icons/app_icon.png');
    await file.create(recursive: true);
    await file.writeAsBytes(bytes);
    
    print('App icon generated successfully!');
  }
}
