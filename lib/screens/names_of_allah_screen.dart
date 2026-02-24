import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../utils/app_colors.dart';

class NamesOfAllahScreen extends StatelessWidget {
  const NamesOfAllahScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tr = context.read<AppProvider>().tr;
    // Basic data for demonstration. In a real app, this would be a full JSON/DB list.
    final names = [
      {"ar": "الله", "en": "Allah", "desc": "The Greatest Name"},
      {"ar": "الرَّحْمَن", "en": "Ar-Rahman", "desc": "The Entirely Merciful"},
      {"ar": "الرَّحِيم", "en": "Ar-Rahim", "desc": "The Especially Merciful"},
      {"ar": "الْمَلِك", "en": "Al-Malik", "desc": "The King and Owner of Dominion"},
      {"ar": "الْقُدُّوس", "en": "Al-Quddus", "desc": "The Absolutely Pure"},
      {"ar": "السَّلَام", "en": "As-Salam", "desc": "The Source of Peace"},
      {"ar": "الْمُؤْمِن", "en": "Al-Mu'min", "desc": "The Giver of Faith and Security"},
      {"ar": "الْمُهَيْمِن", "en": "Al-Muhaymin", "desc": "The Guardian, The Witness"},
      {"ar": "الْعَزِيز", "en": "Al-Aziz", "desc": "The All Mighty"},
      {"ar": "الْجَبَّار", "en": "Al-Jabbar", "desc": "The Compeller"},
      {"ar": "الْمُتَكَبِّر", "en": "Al-Mutakabbir", "desc": "The Supreme, The Majestic"},
      {"ar": "الْخَالِق", "en": "Al-Khaliq", "desc": "The Creator"},
      {"ar": "الْبَارِئ", "en": "Al-Bari", "desc": "The Evolver"},
      {"ar": "الْمُصَوِّر", "en": "Al-Musawwir", "desc": "The Fashioner"},
      {"ar": "الْغَفَّار", "en": "Al-Ghaffar", "desc": "The Constant Forgiver"},
      {"ar": "الْقَهَّار", "en": "Al-Qahhar", "desc": "The All-Prevailing One"},
      {"ar": "الْوَهَّاب", "en": "Al-Wahhab", "desc": "The Supreme Bestower"},
      {"ar": "الرَّزَّاق", "en": "Ar-Razzaq", "desc": "The Provider"},
      {"ar": "الْفَتَّاح", "en": "Al-Fattah", "desc": "The Supreme Solver"},
      {"ar": "الْعَلِيم", "en": "Al-Alim", "desc": "The All-Knowing"},
      {"ar": "الْقَابِض", "en": "Al-Qabid", "desc": "The Withholder"},
      {"ar": "الْبَاسِط", "en": "Al-Basit", "desc": "The Extender"},
      {"ar": "الْخَافِض", "en": "Al-Khafid", "desc": "The Reducer"},
      {"ar": "الرَّافِع", "en": "Ar-Rafi", "desc": "The Exalter"},
      {"ar": "الْمُعِزّ", "en": "Al-Mu'izz", "desc": "The Honorer"},
      {"ar": "الْمُذِلّ", "en": "Al-Mudhill", "desc": "The Humiliator"},
      {"ar": "السَّمِيع", "en": "As-Sami", "desc": "The All-Hearing"},
      {"ar": "الْبَصِير", "en": "Al-Basir", "desc": "The All-Seeing"},
      {"ar": "الْحَكَم", "en": "Al-Hakam", "desc": "The Impartial Judge"},
      {"ar": "الْعَدْل", "en": "Al-Adl", "desc": "The Utterly Just"},
      {"ar": "اللَّطِيف", "en": "Al-Latif", "desc": "The Subtle One"},
      {"ar": "الْخَبِير", "en": "Al-Khabir", "desc": "The All-Aware"},
      {"ar": "الْحَلِيم", "en": "Al-Halim", "desc": "The Most Forbearing"},
      {"ar": "الْعَظِيم", "en": "Al-Azim", "desc": "The Magnificent"},
      {"ar": "الْغَفُور", "en": "Al-Ghafur", "desc": "The Great Forgiver"},
      {"ar": "الشَّكُور", "en": "Ash-Shakur", "desc": "The Most Appreciative"},
      {"ar": "الْعَلِيّ", "en": "Al-Ali", "desc": "The Most High"},
      {"ar": "الْكَبِير", "en": "Al-Kabir", "desc": "The Most Great"},
      {"ar": "الْحَفِيظ", "en": "Al-Hafiz", "desc": "The Preserver"},
      {"ar": "الْمُقِيت", "en": "Al-Muqit", "desc": "The Sustainer"},
      {"ar": "الْحَسِيب", "en": "Al-Hasib", "desc": "The Reckoner"},
      {"ar": "الْجَلِيل", "en": "Al-Jalil", "desc": "The Majestic"},
      {"ar": "الْكَرِيم", "en": "Al-Karim", "desc": "The Bountiful"},
      {"ar": "الرَّقِيب", "en": "Ar-Raqib", "desc": "The Watchful"},
      {"ar": "الْمُجِيب", "en": "Al-Mujib", "desc": "The Responsive"},
      {"ar": "الْوَاسِع", "en": "Al-Wasi", "desc": "The All-Encompassing"},
      {"ar": "الْحَكِيم", "en": "Al-Hakim", "desc": "The All-Wise"},
      {"ar": "الْوَدُود", "en": "Al-Wadud", "desc": "The Loving"},
      {"ar": "الْمَجِيد", "en": "Al-Majid", "desc": "The Glorious"},
      {"ar": "الْبَاعِث", "en": "Al-Ba'ith", "desc": "The Resurrecter"},
      {"ar": "الشَّهِيد", "en": "Ash-Shahid", "desc": "The Witness"},
      {"ar": "الْحَقّ", "en": "Al-Haqq", "desc": "The Truth"},
      {"ar": "الْوَكِيل", "en": "Al-Wakil", "desc": "The Trustee"},
      {"ar": "الْقَوِيّ", "en": "Al-Qawiyy", "desc": "The Possessor of All Strength"},
      {"ar": "الْمَتِين", "en": "Al-Matin", "desc": "The Firm"},
      {"ar": "الْوَلِيّ", "en": "Al-Waliyy", "desc": "The Protecting Friend"},
      {"ar": "الْحَمِيد", "en": "Al-Hamid", "desc": "The Praiseworthy"},
      {"ar": "الْمُحْصِي", "en": "Al-Muhsi", "desc": "The Accounter"},
      {"ar": "الْمُبْدِئ", "en": "Al-Mubdi", "desc": "The Originator"},
      {"ar": "الْمُعِيد", "en": "Al-Mu'id", "desc": "The Restorer"},
      {"ar": "الْمُحْيِي", "en": "Al-Muhyi", "desc": "The Giver of Life"},
      {"ar": "الْمُمِيت", "en": "Al-Mumit", "desc": "The Creator of Death"},
      {"ar": "الْحَيّ", "en": "Al-Hayy", "desc": "The Ever-Living"},
      {"ar": "الْقَيُّوم", "en": "Al-Qayyum", "desc": "The Self-Subsisting"},
      {"ar": "الْوَاجِد", "en": "Al-Wajid", "desc": "The Perceiver"},
      {"ar": "الْمَاجِد", "en": "Al-Majid", "desc": "The Illustrious"},
      {"ar": "الْوَاحِد", "en": "Al-Wahid", "desc": "The One"},
      {"ar": "الْأَحَد", "en": "Al-Ahad", "desc": "The Unique"},
      {"ar": "الصَّمَد", "en": "As-Samad", "desc": "The Eternal Refuge"},
      {"ar": "الْقَادِر", "en": "Al-Qadir", "desc": "The Capable"},
      {"ar": "الْمُقْتَدِر", "en": "Al-Muqtadir", "desc": "The Determiner"},
      {"ar": "الْمُقَدِّم", "en": "Al-Muqaddim", "desc": "The Expediter"},
      {"ar": "الْمُؤَخِّر", "en": "Al-Mu'akhkhir", "desc": "The Delayer"},
      {"ar": "الْأَوَّل", "en": "Al-Awwal", "desc": "The First"},
      {"ar": "الْآخِر", "en": "Al-Akhir", "desc": "The Last"},
      {"ar": "الظَّاهِر", "en": "Az-Zahir", "desc": "The Manifest"},
      {"ar": "الْبَاطِن", "en": "Al-Batin", "desc": "The Hidden"},
      {"ar": "الْوَالِي", "en": "Al-Wali", "desc": "The Patron"},
      {"ar": "الْمُتَعَالِي", "en": "Al-Muta'ali", "desc": "The Self Exalted"},
      {"ar": "الْبَرّ", "en": "Al-Barr", "desc": "The Source of Goodness"},
      {"ar": "التَّوَّاب", "en": "At-Tawwab", "desc": "The Ever-Pardoning"},
      {"ar": "الْمُنْتَقِم", "en": "Al-Muntaqim", "desc": "The Avenger"},
      {"ar": "الْعَفُوّ", "en": "Al-Afuww", "desc": "The Pardoner"},
      {"ar": "الرَّؤُوف", "en": "Ar-Ra'uf", "desc": "The Compassionate"},
      {"ar": "مَالِكُ الْمُلْك", "en": "Malik-ul-Mulk", "desc": "The Owner of All Sovereignty"},
      {"ar": "ذُو الْجَلَالِ وَالْإِكْرَام", "en": "Dhul-Jalal wal-Ikram", "desc": "The Lord of Majesty and Generosity"},
      {"ar": "الْمُقْسِط", "en": "Al-Muqsit", "desc": "The Equitable"},
      {"ar": "الْجَامِع", "en": "Al-Jami", "desc": "The Gatherer"},
      {"ar": "الْغَنِيّ", "en": "Al-Ghaniyy", "desc": "The Self-Sufficient"},
      {"ar": "الْمُغْنِي", "en": "Al-Mughni", "desc": "The Enricher"},
      {"ar": "الْمَانِع", "en": "Al-Mani", "desc": "The Preventer"},
      {"ar": "الضَّار", "en": "Ad-Darr", "desc": "The Distressor"},
      {"ar": "النَّافِع", "en": "An-Nafi", "desc": "The Propitious"},
      {"ar": "النُّور", "en": "An-Nur", "desc": "The Light"},
      {"ar": "الْهَادِي", "en": "Al-Hadi", "desc": "The Guide"},
      {"ar": "الْبَدِيع", "en": "Al-Badi", "desc": "The Incomparable Originator"},
      {"ar": "الْبَاقِي", "en": "Al-Baqi", "desc": "The Ever-Surviving"},
      {"ar": "الْوَارِث", "en": "Al-Warith", "desc": "The Inheritor"},
      {"ar": "الرَّشِيد", "en": "Ar-Rashid", "desc": "The Guide to the Right Path"},
      {"ar": "الصَّبُور", "en": "As-Sabur", "desc": "The Patient"},
    ];

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text(tr('names_of_allah'), style: const TextStyle(color: AppColors.accent)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.1,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: names.length,
        itemBuilder: (context, index) {
          final name = names[index];
          return Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ]
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  name['ar']!, 
                  style: const TextStyle(
                    fontFamily: 'Tajawal', 
                    fontSize: 28, 
                    color: AppColors.accent,
                    fontWeight: FontWeight.bold
                  )
                ),
                const SizedBox(height: 8),
                Text(
                  name['en']!, 
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    name['desc']!, 
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey, fontSize: 10),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}


