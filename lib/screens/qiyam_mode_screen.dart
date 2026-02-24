import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/dnd_service.dart';
import '../utils/app_colors.dart';

class QiyamModeScreen extends StatefulWidget {
  const QiyamModeScreen({super.key});

  @override
  State<QiyamModeScreen> createState() => _QiyamModeScreenState();
}

class _QiyamModeScreenState extends State<QiyamModeScreen> {
  int _counter = 0;
  bool _showAdhkar = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().setQiyamMode(true);
    });
  }

  @override
  void dispose() {
    DndService.disableDnd();
    super.dispose();
  }

  void _increment() async {
    setState(() {
      _counter++;
    });

    try {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        if (_counter % 100 == 0) {
          await Vibration.vibrate(duration: 200);
        } else if (_counter % 33 == 0) {
          await Vibration.vibrate(duration: 100);
        } else {
          await Vibration.vibrate(duration: 25, amplitude: 128);
        }
      }
    } catch (_) {}
  }

  void _reset() {
    setState(() {
      _counter = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final tr = provider.tr;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: GestureDetector(
        onTap: _showAdhkar ? null : _increment,
        child: SafeArea(
          child: Stack(
            children: [
              // Main Tasbih Counter
              AnimatedOpacity(
                opacity: _showAdhkar ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 300),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _counter.toString(),
                        style: GoogleFonts.cairo(
                          fontSize: 150,
                          fontWeight: FontWeight.w200,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        tr('tasbih_tap'),
                        style: TextStyle(color: Colors.grey[700], fontSize: 16),
                      )
                    ],
                  ),
                ),
              ),
              
              // Adhkar View
              AnimatedOpacity(
                opacity: _showAdhkar ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: _buildAdhkarView(provider.locale),
              ),

              // Controls
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.grey, size: 30),
                      onPressed: _reset,
                    ),
                    TextButton(
                      onPressed: () => setState(() => _showAdhkar = !_showAdhkar),
                      child: Text(
                        _showAdhkar ? tr('return_to_tasbih') : tr('wakeup_adhkar'),
                        style: const TextStyle(color: AppColors.accent, fontSize: 16),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey, size: 30),
                      onPressed: () => Navigator.pop(context),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdhkarView(String locale) {
    final adhkarAr = [
      "لا إلهَ إلاّ اللّهُ وَحْـدَهُ لا شَـريكَ له، لهُ المُلـكُ ولهُ الحَمـد، وهوَ على كلّ شيءٍ قدير، سُـبْحانَ اللهِ، والحَمـدُ لله ، ولا إلهَ إلاّ اللهُ واللهُ أكْـبَر، وَلا حَـوْلَ وَلا قُـوَّةَ إِلاّ بِاللهِ العليّ العَظيم",
      "ثم يدعو فيقول: ربِّ اغْفرْ لي"
    ];

    final adhkarEn = [
      "There is no god but Allah alone, who has no partner. His is the dominion and His is the praise, and He is over all things powerful. Glory be to Allah, and praise be to Allah, and there is no god but Allah, and Allah is greatest, and there is no power nor strength except by Allah, the Most High, the Al-Mighty.",
      "Then supplicate: O Lord, forgive me."
    ];

    final currentAdhkar = locale == 'ar' ? adhkarAr : adhkarEn;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 100),
        child: ListView.separated(
          itemCount: currentAdhkar.length,
          separatorBuilder: (context, index) => const Divider(color: Colors.grey, height: 40),
          itemBuilder: (context, index) {
            return Text(
              currentAdhkar[index],
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 22,
                color: Colors.white,
                height: 1.8
              ),
            );
          },
        ),
      ),
    );
  }
}

