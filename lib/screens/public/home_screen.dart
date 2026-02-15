import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/public_scaffold.dart';

import '../../widgets/double_back_pop_scope.dart';
import '../../core/models/public_content_model.dart';
import '../../core/services/public_service.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<PublicContent> _news = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchContent();
  }

  Future<void> _fetchContent() async {
    try {
      final api = context.read<AuthProvider>().apiService;
      final service = PublicService(api);
      
      // Fetch news, circulars, and regulations
      final newsList = await service.getContent('NEWS');
      final circularList = await service.getContent('CIRCULAR');
      final regulationList = await service.getContent('REGULATION');
      
      if (mounted) {
        setState(() {
          _news = [...newsList, ...circularList, ...regulationList];
          _news.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 800;

    return DoubleBackPopScope(
      child: PublicScaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section
            _buildHeroSection(context, loc, isWide),
            // Importance of Portal
            _buildImportanceSection(context, loc, isWide),
            // Quick Services
            _buildQuickServices(context, loc, isWide),
            // Latest News & Circulars
            _buildLatestContent(context, loc, isWide),
            // Statistics
            _buildStatistics(context, loc, isWide),
            // About Preview
            _buildAboutPreview(context, loc, isWide),
            // Footer
            _buildFooter(context, loc),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildHeroSection(BuildContext context, AppLocalizations loc, bool isWide) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: isWide ? 500 : 400),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppTheme.primaryDark, AppTheme.primaryGreen],
        ),
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: CustomPaint(painter: _GridPainter()),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Emblem
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: AppTheme.accentGold, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: ClipOval(
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Image.asset(
                          'assets/images/app_icon.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ).animate().fadeIn(duration: 600.ms).scale(delay: 200.ms),
                  const SizedBox(height: 24),
                  Text(
                    loc.translate('appTitle'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3),
                  const SizedBox(height: 12),
                  Text(
                    loc.translate('portalDescription'),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 500.ms),
                  const SizedBox(height: 36),
                  Wrap(
                    spacing: 16,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => context.push('/login'),
                        icon: const Icon(Icons.rocket_launch),
                        label: Text(loc.translate('startService')),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentGold,
                          foregroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ).animate().fadeIn(delay: 700.ms).slideX(begin: -0.3),
                      OutlinedButton.icon(
                        onPressed: () => context.push('/services'),
                        icon: const Icon(Icons.info_outline),
                        label: Text(loc.translate('services')),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white),
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                        ),
                      ).animate().fadeIn(delay: 700.ms).slideX(begin: 0.3),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickServices(BuildContext context, AppLocalizations loc, bool isWide) {
    final services = [
      {'icon': Icons.add_business, 'key': 'newApplication', 'path': '/login'},
      {'icon': Icons.verified_user, 'key': 'verifyLicense', 'path': '/license-lookup'},
      {'icon': Icons.track_changes, 'key': 'trackApplication', 'path': '/login'},
      {'icon': Icons.gavel, 'key': 'violations', 'path': '/login'},
      {'icon': Icons.report_problem, 'key': 'complaints', 'path': '/complaints'},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Column(
        children: [
          Text(
            loc.translate('services'),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryGreen,
                ),
          ),
          const SizedBox(height: 8),
          Container(width: 60, height: 4, decoration: BoxDecoration(
            color: AppTheme.accentGold,
            borderRadius: BorderRadius.circular(2),
          )),
          const SizedBox(height: 32),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: services.asMap().entries.map((entry) {
              final index = entry.key;
              final svc = entry.value;
              return SizedBox(
                width: isWide ? 220 : (MediaQuery.of(context).size.width - 68) / 2,
                child: Card(
                  elevation: 4,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => context.push(svc['path'] as String),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryGreen.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(svc['icon'] as IconData, color: AppTheme.primaryGreen, size: 30),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            loc.translate(svc['key'] as String),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: (200 + index * 100).ms).slideY(begin: 0.2),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildImportanceSection(BuildContext context, AppLocalizations loc, bool isWide) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 32),
      color: Colors.white,
      child: Column(
        children: [
          Text(
            'أهمية البوابة الإلكترونية',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryGreen,
                ),
          ),
          const SizedBox(height: 12),
          Container(width: 80, height: 4, decoration: BoxDecoration(
            color: AppTheme.accentGold,
            borderRadius: BorderRadius.circular(2),
          )),
          const SizedBox(height: 48),
          Wrap(
            spacing: 32,
            runSpacing: 32,
            alignment: WrapAlignment.center,
            children: [
              _importanceItem(Icons.speed, 'سرعة الإنجاز', 'تقليص وقت معالجة المعاملات بنسبة 70% عبر الأتمتة الكاملة'),
              _importanceItem(Icons.security, 'الشفافية والأمان', 'تتبع دقيق لكل خطوة في معاملتك مع نظام أرشفة إلكتروني آمن'),
              _importanceItem(Icons.how_to_reg, 'سهولة الوصول', 'تقديم الطلبات ومتابعتها من أي مكان وفي أي وقت دون الحاجة للحضور'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _importanceItem(IconData icon, String title, String desc) {
    return SizedBox(
      width: 300,
      child: Column(
        children: [
          Icon(icon, color: AppTheme.accentGold, size: 48),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 8),
          Text(desc, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildLatestContent(BuildContext context, AppLocalizations loc, bool isWide) {
    if (_isLoading) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(64.0),
        child: CircularProgressIndicator(),
      ));
    }

    if (_news.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 32),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'آخر الأخبار والتعاميم',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              TextButton(onPressed: () => context.push('/news'), child: const Text('عرض الكل')),
            ],
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 24,
            runSpacing: 24,
            alignment: WrapAlignment.start,
            children: _news.take(3).map((item) {
              return _contentCard(
                item.titleAr,
                item.bodyAr,
                item.category.toLowerCase(),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _contentCard(String title, String desc, String type) {
    return Container(
      width: 380,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Icon(
              type == 'circular' ? Icons.assignment_late : type == 'news' ? Icons.newspaper : Icons.gavel,
              size: 48,
              color: AppTheme.primaryGreen,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                Text(desc, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                const SizedBox(height: 16),
                TextButton(onPressed: () {}, child: const Text('اقرأ المزيد')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics(BuildContext context, AppLocalizations loc, bool isWide) {
    final stats = [
      {'icon': Icons.description, 'count': '1,250+', 'labelKey': 'totalApplications'},
      {'icon': Icons.card_membership, 'count': '980+', 'labelKey': 'activeLicenses'},
      {'icon': Icons.search, 'count': '200+', 'labelKey': 'inspections'},
      {'icon': Icons.people, 'count': '500+', 'labelKey': 'facilityData'},
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryGreen.withOpacity(0.05), AppTheme.accentGold.withOpacity(0.05)],
        ),
      ),
      child: Wrap(
        spacing: 24,
        runSpacing: 24,
        alignment: WrapAlignment.center,
        children: stats.asMap().entries.map((entry) {
          final index = entry.key;
          final stat = entry.value;
          return SizedBox(
            width: isWide ? 200 : (MediaQuery.of(context).size.width - 72) / 2,
            child: Column(
              children: [
                Icon(stat['icon'] as IconData, color: AppTheme.primaryGreen, size: 36),
                const SizedBox(height: 8),
                Text(
                  stat['count'] as String,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGreen,
                  ),
                ),
                Text(
                  loc.translate(stat['labelKey'] as String),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ).animate().fadeIn(delay: (300 + index * 150).ms),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAboutPreview(BuildContext context, AppLocalizations loc, bool isWide) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 32),
      child: Column(
        children: [
          Text(
            loc.translate('about'),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryGreen,
                ),
          ),
          const SizedBox(height: 8),
          Container(width: 60, height: 4, decoration: BoxDecoration(
            color: AppTheme.accentGold,
            borderRadius: BorderRadius.circular(2),
          )),
          const SizedBox(height: 24),
          Text(
            loc.translate('welcomeMessage'),
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () => context.push('/about'),
            child: Text(loc.translate('viewDetails')),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, AppLocalizations loc) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      color: AppTheme.primaryDark,
      child: Column(
        children: [
          Text(
            loc.translate('appTitle'),
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            '© 2026 ${loc.translate('appSubtitle')}',
            style: const TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 0.5;
    for (double i = 0; i < size.width; i += 40) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 40) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
