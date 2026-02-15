import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';

class AdminEmployeesScreen extends StatefulWidget {
  const AdminEmployeesScreen({super.key});

  @override
  State<AdminEmployeesScreen> createState() => _AdminEmployeesScreenState();
}

class _AdminEmployeesScreenState extends State<AdminEmployeesScreen> {
  List<dynamic> _employees = [];
  List<dynamic> _roles = []; // الأدوار من الـ API (code, nameAr, nameEn, permissionCodes)
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchEmployees();
    _fetchRoles();
  }

  Future<void> _fetchRoles() async {
    try {
      final api = context.read<AuthProvider>().apiService;
      final list = await api.get('/admin/roles');
      if (mounted && list is List) setState(() => _roles = list);
    } catch (_) {}
  }

  Future<void> _fetchEmployees() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final api = context.read<AuthProvider>().apiService;
      final response = await api.get('/admin/employees');
      setState(() {
        _employees = response['content'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/admin'),
        ),
        title: const Text('إدارة الموظفين والمهام'),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchEmployees),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ElevatedButton.icon(
              onPressed: _showAddEmployeeDialog,
              icon: const Icon(Icons.add),
              label: const Text('موظف جديد'),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentGold),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : _employees.isEmpty
                  ? const Center(child: Text('لا يوجد موظفين حالياً'))
                  : Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1000),
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _employees.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final emp = _employees[index];
                            return _buildEmployeeCard(emp);
                          },
                        ),
                      ),
                    ),
    );
  }

  Widget _buildEmployeeCard(dynamic emp) {
    final bool isEnabled = emp['enabled'] ?? true;
    final List<dynamic> roles = emp['roles'] ?? [];

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isEnabled ? AppTheme.primaryGreen : Colors.grey,
          child: const Icon(Icons.person, color: Colors.white),
        ),
        title: Text(emp['fullName'] ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('اسم المستخدم: ${emp['username']}'),
            Text('البريد: ${emp['email'] ?? 'N/A'}'),
            Wrap(
              spacing: 4,
              children: roles.map((r) => Chip(
                label: Text(r.toString(), style: const TextStyle(fontSize: 10)),
                backgroundColor: AppTheme.accentLight,
              )).toList(),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: isEnabled,
              activeColor: AppTheme.primaryGreen,
              onChanged: (val) => _toggleEmployeeStatus(emp['id'], val),
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: AppTheme.primaryGreen),
              onPressed: () => _showEditEmployeeDialog(emp),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleEmployeeStatus(int id, bool enabled) async {
    try {
      final api = context.read<AuthProvider>().apiService;
      await api.put('/admin/employees/$id', body: {'enabled': enabled});
      _fetchEmployees();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    }
  }

  void _showAddEmployeeDialog() {
    _showEmployeeForm();
  }

  void _showEditEmployeeDialog(dynamic emp) {
    _showEmployeeForm(emp: emp);
  }

  void _showEmployeeForm({dynamic emp}) {
    final isEdit = emp != null;
    final fullNameCtrl = TextEditingController(text: emp?['fullName']);
    final usernameCtrl = TextEditingController(text: emp?['username']);
    final emailCtrl = TextEditingController(text: emp?['email']);
    final phoneCtrl = TextEditingController(text: emp?['phoneNumber']);
    final passwordCtrl = TextEditingController();
    
    Set<String> selectedRoles = Set.from(List<String>.from(emp?['roles'] ?? (isEdit ? [] : ['LICENSING_OFFICER'])));

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isEdit ? 'تعديل بيانات موظف' : 'إضافة موظف جديد'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(controller: fullNameCtrl, decoration: const InputDecoration(labelText: 'الاسم الكامل')),
                    if (!isEdit) TextField(controller: usernameCtrl, decoration: const InputDecoration(labelText: 'اسم المستخدم')),
                    if (!isEdit) TextField(controller: passwordCtrl, decoration: const InputDecoration(labelText: 'كلمة المرور'), obscureText: true),
                    TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'البريد الإلكتروني')),
                    TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'رقم الهاتف')),
                    const SizedBox(height: 16),
                    const Text('الدور / الصلاحيات:', style: TextStyle(fontWeight: FontWeight.bold)),
                    if (_roles.isEmpty)
                      const Padding(padding: EdgeInsets.all(8), child: Text('جاري تحميل الأدوار...', style: TextStyle(fontSize: 12)))
                    else
                      ...(_roles as List).map((r) => _roleCheckbox(
                        r['nameAr'] ?? r['code'] ?? '', 
                        r['code'] ?? '', 
                        selectedRoles, 
                        setDialogState,
                      )),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
                ElevatedButton(
                  onPressed: () async {
                    final api = context.read<AuthProvider>().apiService;
                    final body = {
                      'fullName': fullNameCtrl.text,
                      'email': emailCtrl.text,
                      'phoneNumber': phoneCtrl.text,
                      'roles': selectedRoles.toList(),
                    };
                    if (!isEdit) {
                      body['username'] = usernameCtrl.text;
                      body['password'] = passwordCtrl.text;
                    }

                    try {
                      if (isEdit) {
                        await api.put('/admin/employees/${emp['id']}', body: body);
                      } else {
                        await api.post('/admin/employees', body: body);
                      }
                      if (context.mounted) {
                        Navigator.pop(context);
                        _fetchEmployees();
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('خطأ: $e'), backgroundColor: AppTheme.errorRed),
                        );
                      }
                    }
                  },
                  child: const Text('حفظ'),
                ),
              ],
            );
          }
        );
      }
    );
  }

  Widget _roleCheckbox(String label, String code, Set<String> selected, StateSetter setState) {
    return CheckboxListTile(
      title: Text(label),
      value: selected.contains(code),
      onChanged: (val) {
        setState(() {
          if (val == true) selected.add(code);
          else selected.remove(code);
        });
      },
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }
}
