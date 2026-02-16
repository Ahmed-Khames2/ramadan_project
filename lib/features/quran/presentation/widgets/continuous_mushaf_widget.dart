import 'package:flutter/material.dart';
import 'package:quran/quran.dart' as quran;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ramadan_project/core/theme/app_theme.dart';
import 'package:ramadan_project/features/quran/domain/entities/ayah.dart';
import 'package:ramadan_project/features/quran/domain/entities/quran_page.dart';
import 'package:ramadan_project/features/quran/domain/repositories/quran_repository.dart';

/// Mushaf-style page widget with a classic printed look.
class ContinuousMushafPageWidget extends StatefulWidget {
  final int pageNumber;
  final double fontScale;

  const ContinuousMushafPageWidget({
    super.key,
    required this.pageNumber,
    this.fontScale = 1.0,
  });

  @override
  State<ContinuousMushafPageWidget> createState() =>
      _ContinuousMushafPageWidgetState();
}

class _ContinuousMushafPageWidgetState
    extends State<ContinuousMushafPageWidget> {
  static const double _basePageWidth = 360;
  static const double _basePageHeight = 640;
  static const EdgeInsets _frameInset =
      EdgeInsets.symmetric(horizontal: 18, vertical: 16);
  late Future<QuranPage> _pageData;
  static const List<String> _arabicDigits = [
    '٠',
    '١',
    '٢',
    '٣',
    '٤',
    '٥',
    '٦',
    '٧',
    '٨',
    '٩',
  ];

  String _toArabicDigits(String input) {
    final buffer = StringBuffer();
    for (final codeUnit in input.codeUnits) {
      final digit = codeUnit - 48;
      if (digit >= 0 && digit <= 9) {
        buffer.write(_arabicDigits[digit]);
      } else {
        buffer.writeCharCode(codeUnit);
      }
    }
    return buffer.toString();
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(ContinuousMushafPageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pageNumber != widget.pageNumber) {
      _loadData();
    }
  }

  void _loadData() {
    _pageData = context.read<QuranRepository>().getPage(widget.pageNumber);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuranPage>(
      future: _pageData,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final page = snapshot.data!;
        final isDefaultScale = (widget.fontScale - 1.0).abs() < 0.01;
        final contentScale = isDefaultScale ? 1.0 : widget.fontScale;

        Widget buildContent() {
          final body = _buildPageBody(
            page,
            contentScale,
            useExpanded: isDefaultScale,
          );

          if (isDefaultScale) {
            return Align(
              alignment: Alignment.topCenter,
              child: FittedBox(
                fit: BoxFit.contain,
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: _basePageWidth,
                  height: _basePageHeight,
                  child: body,
                ),
              ),
            );
          }

          return SingleChildScrollView(child: body);
        }

        return Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFFDFBF7),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFD4AF37), width: 1.2),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
            image: const DecorationImage(
              image: AssetImage('assets/images/paper_texture.png'),
              fit: BoxFit.cover,
              opacity: 0.35,
            ),
          ),
          child: Padding(
            padding: _frameInset,
            child: buildContent(),
          ),
        );
      },
    );
  }

  Widget _buildPageBody(
    QuranPage page,
    double scale, {
    required bool useExpanded,
  }) {
    final quranContent = _buildQuranContent(page, scale);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildHeaderChip(
              'الجزء ${_toArabicDigits(page.juzNumber.toString())}',
              scale,
            ),
            _buildHeaderChip(
              'الصفحة ${_toArabicDigits(page.pageNumber.toString())}',
              scale,
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (useExpanded)
          Expanded(child: quranContent)
        else
          quranContent,
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFD4AF37)),
          ),
          child: Text(
            _toArabicDigits(page.pageNumber.toString()),
            style: TextStyle(
              fontFamily: 'UthmanTaha',
              fontSize: 14 * scale,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryEmerald,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderChip(String text, double scale) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD4AF37)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'UthmanTaha',
          fontSize: 12 * scale,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryEmerald,
        ),
      ),
    );
  }

  Widget _buildQuranContent(
    QuranPage page,
    double scale,
  ) {
    final spans = <InlineSpan>[];
    int currentSurah = -1;
    final baseTextStyle = TextStyle(
      fontFamily: 'UthmanTaha',
      fontSize: 18 * scale,
      height: 1.9,
      color: Colors.black87,
    );
    final centeredLineWidth = _basePageWidth - _frameInset.horizontal;

    for (final ayah in page.ayahs) {
      if (ayah.surahNumber != currentSurah) {
        if (currentSurah != -1) {
          spans.add(const TextSpan(text: '\n'));
        }

        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: SizedBox(
              width: centeredLineWidth,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFFD4AF37),
                      width: 1.2,
                    ),
                  ),
                  child: Text(
                    'سورة ${quran.getSurahNameArabic(ayah.surahNumber)}',
                    style: baseTextStyle.copyWith(fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        );
        spans.add(const TextSpan(text: '\n'));

        if (ayah.surahNumber != 1) {
          spans.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: SizedBox(
                width: centeredLineWidth,
                child: Center(
                  child: Text(
                    'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
                    style: baseTextStyle,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          );
          spans.add(const TextSpan(text: '\n'));
        }

        currentSurah = ayah.surahNumber;
      }

      spans.add(
        TextSpan(
          text: ayah.text,
          style: baseTextStyle,
        ),
      );

      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: SizedBox(
              width: 32 * scale,
              height: 32 * scale,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/images/ayah_frame.svg',
                    width: 32 * scale,
                    height: 32 * scale,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFFD4AF37),
                      BlendMode.srcIn,
                    ),
                  ),
                  Text(
                    _toArabicDigits(ayah.ayahNumber.toString()),
                    style: TextStyle(
                      fontFamily: 'UthmanTaha',
                      fontSize: 12 * scale,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      spans.add(const TextSpan(text: ' '));
    }

    return RichText(
      text: TextSpan(children: spans),
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.justify,
    );
  }
}
