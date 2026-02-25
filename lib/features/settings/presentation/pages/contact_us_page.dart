import 'package:flutter/material.dart';
import 'package:ramadan_project/core/theme/app_theme.dart';
import 'package:ramadan_project/core/widgets/common_widgets.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ramadan_project/core/widgets/error_dialog.dart';

class ContactUsPage extends StatelessWidget {
  const ContactUsPage({super.key});

  Future<void> _launchUrl(BuildContext context, String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ErrorDialog.show(context, message: 'لا يمكن فتح الرابط المطلوب');
        }
      }
    } catch (e) {
      if (context.mounted) {
        ErrorDialog.show(context, message: 'حدث خطأ أثناء محاولة فتح الرابط');
      }
    }
  }

  Future<void> _sendEmailTo(BuildContext context, String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=زاد - استفسار',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      if (context.mounted) {
        ErrorDialog.show(
          context,
          message: 'لا يمكن فتح تطبيق البريد الإلكتروني',
        );
      }
    }
  }

  Future<void> _showDeveloperChoice(
    BuildContext context, {
    required String channel,
  }) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.textGrey.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'تواصل عبر $channel مع:',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryEmerald,
              ),
            ),
            const SizedBox(height: 24),
            _buildDevOption(
              context,
              name: 'م/ أحمد خميس',
              channel: channel,
              whatsapp: 'https://wa.me/201276898296',
              linkedin: 'https://www.linkedin.com/in/ahmed-khames-738070289/',
              email: 'ahmedkhames1234567@gmail.com',
            ),
            const SizedBox(height: 12),
            _buildDevOption(
              context,
              name: 'م/ أحمد الليبي',
              channel: channel,
              whatsapp: 'https://wa.me/201278576046', // Placeholder
              linkedin:
                  'https://www.linkedin.com/in/ahmedabdulaziz10', // Placeholder
              email: 'ahmedabdulazizz203@gmail.com',
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDevOption(
    BuildContext context, {
    required String name,
    required String channel,
    required String whatsapp,
    required String linkedin,
    required String email,
  }) {
    return IslamicCard(
      padding: EdgeInsets.zero,
      onTap: () {
        Navigator.pop(context);
        if (channel == 'واتساب') {
          _launchUrl(context, whatsapp);
        } else if (channel == 'لينكد إن') {
          _launchUrl(context, linkedin);
        } else {
          _sendEmailTo(context, email);
        }
      },
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryEmerald.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.person_rounded,
            color: AppTheme.primaryEmerald,
          ),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'تواصل معنا',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cairo',
            color: AppTheme.primaryEmerald,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const IslamicBackButton(),
      ),
      body: DecorativeBackground(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            const Center(
              child: Column(
                children: [
                  SizedBox(height: 8),
                  Text(
                    'يسعدنا دائماً تواصلكم معنا  ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryEmerald,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'نحن مهتمون بمساعدتكم وتطوير التطبيق بآرائكم ومجهوداتكم ',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: AppTheme.textGrey),
                  ),
                  SizedBox(height: 16),
                  OrnamentalDivider(width: 60),
                ],
              ),
            ),
            const SizedBox(height: 48),
            _buildContactGrid(context),
            const SizedBox(height: 48),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildContactGrid(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _buildChannelCard(
              context,
              title: 'واتساب',
              childTitle: 'WhatsApp',
              icon: FontAwesomeIcons.whatsapp,
              color: Colors.green,
              onTap: () => _showDeveloperChoice(context, channel: 'واتساب'),
            ),
            const SizedBox(width: 16),
            _buildChannelCard(
              context,
              title: 'لينكد إن',
              childTitle: 'LinkedIn',
              icon: FontAwesomeIcons.linkedin,
              color: const Color(0xFF0A66C2),
              onTap: () => _showDeveloperChoice(context, channel: 'لينكد إن'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildChannelCard(
          context,
          title: 'البريد الإلكتروني',
          childTitle: 'Email (Gmail)',
          icon: FontAwesomeIcons.envelope,
          color: const Color(0xFFEA4335),
          fullWidth: true,
          onTap: () =>
              _showDeveloperChoice(context, channel: 'البريد الإلكتروني'),
        ),
      ],
    );
  }

  Widget _buildChannelCard(
    BuildContext context, {
    required String title,
    required String childTitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool fullWidth = false,
  }) {
    final card = IslamicCard(
      padding: const EdgeInsets.symmetric(vertical: 32),
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: FaIcon(icon, color: color, size: 36),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            childTitle,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textGrey.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );

    return fullWidth
        ? SizedBox(width: double.infinity, child: card)
        : Expanded(child: card);
  }

  Widget _buildFooter(BuildContext context) {
    return const Center(
      child: Column(
        children: [
          Text(
            'فريق تطوير زاد',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryEmerald,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'م/ أحمد خميس & م/ أحمد الليبي',
            style: TextStyle(fontSize: 12, color: AppTheme.textGrey),
          ),
        ],
      ),
    );
  }
}
