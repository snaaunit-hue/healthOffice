import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/localization/app_localizations.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final config = _getConfig(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: config.color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: config.color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config.icon, size: 14, color: config.color),
          const SizedBox(width: 6),
          Text(
            _getTranslatedStatus(context, status),
            style: TextStyle(
              color: config.color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  static _StatusConfig _getConfig(String status) {
    return switch (status) {
      'DRAFT' => _StatusConfig(Colors.grey, Icons.edit_note),
      'SUBMITTED' => _StatusConfig(AppTheme.infoBlu, Icons.send),
      'UNDER_REVIEW' => _StatusConfig(AppTheme.warningOrange, Icons.rate_review),
      'BLUEPRINT_REVIEW' => _StatusConfig(Colors.deepPurple, Icons.architecture),
      'INSPECTION_SCHEDULED' => _StatusConfig(Colors.indigo, Icons.calendar_today),
      'INSPECTION_COMPLETED' => _StatusConfig(Colors.teal, Icons.check_circle_outline),
      'COMMITTEE_APPROVED' => _StatusConfig(AppTheme.successGreen, Icons.verified),
      'PAYMENT_PENDING' => _StatusConfig(AppTheme.warningOrange, Icons.payment),
      'PAYMENT_COMPLETED' => _StatusConfig(AppTheme.successGreen, Icons.paid),
      'LICENSE_ISSUED' => _StatusConfig(AppTheme.primaryGreen, Icons.card_membership),
      'REJECTED' => _StatusConfig(AppTheme.errorRed, Icons.cancel),
      'ARCHIVED' => _StatusConfig(Colors.blueGrey, Icons.archive),
      'SCHEDULED' => _StatusConfig(Colors.indigo, Icons.schedule),
      'COMPLETED' => _StatusConfig(AppTheme.successGreen, Icons.done_all),
      'PENDING' => _StatusConfig(AppTheme.warningOrange, Icons.hourglass_top),
      'PAID' => _StatusConfig(AppTheme.successGreen, Icons.check_circle),
      'ACTIVE' => _StatusConfig(AppTheme.successGreen, Icons.verified),
      _ => _StatusConfig(Colors.grey, Icons.info_outline),
    };
  }
  static String _getTranslatedStatus(BuildContext context, String status) {
    final loc = AppLocalizations.of(context)!;
    final Map<String, String> keyMap = {
      'DRAFT': 'draft',
      'SUBMITTED': 'submitted',
      'UNDER_REVIEW': 'underReview',
      'BLUEPRINT_REVIEW': 'blueprintReview',
      'INSPECTION_SCHEDULED': 'inspectionScheduled',
      'INSPECTION_COMPLETED': 'inspectionCompleted',
      'COMMITTEE_APPROVED': 'committeeApproved',
      'PAYMENT_PENDING': 'paymentPending',
      'PAYMENT_COMPLETED': 'paymentCompleted',
      'LICENSE_ISSUED': 'licenseIssued',
      'REJECTED': 'rejected',
      'ARCHIVED': 'archived',
    };
    final key = keyMap[status];
    return key != null ? loc.translate(key) : status.replaceAll('_', ' ');
  }
}

class _StatusConfig {
  final Color color;
  final IconData icon;
  const _StatusConfig(this.color, this.icon);
}
