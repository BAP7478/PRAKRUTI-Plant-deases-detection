import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🎨 Generating app icon...');
  
  // Create the icon widget
  final iconWidget = Container(
    width: 1024,
    height: 1024,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: LinearGradient(
        colors: [
          const Color(0xFF66BB6A), // Colors.green[400]
          const Color(0xFF4CAF50), // Colors.green[600]
        ],
      ),
    ),
    child: const Icon(
      Icons.eco_rounded,
      size: 600,
      color: Colors.white,
    ),
  );

  // Generate the icon
  await _captureWidget(iconWidget);
}

Future<void> _captureWidget(Widget widget) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  
  // Draw background circle
  final backgroundPaint = Paint()
    ..shader = const LinearGradient(
      colors: [Color(0xFF66BB6A), Color(0xFF4CAF50)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(const Rect.fromLTWH(0, 0, 1024, 1024));
  
  canvas.drawCircle(
    const Offset(512, 512),
    512,
    backgroundPaint,
  );
  
  // Draw leaf icon (simplified eco icon)
  final leafPaint = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.fill;
  
  // Create leaf path
  final leafPath = Path();
  const center = Offset(512, 512);
  const leafSize = 300.0;
  
  // Main leaf shape
  leafPath.moveTo(center.dx, center.dy - leafSize);
  leafPath.quadraticBezierTo(
    center.dx + leafSize * 0.8,
    center.dy - leafSize * 0.3,
    center.dx + leafSize * 0.7,
    center.dy + leafSize * 0.3,
  );
  leafPath.quadraticBezierTo(
    center.dx + leafSize * 0.3,
    center.dy + leafSize * 0.8,
    center.dx,
    center.dy + leafSize,
  );
  leafPath.quadraticBezierTo(
    center.dx - leafSize * 0.3,
    center.dy + leafSize * 0.8,
    center.dx - leafSize * 0.7,
    center.dy + leafSize * 0.3,
  );
  leafPath.quadraticBezierTo(
    center.dx - leafSize * 0.8,
    center.dy - leafSize * 0.3,
    center.dx,
    center.dy - leafSize,
  );
  
  canvas.drawPath(leafPath, leafPaint);
  
  // Add leaf veins
  final veinPaint = Paint()
    ..color = Colors.white.withOpacity(0.3)
    ..strokeWidth = 4
    ..style = PaintingStyle.stroke;
  
  // Central vein
  canvas.drawLine(
    Offset(center.dx, center.dy - leafSize),
    Offset(center.dx, center.dy + leafSize),
    veinPaint,
  );
  
  // Side veins
  for (int i = 1; i <= 3; i++) {
    final offset = leafSize * 0.2 * i;
    canvas.drawLine(
      Offset(center.dx, center.dy - leafSize + offset),
      Offset(center.dx + leafSize * 0.3, center.dy - leafSize + offset * 1.5),
      veinPaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - leafSize + offset),
      Offset(center.dx - leafSize * 0.3, center.dy - leafSize + offset * 1.5),
      veinPaint,
    );
  }
  
  final picture = recorder.endRecording();
  final image = await picture.toImage(1024, 1024);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  
  if (byteData == null) {
    print('❌ Failed to generate image data');
    return;
  }
  
  final bytes = byteData.buffer.asUint8List();
  
  // Create directory if it doesn't exist
  final directory = Directory('assets/icons');
  if (!await directory.exists()) {
    await directory.create(recursive: true);
  }
  
  // Save the icon
  final file = File('assets/icons/app_icon.png');
  await file.writeAsBytes(bytes);
  
  print('✅ App icon saved to assets/icons/app_icon.png');
  print('📱 Now run: flutter pub run flutter_launcher_icons');
}
