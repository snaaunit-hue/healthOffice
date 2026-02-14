import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/localization/app_localizations.dart';

class WorkflowTracker extends StatelessWidget {
  final int currentStep;
  const WorkflowTracker({super.key, required this.currentStep});

  static const List<String> stepKeys = [
    'draft', 'submitted', 'underReview', 'blueprintReview', 'inspectionScheduled',
    'inspectionCompleted', 'committeeApproved', 'paymentPending',
    'paymentCompleted', 'licenseIssued', 'archived',
  ];

  static const List<IconData> stepIcons = [
    Icons.edit_note, Icons.send, Icons.rate_review, Icons.architecture, Icons.calendar_today,
    Icons.check_circle_outline, Icons.verified, Icons.payment,
    Icons.paid, Icons.card_membership, Icons.archive,
  ];

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: List.generate(stepKeys.length, (index) {
          final isCompleted = index < currentStep;
          final isCurrent = index == currentStep;

          return Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? AppTheme.primaryGreen
                          : isCurrent
                              ? AppTheme.accentGold
                              : Colors.grey.shade300,
                      shape: BoxShape.circle,
                      boxShadow: isCurrent
                          ? [
                              BoxShadow(
                                color: AppTheme.accentGold.withOpacity(0.4),
                                blurRadius: 8,
                                spreadRadius: 2,
                              )
                            ]
                          : null,
                    ),
                    child: Icon(
                      isCompleted ? Icons.check : stepIcons[index],
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: 80,
                    child: Text(
                      loc.translate(stepKeys[index]),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                        color: isCompleted
                            ? AppTheme.primaryGreen
                            : isCurrent
                                ? AppTheme.accentGold
                                : Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
              if (index < stepKeys.length - 1)
                Container(
                  width: 30,
                  height: 3,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: isCompleted ? AppTheme.primaryGreen : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }
}
