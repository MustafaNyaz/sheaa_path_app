import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:adhan/adhan.dart';
import '../providers/app_provider.dart';
import '../utils/app_colors.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  @override
  Widget build(BuildContext context) {
    final tr = context.read<AppProvider>().tr;
    final provider = context.read<AppProvider>();
    
    final qiblaAngle = Qibla(Coordinates(provider.lat, provider.lng)).direction;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text(tr('qibla_compass'), style: const TextStyle(color: AppColors.accent)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
      ),
      body: StreamBuilder<CompassEvent>(
        stream: FlutterCompass.events,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.white)));
          }
          
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.accent));
          }

          // Use `heading` (magnetic north) or `headingForCameraMode` (if available)
          // Ideally we want True North if available, but magnetic is fallback.
          final double? direction = snapshot.data?.heading;

          if (direction == null) {
             return Center(child: Text(tr('qibla_not_supported'), style: const TextStyle(color: Colors.white)));
          }

          // SMOOTHING: We can use an AnimatedRotation or Tween, but for simplicity here
          // we are just rendering directly. The stream updates fast enough usually.
          // To fix alignment: 
          // 1. Rotate the whole compass disk so "N" matches the phone's North.
          // 2. The needle should point to Qibla Angle relative to North.

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Compass Rose: Rotates against device heading so 'N' points North.
                      // E.g. if device points 90° East, compass rose should rotate -90°.
                      AnimatedRotation(
                        turns: (direction * -1) / 360,
                        duration: const Duration(milliseconds: 200), // Smooth animation
                        curve: Curves.easeOut,
                        child: SvgPicture.string(
                          _compassSvg,
                          height: 300,
                        ),
                      ),
                      
                      // Qibla Needle: Points to Qibla relative to North.
                      // If Qibla is 130°, the needle sits at 130° on the compass rose.
                      // Since the ROSE rotates, we just need to rotate the needle to Qibla angle relative to the ROSE's 0.
                      // Wait, if Rose is at -Heading, Needle should be at -Heading + Qibla.
                      AnimatedRotation(
                        turns: ((direction * -1) + qiblaAngle) / 360,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOut,
                        child: SvgPicture.string(
                          _needleSvg,
                          height: 300,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),
                  Text(
                    "${qiblaAngle.toStringAsFixed(1)}\u00B0", 
                    style: const TextStyle(color: AppColors.accent, fontSize: 40, fontWeight: FontWeight.bold)
                  ),
                  Text(tr('offset_from_north'), style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 10),
                  Text(
                    "${provider.locationName}\nYour Heading: ${direction.toStringAsFixed(0)}\u00B0", 
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 14)
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// Improved Compass SVG
const String _compassSvg = '''
<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
  <!-- Outer Ring -->
  <circle cx="50" cy="50" r="48" stroke="#D4A94A" stroke-width="1" fill="#19130D" opacity="0.9" />
  
  <!-- Ticks -->
  <line x1="50" y1="2" x2="50" y2="8" stroke="#EF4444" stroke-width="3" /> <!-- N -->
  <line x1="98" y1="50" x2="92" y2="50" stroke="white" stroke-width="2" /> <!-- E -->
  <line x1="50" y1="98" x2="50" y2="92" stroke="white" stroke-width="2" /> <!-- S -->
  <line x1="2" y1="50" x2="8" y2="50" stroke="white" stroke-width="2" /> <!-- W -->

  <!-- Letters -->
  <text x="47" y="18" fill="#EF4444" font-size="8" font-weight="bold">N</text>
  <text x="82" y="52" fill="white" font-size="8">E</text>
  <text x="47" y="88" fill="white" font-size="8">S</text>
  <text x="12" y="52" fill="white" font-size="8">W</text>
</svg>
''';

// Needle with Kaaba Icon
const String _needleSvg = '''
<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
  <!-- Arrow Body -->
  <polygon points="50,15 55,50 50,85 45,50" fill="#D4A94A" opacity="0.9" />
  
  <!-- Kaaba Box at tip -->
  <rect x="46" y="5" width="8" height="8" fill="black" stroke="#D4A94A" stroke-width="0.5" />
  <line x1="46" y1="7" x2="54" y2="7" stroke="#D4A94A" stroke-width="0.5" /> <!-- Gold band -->
  
  <!-- Center Pivot -->
  <circle cx="50" cy="50" r="4" fill="#0E0B08" stroke="#D4A94A" stroke-width="1" />
</svg>
''';



