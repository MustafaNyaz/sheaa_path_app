import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../data/athkar_data.dart';
import '../providers/app_provider.dart';
import '../utils/app_colors.dart';

class AthkarScreen extends StatelessWidget {
  const AthkarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tr = context.read<AppProvider>().tr;
    final locale = context.read<AppProvider>().locale;

    return DefaultTabController(
      length: athkarCategories.length,
      child: Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(
          title: Text(tr('athkar'), style: const TextStyle(color: AppColors.accent)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: const BackButton(color: Colors.white),
          bottom: TabBar(
            isScrollable: true,
            indicatorColor: AppColors.accent,
            labelColor: AppColors.accent,
            unselectedLabelColor: AppColors.muted,
            tabs: [
              for (final category in athkarCategories) Tab(text: tr(category.titleKey)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            for (final category in athkarCategories) _AthkarList(category: category, locale: locale),
          ],
        ),
      ),
    );
  }
}

class _AthkarList extends StatelessWidget {
  final AthkarCategory category;
  final String locale;

  const _AthkarList({
    required this.category,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    final showTranslation = locale == 'en';
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 30),
      itemCount: category.items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = category.items[index];
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.accent.withValues(alpha: 0.15)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      item.ar,
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                      style: GoogleFonts.cairo(
                        fontSize: 20,
                        color: Colors.white,
                        height: 1.7,
                      ),
                      textHeightBehavior: const TextHeightBehavior(
                        applyHeightToFirstAscent: false,
                        applyHeightToLastDescent: false,
                      ),
                      softWrap: true,
                    ),
                  ),
                  if (item.repeat != null) ...[
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.accent.withValues(alpha: 0.5)),
                      ),
                      child: Text(
                        'x${item.repeat}',
                        style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ],
              ),
              if (showTranslation) ...[
                const SizedBox(height: 10),
                Text(
                  item.en,
                  style: const TextStyle(color: AppColors.muted, height: 1.55),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

