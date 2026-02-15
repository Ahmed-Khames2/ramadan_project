import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ramadan_project/presentation/blocs/tasbih_bloc.dart';
import 'package:ramadan_project/core/theme/app_theme.dart';

class TasbihSettingsSheet extends StatelessWidget {
  const TasbihSettingsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.all(AppTheme.spacing6),
      child: BlocBuilder<TasbihBloc, TasbihState>(
        builder: (context, state) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'إعدادات المسبحة',
                    style: GoogleFonts.cairo(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacing4),

              Text(
                'عدد التسبيحات',
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                children: [33, 99, 100].map((count) {
                  final isSelected = state.targetCount == count;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => context.read<TasbihBloc>().add(
                        UpdateBeadSettings(
                          totalBeads: count,
                          material: state.material,
                        ),
                      ),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.primaryEmerald
                              : AppTheme.primaryEmerald.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            '$count',
                            style: GoogleFonts.cairo(
                              color: isSelected
                                  ? Colors.white
                                  : AppTheme.primaryEmerald,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: AppTheme.spacing6),
              Text(
                'نوع المادة',
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 80,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildMaterialOption(
                      context,
                      state,
                      'emerald',
                      'زمرد',
                      AppTheme.primaryEmerald,
                    ),
                    _buildMaterialOption(
                      context,
                      state,
                      'gold',
                      'ذهب',
                      AppTheme.accentGold,
                    ),
                    _buildMaterialOption(
                      context,
                      state,
                      'wood',
                      'خشب',
                      const Color(0xFF5D4037),
                    ),
                    _buildMaterialOption(
                      context,
                      state,
                      'marble',
                      'رخام',
                      const Color(0xFFE0E0E0),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppTheme.spacing6),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMaterialOption(
    BuildContext context,
    TasbihState state,
    String id,
    String name,
    Color color,
  ) {
    final isSelected = state.material == id;
    return GestureDetector(
      onTap: () => context.read<TasbihBloc>().add(
        UpdateBeadSettings(totalBeads: state.targetCount, material: id),
      ),
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryEmerald.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: AppTheme.primaryEmerald, width: 2)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(name, style: GoogleFonts.cairo(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
