import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';

class MediaManagementScreen extends StatefulWidget {
  const MediaManagementScreen({super.key});

  @override
  State<MediaManagementScreen> createState() => _MediaManagementScreenState();
}

class _MediaManagementScreenState extends State<MediaManagementScreen> {
  List<dynamic> _contents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchContent();
  }

  Future<void> _fetchContent() async {
    setState(() => _isLoading = true);
    try {
      final api = context.read<AuthProvider>().apiService;
      final response = await api.get('/admin/media/content');
      setState(() {
        _contents = response ?? [];
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      setState(() => _isLoading = false);
    }
  }

  void _showForm({dynamic content}) {
    final isEdit = content != null;
    final titleArCtrl = TextEditingController(text: content?['titleAr']);
    final contentArCtrl = TextEditingController(text: content?['contentAr']);
    String category = content?['category'] ?? 'NEWS';
    bool isPublished = content?['published'] ?? false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEdit ? 'تعديل محتوى' : 'إضافة محتوى جديد'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: category,
                  items: const [
                    DropdownMenuItem(value: 'NEWS', child: Text('خبر صحفي')),
                    DropdownMenuItem(value: 'CIRCULAR', child: Text('تعميم')),
                    DropdownMenuItem(value: 'REGULATION', child: Text('لائحة')),
                  ],
                  onChanged: (v) => setDialogState(() => category = v!),
                  decoration: const InputDecoration(labelText: 'التصنيف'),
                ),
                TextField(controller: titleArCtrl, decoration: const InputDecoration(labelText: 'العنوان')),
                TextField(controller: contentArCtrl, decoration: const InputDecoration(labelText: 'المحتوى'), maxLines: 5),
                SwitchListTile(
                  title: const Text('نشر في الموقع العام'),
                  value: isPublished, 
                  onChanged: (v) => setDialogState(() => isPublished = v),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () async {
                final api = context.read<AuthProvider>().apiService;
                final body = {
                  'category': category,
                  'titleAr': titleArCtrl.text,
                  'contentAr': contentArCtrl.text,
                  'published': isPublished,
                };
                if (isEdit) {
                  await api.put('/admin/media/content/${content['id']}', body: body);
                } else {
                  await api.post('/admin/media/content', body: body);
                }
                if (context.mounted) {
                  Navigator.pop(context);
                  _fetchContent();
                }
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/admin'),
        ),
        title: const Text('إدارة الموقع العام'),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: () => _showForm()),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: ListView.builder(
                  itemCount: _contents.length,
                  itemBuilder: (context, index) {
                    final item = _contents[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
                          child: Icon(_getIcon(item['category'])),
                        ),
                        title: Text(item['titleAr'] ?? ''),
                        subtitle: Text(item['category'], style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(icon: const Icon(Icons.edit), onPressed: () => _showForm(content: item)),
                            IconButton(
                              icon: const Icon(Icons.delete, color: AppTheme.errorRed),
                              onPressed: () async {
                                final api = context.read<AuthProvider>().apiService;
                                await api.delete('/admin/media/content/${item['id']}');
                                _fetchContent();
                              },
                            ),
                          ],
                        ),
                        onLongPress: () async {
                          final api = context.read<AuthProvider>().apiService;
                          await api.post('/admin/media/content/${item['id']}/toggle-publish');
                          _fetchContent();
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
    );
  }

  IconData _getIcon(String cat) {
    switch (cat) {
      case 'CIRCULAR': return Icons.assignment_late;
      case 'REGULATION': return Icons.gavel;
      default: return Icons.newspaper;
    }
  }
}
