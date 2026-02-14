import 'package:flutter/material.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/public_scaffold.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return PublicScaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.translate('about'),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
            ),
            const SizedBox(height: 24),
            _buildSection(
              'الرؤية',
              'منشآت طبية نموذجية ومجتمع صحي آمن في أمانة العاصمة عبر تطبيق أعلى معايير الجودة والرقابة الصحية.',
              Icons.visibility,
            ),
            const SizedBox(height: 24),
            _buildSection(
              'الرسالة',
              'الارتقاء بالخدمات الطبية النوعية وتسهيل الإجراءات للمستثمرين في القطاع الصحي مع ضمان الالتزام باللوائح والأنظمة المنظمة للمهن الطبية والبيئية.',
              Icons.flag,
            ),
            const SizedBox(height: 24),
            const Text(
              'قيمنا الجوهرية',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _valueCard('النزاهة', 'الالتزام التام بالمعايير القانونية والأخلاقية.'),
                _valueCard('الشفافية', 'وضوح الإجراءات والضوابط لجميع المواطنين.'),
                _valueCard('التميز', 'السعي الدائم لتحسين جودة الخدمات المقدمة.'),
                _valueCard('الرقابة', 'متابعة مستمرة لضمان سلامة المجتمع.'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content, IconData icon) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppTheme.accentGold, size: 28),
                const SizedBox(width: 12),
                Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            Text(content, style: const TextStyle(fontSize: 16, height: 1.8, color: Colors.black87)),
          ],
        ),
      ),
    );
  }

  Widget _valueCard(String title, String desc) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primaryGreen)),
          const SizedBox(height: 8),
          Text(desc, style: const TextStyle(color: Colors.black54, fontSize: 14)),
        ],
      ),
    );
  }
}
