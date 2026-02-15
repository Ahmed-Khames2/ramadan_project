import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran/quran.dart' as quran;
import 'package:ramadan_project/features/quran/domain/repositories/quran_repository.dart';

class QuranIndexDrawer extends StatelessWidget {
  final Function(int page) onPageSelected;

  const QuranIndexDrawer({super.key, required this.onPageSelected});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 48, bottom: 16),
            color: const Color(0xFFFDFBF7),
            width: double.infinity,
            child: const Text(
              "الفهرس",
              style: TextStyle(
                fontFamily: 'UthmanTaha',
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  const TabBar(
                    labelColor: Color(0xFFD4AF37),
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Color(0xFFD4AF37),
                    tabs: [
                      Tab(text: "السور"),
                      Tab(text: "الأجزاء"),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildSurahList(context),
                        _buildJuzList(context),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSurahList(BuildContext context) {
    return ListView.builder(
      itemCount: 114,
      itemBuilder: (context, index) {
        final surahNum = index + 1;
        return ListTile(
          leading: Text(
            "$surahNum",
            style: const TextStyle(
              fontFamily: 'UthmanTaha',
              color: Color(0xFFD4AF37),
            ),
          ),
          title: Text(
            "سورة ${quran.getSurahNameArabic(surahNum)}",
            style: const TextStyle(fontFamily: 'UthmanTaha', fontSize: 18),
          ),
          subtitle: Text(
            "${quran.getPlaceOfRevelation(surahNum)} - ${quran.getVerseCount(surahNum)} آية",
            style: const TextStyle(fontSize: 12),
          ),
          onTap: () {
            // Get start page of Surah
            // We can use quran package or Repo. Repo logic is more consistent with our Page Engine.
            // But Repo page map is internal.
            // However, quran.getPageNumber(surah, 1) usually works.
            final page = quran.getPageNumber(surahNum, 1);
            onPageSelected(page);
          },
        );
      },
    );
  }

  Widget _buildJuzList(BuildContext context) {
    return ListView.builder(
      itemCount: 30,
      itemBuilder: (context, index) {
        final juzNum = index + 1;
        return ListTile(
          leading: const Icon(Icons.bookmark_outline, color: Color(0xFFD4AF37)),
          title: Text(
            "الجزء $juzNum",
            style: const TextStyle(fontFamily: 'UthmanTaha', fontSize: 18),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 14),
          onTap: () {
            final page = context.read<QuranRepository>().getJuzStartPage(
              juzNum,
            );
            onPageSelected(page);
          },
        );
      },
    );
  }
}
