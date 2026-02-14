import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/public_scaffold.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  int? _expandedIndex;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final services = [
      {
        'icon': Icons.add_business,
        'key': 'newApplication',
        'desc': 'خدمة طلب فتح ترخيص منشأة طبية جديدة لأول مرة بجميع أنواعها.',
        'requirements': [
          'تقديم طلب رسمي موجه لمدير مكتب الصحة',
          'عقد ملكية أو إيجار المنشأة',
          'مخطط هندسي معتمد للموقع',
          'صور شخصية + صورة البطاقة الشخصية',
          'ترخيص مزاولة المهنة للمشرف الفني',
        ],
      },
      {
        'icon': Icons.refresh,
        'key': 'licenseRenewal',
        'desc': 'تجديد التراخيص السنوية للمنشآت الطبية لضمان استمرارية العمل القانوني.',
        'requirements': [
          'صورة من الترخيص السابق',
          'تقرير التفتيش الفني لآخر زيارة',
          'تحديث بيانات الكادر الطبي إن وجد',
          'سداد الرسوم المقررة',
        ],
      },
      {
        'icon': Icons.medical_services,
        'key': 'licenseUpdate',
        'desc': 'تعديل بيانات الترخيص (تغيير اسم، إضافة تخصص، تغيير موقع).',
        'requirements': [
          'الترخيص الأصلي',
          'الوثائق المؤيدة لطلب التعديل',
          'معاينة فنية للموقع في حال تغيير المقر',
        ],
      },
    ];

    return PublicScaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.translate('services'),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'تعرف على الخدمات الإلكترونية المتاحة والمتطلبات اللازمة لكل منها',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 32),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: services.length,
              itemBuilder: (context, index) {
                final svc = services[index];
                final isExpanded = _expandedIndex == index;

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
                          child: Icon(svc['icon'] as IconData, color: AppTheme.primaryGreen),
                        ),
                        title: Text(
                          loc.translate(svc['key'] as String),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(svc['desc'] as String),
                        ),
                        trailing: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
                        onTap: () => setState(() => _expandedIndex = isExpanded ? null : index),
                      ),
                      if (isExpanded)
                        Container(
                          padding: const EdgeInsets.all(24),
                          color: Colors.grey.shade50,
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'الوثائق والمتطلبات المطلوبة:',
                                style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                              ),
                              const SizedBox(height: 12),
                              ...(svc['requirements'] as List<String>).map((req) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    const Icon(Icons.check_circle_outline, size: 18, color: AppTheme.accentGold),
                                    const SizedBox(width: 12),
                                    Expanded(child: Text(req)),
                                  ],
                                ),
                              )),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () => context.go('/login'),
                                  icon: const Icon(Icons.send),
                                  label: const Text('بدء الخدمة عبر البوابة'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
