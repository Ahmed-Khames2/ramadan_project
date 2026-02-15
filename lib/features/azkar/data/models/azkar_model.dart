import 'package:flutter/material.dart';

class AzkarItem {
  final String id;
  final String title;
  final IconData icon;
  final List<ZekrModel> azkarTexts;
  final String category;

  AzkarItem({
    required this.id,
    required this.title,
    required this.icon,
    required this.azkarTexts,
    required this.category,
  });

  factory AzkarItem.fromJson(Map<String, dynamic> json) {
    final parentId = json['id']?.toString() ?? 'unknown';
    final rawItems = json['items'] as List? ?? [];

    return AzkarItem(
      id: parentId,
      title: json['title']?.toString() ?? 'بدون عنوان',
      icon: _getIcon(json['icon']?.toString() ?? ''),
      category: json['category']?.toString() ?? 'متنوع',
      azkarTexts: rawItems
          .map(
            (i) => ZekrModel.fromJson(
              i as Map<String, dynamic>,
              parentId: parentId,
            ),
          )
          .toList(),
    );
  }

  static IconData _getIcon(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'cloud':
        return Icons.cloud_queue_rounded;
      case 'moon':
        return Icons.nightlight_round;
      case 'bed':
        return Icons.bed_rounded;
      case 'sun':
        return Icons.wb_sunny_rounded;
      case 'self_improvement':
      case 'selfimprovement':
        return Icons.self_improvement_rounded;
      case 'hands_praying':
      case 'handspraying':
        return Icons.front_hand_rounded;
      case 'person_praying':
      case 'personpraying':
        return Icons.person_pin_circle_rounded;
      case 'arrow_turn_down':
      case 'arrowturndown':
        return Icons.keyboard_arrow_down_rounded;
      case 'campaign':
        return Icons.campaign_rounded;
      case 'door_open':
      case 'dooropen':
        return Icons.door_front_door_rounded;
      case 'mosque':
        return Icons.mosque_rounded;
      case 'opacity':
        return Icons.opacity_rounded;
      case 'clean_hands':
      case 'cleanhands':
        return Icons.clean_hands_rounded;
      case 'restaurant':
        return Icons.restaurant_rounded;
      case 'fastfood':
        return Icons.fastfood_rounded;
      case 'flight':
        return Icons.flight_rounded;
      case 'explore':
        return Icons.explore_rounded;
      case 'home':
        return Icons.home_rounded;
      case 'directions_walk':
      case 'directionswalk':
        return Icons.directions_walk_rounded;
      case 'checkroom':
        return Icons.checkroom_rounded;
      case 'vest':
        return Icons.checkroom_outlined;
      case 'shirt':
        return Icons.checkroom;
      case 'toilet':
        return Icons.wc_rounded;
      case 'bath':
        return Icons.bathtub_rounded;
      default:
        return Icons.circle_outlined;
    }
  }
}

class ZekrModel {
  final String id;
  final String text;
  final String? source;
  final int repeat;

  ZekrModel({
    required this.id,
    required this.text,
    this.source,
    required this.repeat,
  });

  factory ZekrModel.fromJson(
    Map<String, dynamic> json, {
    required String parentId,
  }) {
    final itemId = json['id']?.toString() ?? 'item';
    return ZekrModel(
      id: '${parentId}_$itemId',
      text: json['text']?.toString() ?? '',
      source: json['source']?.toString(),
      repeat: (json['repeat'] as num?)?.toInt() ?? 1,
    );
  }
}
