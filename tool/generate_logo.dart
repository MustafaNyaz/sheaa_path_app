import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  const int size = 1024;
  final image = img.Image(width: size, height: size);

  // Colors
  final bg = img.ColorRgb8(15, 23, 42); // #0F172A
  final gold = img.ColorRgb8(251, 191, 36); // #FBBF24

  // Fill Background
  img.fill(image, color: bg);

  // Draw Crescent
  const center = size ~/ 2;
  const radius = size * 0.35;
  
  // Outer Circle (Gold)
  img.fillCircle(image, x: center, y: center, radius: radius.toInt(), color: gold);

  // Inner Circle (Background color, offset to create crescent)
  final offsetX = (size * 0.1).toInt();
  final offsetY = -(size * 0.05).toInt();
  final innerRadius = (radius * 0.85).toInt();
  
  img.fillCircle(image, x: center + offsetX, y: center + offsetY, radius: innerRadius, color: bg);

  // Draw Star (Simple Diamond Shape)
  final starX = center + (size * 0.15).toInt();
  final starY = center - (size * 0.2).toInt();
  final starSize = (size * 0.15).toInt();

  // Draw simple cross star
  // Vertical
  // img.drawLine(image, x1: starX, y1: starY - starSize, x2: starX, y2: starY + starSize, color: gold, thickness: 20);
  // Horizontal
  // img.drawLine(image, x1: starX - starSize, y1: starY, x2: starX + starSize, y2: starY, color: gold, thickness: 20);
  
  // Draw a circle for star for simplicity and smoothness
  img.fillCircle(image, x: starX, y: starY, radius: (starSize * 0.4).toInt(), color: gold);

  // Save to file
  final png = img.encodePng(image);
  File('assets/icon.png').writeAsBytesSync(png);
  print('Logo generated at assets/icon.png');
}
