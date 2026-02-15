import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _adminUsernameCtrl = TextEditingController();
  final _adminPasswordCtrl = TextEditingController();
  final _userPhoneCtrl = TextEditingController();
  final _userPasswordCtrl = TextEditingController();
  bool _isLoading = false;
  String? _error;
  bool _obscureAdmin = true;
  bool _obscureUser = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _adminUsernameCtrl.dispose();
    _adminPasswordCtrl.dispose();
    _userPhoneCtrl.dispose();
    _userPasswordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 800;

    return Scaffold(
      body: Row(
        children: [
          // Left panel (desktop only)
          if (isWide)
            Expanded(
              flex: 5,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppTheme.primaryDark, AppTheme.primaryGreen],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        Container(
                          width: 140, height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(color: AppTheme.accentGold, width: 2),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4)),
                            ],
                          ),
                          child: ClipOval(
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Image.asset('assets/images/app_icon.png', fit: BoxFit.contain),
                            ),
                          ),
                        ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
                      const SizedBox(height: 32),
                      Text(
                        loc.translate('appTitle'),
                        style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(delay: 300.ms),
                      const SizedBox(height: 12),
                      Text(
                        loc.translate('appSubtitle'),
                        style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16),
                      ).animate().fadeIn(delay: 500.ms),
                    ],
                  ),
                ),
              ),
            ),
          // Right panel – login form
          Expanded(
            flex: isWide ? 4 : 1,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (!isWide) ...[
                        Image.asset('assets/images/app_icon.png', height: 60),
                        const SizedBox(height: 16),
                        Text(loc.translate('appTitle'), textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        const SizedBox(height: 24),
                      ],
                      Text(
                        loc.translate('login'),
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          indicator: BoxDecoration(
                            color: AppTheme.primaryGreen,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.grey.shade600,
                          indicatorSize: TabBarIndicatorSize.tab,
                          dividerColor: Colors.transparent,
                          tabs: [
                            Tab(text: loc.translate('adminLogin')),
                            Tab(text: loc.translate('userLogin')),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'ملاحظة: إذا كنت مالك منشأة، يرجى اختيار تبويب "دخول المنشآت"',
                        style: TextStyle(fontSize: 12, color: AppTheme.primaryGreen, fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 280,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildAdminForm(loc),
                            _buildUserForm(loc),
                          ],
                        ),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.errorRed.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: AppTheme.errorRed, size: 20),
                              const SizedBox(width: 8),
                              Expanded(child: Text(_error!, style: const TextStyle(color: AppTheme.errorRed))),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      TextButton.icon(
                        onPressed: () => context.canPop() ? context.pop() : context.go('/'),
                        icon: const Icon(Icons.arrow_back),
                        label: Text(loc.translate('home')),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminForm(AppLocalizations loc) {
    return Column(
      children: [
        TextField(
          controller: _adminUsernameCtrl,
          decoration: InputDecoration(
            labelText: loc.translate('username'),
            prefixIcon: const Icon(Icons.person),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _adminPasswordCtrl,
          obscureText: _obscureAdmin,
          decoration: InputDecoration(
            labelText: loc.translate('password'),
            prefixIcon: const Icon(Icons.lock),
            suffixIcon: IconButton(
              icon: Icon(_obscureAdmin ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => _obscureAdmin = !_obscureAdmin),
            ),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _loginAdmin,
            child: _isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(loc.translate('login')),
          ),
        ),
      ],
    );
  }

  Widget _buildUserForm(AppLocalizations loc) {
    return Column(
      children: [
        TextField(
          controller: _userPhoneCtrl,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: loc.translate('phoneNumber'),
            prefixIcon: const Icon(Icons.phone),
            hintText: '+967...',
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _userPasswordCtrl,
          obscureText: _obscureUser,
          decoration: InputDecoration(
            labelText: loc.translate('password'),
            prefixIcon: const Icon(Icons.lock),
            suffixIcon: IconButton(
              icon: Icon(_obscureUser ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => _obscureUser = !_obscureUser),
            ),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _loginUser,
            child: _isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(loc.translate('login')),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('ليس لديك حساب؟'),
            TextButton(
              onPressed: () => context.push('/register'),
              child: const Text('تسجيل حساب جديد', style: TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const Text(
          'يمكن تسجيل الدخول بكلمة السر الافتراضية 1234',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppTheme.primaryGreen, fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Future<void> _loginAdmin() async {
    setState(() { _isLoading = true; _error = null; });
    final auth = context.read<AuthProvider>();
    final success = await auth.loginAdmin(
      _adminUsernameCtrl.text.trim(),
      _adminPasswordCtrl.text,
    );
    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        if (auth.mustChangePassword) {
          context.push('/change-password');
        } else {
          context.go('/admin');
        }
      } else {
        setState(() => _error = 'Invalid credentials');
      }
    }
  }

  Future<void> _loginUser() async {
    setState(() { _isLoading = true; _error = null; });
    final auth = context.read<AuthProvider>();
    final success = await auth.loginUser(
      _userPhoneCtrl.text.trim(),
      _userPasswordCtrl.text,
    );
    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        if (auth.mustChangePassword) {
          context.push('/change-password');
        } else {
          context.go('/portal');
        }
      } else {
        setState(() => _error = 'Invalid credentials');
      }
    }
  }
}
