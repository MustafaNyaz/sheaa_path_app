class AthkarEntry {
  final String ar;
  final String en;
  final int? repeat;

  const AthkarEntry({
    required this.ar,
    required this.en,
    this.repeat,
  });
}

class AthkarCategory {
  final String id;
  final String titleKey;
  final List<AthkarEntry> items;

  const AthkarCategory({
    required this.id,
    required this.titleKey,
    required this.items,
  });
}

const List<AthkarCategory> athkarCategories = [
  AthkarCategory(
    id: 'morning',
    titleKey: 'athkar_morning',
    items: [
      AthkarEntry(
        ar: 'أصبحنا وأصبح الملك لله والحمد لله، لا إله إلا الله وحده لا شريك له، له الملك وله الحمد وهو على كل شيء قدير.',
        en: 'We have entered a new morning and with it all dominion is Allah’s. Praise is to Allah; none has the right to be worshiped except Allah alone, without partner.',
      ),
      AthkarEntry(
        ar: 'اللهم بك أصبحنا وبك أمسينا وبك نحيا وبك نموت وإليك النشور.',
        en: 'O Allah, by You we enter the morning and by You we enter the evening; by You we live and by You we die, and to You is the return.',
      ),
      AthkarEntry(
        ar: 'حسبي الله لا إله إلا هو عليه توكلت وهو رب العرش العظيم.',
        en: 'Allah is sufficient for me; there is no deity except Him. In Him I trust, and He is the Lord of the Mighty Throne.',
        repeat: 7,
      ),
      AthkarEntry(
        ar: 'سبحان الله وبحمده.',
        en: 'Glory and praise be to Allah.',
        repeat: 100,
      ),
      AthkarEntry(
        ar: 'اللهم إني أسألك خير هذا اليوم فتحه ونصره ونوره وبركته وهداه.',
        en: 'O Allah, I ask You for the الخير of this day: its openings, its victory, its light, its blessing, and its guidance.',
      ),
    ],
  ),
  AthkarCategory(
    id: 'evening',
    titleKey: 'athkar_evening',
    items: [
      AthkarEntry(
        ar: 'أمسينا وأمسى الملك لله والحمد لله، لا إله إلا الله وحده لا شريك له، له الملك وله الحمد وهو على كل شيء قدير.',
        en: 'We have entered a new evening and with it all dominion is Allah’s. Praise is to Allah; none has the right to be worshiped except Allah alone, without partner.',
      ),
      AthkarEntry(
        ar: 'اللهم بك أمسينا وبك أصبحنا وبك نحيا وبك نموت وإليك المصير.',
        en: 'O Allah, by You we enter the evening and by You we enter the morning; by You we live and by You we die, and to You is the return.',
      ),
      AthkarEntry(
        ar: 'حسبي الله لا إله إلا هو عليه توكلت وهو رب العرش العظيم.',
        en: 'Allah is sufficient for me; there is no deity except Him. In Him I trust, and He is the Lord of the Throne.',
        repeat: 7,
      ),
      AthkarEntry(
        ar: 'أعوذ بكلمات الله التامات من شر ما خلق.',
        en: 'I seek refuge in the perfect words of Allah from the evil of what He has created.',
        repeat: 3,
      ),
      AthkarEntry(
        ar: 'سبحان الله وبحمده.',
        en: 'Glory and praise be to Allah.',
        repeat: 100,
      ),
    ],
  ),
  AthkarCategory(
    id: 'after_prayer',
    titleKey: 'athkar_after_prayer',
    items: [
      AthkarEntry(
        ar: 'أستغفر الله.',
        en: 'I seek Allah’s forgiveness.',
        repeat: 3,
      ),
      AthkarEntry(
        ar: 'اللهم أنت السلام ومنك السلام تباركت يا ذا الجلال والإكرام.',
        en: 'O Allah, You are Peace and from You is Peace. Blessed are You, O Possessor of majesty and honor.',
      ),
      AthkarEntry(
        ar: 'سبحان الله.',
        en: 'Glory be to Allah.',
        repeat: 33,
      ),
      AthkarEntry(
        ar: 'الحمد لله.',
        en: 'All praise is due to Allah.',
        repeat: 33,
      ),
      AthkarEntry(
        ar: 'الله أكبر.',
        en: 'Allah is the Greatest.',
        repeat: 34,
      ),
    ],
  ),
  AthkarCategory(
    id: 'before_sleep',
    titleKey: 'athkar_before_sleep',
    items: [
      AthkarEntry(
        ar: 'باسمك اللهم أموت وأحيا.',
        en: 'In Your name, O Allah, I die and I live.',
      ),
      AthkarEntry(
        ar: 'اللهم قني عذابك يوم تبعث عبادك.',
        en: 'O Allah, protect me from Your punishment on the Day You resurrect Your servants.',
        repeat: 3,
      ),
      AthkarEntry(
        ar: 'سبحان الله.',
        en: 'Glory be to Allah.',
        repeat: 33,
      ),
      AthkarEntry(
        ar: 'الحمد لله.',
        en: 'All praise is due to Allah.',
        repeat: 33,
      ),
      AthkarEntry(
        ar: 'الله أكبر.',
        en: 'Allah is the Greatest.',
        repeat: 34,
      ),
    ],
  ),
  AthkarCategory(
    id: 'wakeup',
    titleKey: 'athkar_wakeup',
    items: [
      AthkarEntry(
        ar: 'الحمد لله الذي أحيانا بعد ما أماتنا وإليه النشور.',
        en: 'Praise is to Allah who gave us life after causing us to die, and to Him is the return.',
      ),
      AthkarEntry(
        ar: 'لا إله إلا الله وحده لا شريك له، له الملك وله الحمد وهو على كل شيء قدير.',
        en: 'There is no deity except Allah alone, without partner. His is the dominion and praise, and He is over all things capable.',
      ),
      AthkarEntry(
        ar: 'رب اغفر لي.',
        en: 'My Lord, forgive me.',
      ),
    ],
  ),
];
