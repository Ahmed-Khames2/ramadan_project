import 'package:flutter/material.dart';
import 'package:ramadan_project/core/theme/app_theme.dart';
import 'package:ramadan_project/core/widgets/common_widgets.dart';

class DedicationPage extends StatelessWidget {
  const DedicationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'إهداء وتذكرة',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cairo', // AppBar title usually uses Cairo in this app
            color: AppTheme.primaryEmerald,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const IslamicBackButton(),
      ),
      body: DecorativeBackground(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      _buildDedicationCard(context),
                      const SizedBox(height: 32),
                      _buildDuaSection(context),
                      const SizedBox(height: 40),
                      _buildFooter(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDedicationCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return IslamicCard(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryEmerald.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.favorite_rounded,
              color: AppTheme.primaryEmerald,
              size: 48,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'هذا العمل صدقة جارية',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryEmerald,
              fontFamily: 'UthmanTaha',
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'عن روح والد المطور أحمد خميس\nنسأل الله أن يتغمده بواسع رحمته ويسكنه فسيح جناته، وأن يجزيه خير الجزاء على ما ربى وعلم.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? AppTheme.textLight : AppTheme.textDark,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),
          const OrnamentalDivider(width: 100),
        ],
      ),
    );
  }

  Widget _buildDuaSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final duas = [
      'اللهم اغفر له وارحمه، وعافه واعف عنه، وأكرم نزله، ووسع مدخله، واغسله بالماء والثلج والبرد، ونقه من الخطايا كما ينقى الثوب الأبيض من الدنس.',
      'اللهم أبدله داراً خيراً من داره، وأهلاً خيراً من أهله، وأدخله الجنة، وأعذه من عذاب القبر ومن عذاب النار.',
      'اللهم عامله بما أنت أهله، ولا تعامله بما هو أهله، واجزه عن الإحسان إحساناً، وعن الإساءة عفواً وغفراناً.',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'أدعية مأثورة للمتوفى',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryEmerald,
          ),
        ),
        const SizedBox(height: 16),
        ...duas.map(
          (dua) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: IslamicCard(
              child: Text(
                dua,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: isDark ? AppTheme.textLight : AppTheme.textDark,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Column(
      children: [
        const Text(
          'قال رسول الله ﷺ: "إِذَا مَاتَ ابنُ آدم انْقَطَعَ عَنْهُ عَمَلُهُ إِلَّا مِنْ ثَلَاثٍ: صَدَقَةٍ جَارِيَةٍ، أَوْ عِلْمٍ يُنْتَفَعُ بِهِ، أَوْ وَلَدٍ صَالِحٍ يَدْعُو لَهُ"',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontStyle: FontStyle.italic,
            color: AppTheme.textGrey,
            height: 1.8,
          ),
        ),
        const SizedBox(height: 24),
        Opacity(opacity: 0.6, child: const OrnamentalDivider(width: 120)),
        const SizedBox(height: 32),
      ],
    );
  }
}
