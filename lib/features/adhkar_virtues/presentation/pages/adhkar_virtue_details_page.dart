import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/adhkar_virtue.dart';
import '../widgets/adhkar_virtue_content_view.dart';
import 'package:ramadan_project/core/theme/app_theme.dart';

class AdhkarVirtueDetailsPage extends StatelessWidget {
  final AdhkarVirtue adhk;

  const AdhkarVirtueDetailsPage({super.key, required this.adhk});

  Color get _categoryColor {
    switch (adhk.type) {
      case 1:
        return const Color(0xFFE65100);
      case 2:
        return const Color(0xFF283593);
      default:
        return AppTheme.primaryEmerald;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _categoryColor;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: color,
              size: 18,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Text(
          'الذكر والفضائل',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            fontFamily: 'Cairo',
          ),
        ),
        centerTitle: true,
      ),
      body: AdhkarVirtueContentView(adhk: adhk),
    );
  }
}
