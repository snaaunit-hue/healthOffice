import 'package:flutter/material.dart';
import 'dart:async';

class DoubleBackPopScope extends StatefulWidget {
  final Widget child;
  final String message;

  const DoubleBackPopScope({
    super.key,
    required this.child,
    this.message = 'انقر مرة أخرى للخروج من التطبيق',
  });

  @override
  State<DoubleBackPopScope> createState() => _DoubleBackPopScopeState();
}

class _DoubleBackPopScopeState extends State<DoubleBackPopScope> {
  DateTime? _lastPressedAt;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final now = DateTime.now();
        if (_lastPressedAt == null || 
            now.difference(_lastPressedAt!) > const Duration(seconds: 2)) {
          _lastPressedAt = now;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.message),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }

        // Second tap within 2 seconds
        final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('تأكيد الخروج'),
            content: const Text('هل أنت متأكد من رغبتك في الخروج من التطبيق؟'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('خروج'),
              ),
            ],
          ),
        );

        if (confirm == true) {
          // In Flutter, to exit app completely:
          // SystemChannels.platform.invokeMethod('SystemNavigator.pop');
          // But since we are inside PopScope and we want to allow it:
          if (context.mounted) {
            Navigator.of(context).pop(true);
            // On android this usually exits if it's the root.
            // If using go_router, it might be different.
          }
        }
      },
      child: widget.child,
    );
  }
}
