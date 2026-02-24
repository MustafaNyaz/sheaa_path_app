import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';

class PrayerCard extends StatelessWidget {
  final String title;
  final String time;
  final String subText;
  final Color color;
  final IconData icon;
  final bool isGolden;
  final Widget? child;

  const PrayerCard({
    super.key,
    required this.title,
    required this.time,
    required this.subText,
    required this.color,
    required this.icon,
    this.isGolden = false,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: isGolden 
            ? Border.all(color: color.withOpacity(0.6), width: 1.0) 
            : Border.all(color: Colors.white.withOpacity(0.08), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3), 
            blurRadius: 25, 
            offset: const Offset(0, 10)
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {}, // For subtle splash
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(icon, color: color, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        title, 
                        style: TextStyle(
                          color: isGolden ? color : Colors.white, 
                          fontSize: 18, 
                          fontWeight: FontWeight.bold
                        )
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      time, 
                      style: GoogleFonts.cairo(
                        fontSize: 40, 
                        fontWeight: FontWeight.bold, 
                        color: Colors.white,
                        height: 1
                      )
                    ),
                    Flexible(
                      child: Container(
                         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                         // Removed background color decoration for transparent look
                         child: Text(
                          subText, 
                          textAlign: TextAlign.end,
                          style: TextStyle(fontSize: 12, color: Colors.grey[400])
                        ),
                      ),
                    ),
                  ],
                ),
                if (child != null) ...[
                  const SizedBox(height: 24),
                  child!,
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}



