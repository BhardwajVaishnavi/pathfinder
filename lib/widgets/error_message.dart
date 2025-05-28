import 'package:flutter/material.dart';
import '../utils/utils.dart';
import 'custom_button.dart';

class ErrorMessage extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData icon;

  const ErrorMessage({
    Key? key,
    required this.message,
    this.onRetry,
    this.icon = Icons.error_outline,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: AppDimensions.paddingM),
            Text(
              message,
              style: AppTextStyles.subtitle1,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppDimensions.paddingL),
              CustomButton(
                text: AppStrings.retry,
                onPressed: onRetry!,
                type: ButtonType.primary,
                icon: Icons.refresh,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
